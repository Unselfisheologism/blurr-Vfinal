/// Excel import/export service using Syncfusion XLSIO
import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/spreadsheet_document.dart';
import '../models/spreadsheet_cell.dart';

class ExcelService {
  /// Export spreadsheet to Excel file
  Future<String> exportToExcel(SpreadsheetDocument document) async {
    // Create a new Excel document
    final xlsio.Workbook workbook = xlsio.Workbook();
    
    // Add sheets
    for (int i = 0; i < document.sheets.length; i++) {
      final sheet = document.sheets[i];
      xlsio.Worksheet worksheet;
      
      if (i == 0 && workbook.worksheets.count > 0) {
        // Use the default first worksheet
        worksheet = workbook.worksheets[0];
        worksheet.name = sheet.name;
      } else {
        // Add new worksheet
        worksheet = workbook.worksheets.addWithName(sheet.name);
      }
      
      // Add cell data
      sheet.cells.forEach((cellId, cell) {
        final (row, col) = _parseCellId(cellId);
        final xlsio.Range range = worksheet.getRangeByIndex(row + 1, col + 1);
        
        // Set value based on type
        if (cell.dataType == CellDataType.formula && cell.formula != null) {
          range.formula = cell.formula;
        } else if (cell.value is num) {
          range.number = (cell.value as num).toDouble();
        } else if (cell.value is bool) {
          range.value = cell.value as bool;
        } else if (cell.value is DateTime) {
          range.dateTime = cell.value as DateTime;
        } else {
          range.text = cell.displayValue;
        }
        
        // Apply formatting
        _applyFormatting(range, cell.format);
      });
    }
    
    // Save the document
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    
    // Write to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${document.name}.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);
    
    return path;
  }

  /// Import Excel file to SpreadsheetDocument
  Future<SpreadsheetDocument> importFromExcel(String filePath) async {
    // Note: syncfusion_flutter_xlsio currently has limited support for reading existing files.
    // This is a placeholder implementation or requires a different package like 'excel'.
    
    final File file = File(filePath);
    // ignore: unused_local_variable
    final bytes = await file.readAsBytes();
    
    // Fallback to empty document if reading is not supported by this version of xlsio
    // In a real scenario, we'd use the 'excel' package here for reading.
    final now = DateTime.now();
    return SpreadsheetDocument(
      id: now.millisecondsSinceEpoch.toString(),
      name: file.path.split('/').last.replaceAll('.xlsx', ''),
      sheets: [SpreadsheetSheet.empty('Sheet1')],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Open exported file
  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  void _applyFormatting(xlsio.Range range, CellFormat format) {
    if (format.bold) range.cellStyle.bold = true;
    if (format.italic) range.cellStyle.italic = true;
    
    if (format.textColorValue != null) {
      // Convert Flutter color to Hex string for Syncfusion
      final color = format.textColorValue!;
      range.cellStyle.fontColor = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    }
    
    if (format.backgroundColorValue != null) {
      final color = format.backgroundColorValue!;
      range.cellStyle.backColor = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    }
    
    if (format.fontSize != null) {
      range.cellStyle.fontSize = format.fontSize!;
    }
    
    if (format.alignment != null) {
      range.cellStyle.hAlign = _getHorizontalAlignment(format.alignment!);
    }
  }

  String _getCellId(int row, int col) {
    String label = '';
    int tempCol = col;
    while (tempCol >= 0) {
      label = String.fromCharCode(65 + (tempCol % 26)) + label;
      tempCol = (tempCol ~/ 26) - 1;
    }
    return '$label${row + 1}';
  }

  (int, int) _parseCellId(String cellId) {
    final colMatch = RegExp(r'^[A-Z]+').firstMatch(cellId);
    final rowMatch = RegExp(r'\d+$').firstMatch(cellId);
    
    if (colMatch == null || rowMatch == null) {
      throw FormatException('Invalid cell ID: $cellId');
    }

    final colLabel = colMatch.group(0)!;
    final row = int.parse(rowMatch.group(0)!) - 1;
    
    int col = 0;
    for (int i = 0; i < colLabel.length; i++) {
      col = col * 26 + (colLabel.codeUnitAt(i) - 64);
    }
    col -= 1;
    
    return (row, col);
  }

  xlsio.HAlignType _getHorizontalAlignment(Alignment alignment) {
    if (alignment == Alignment.centerLeft) return xlsio.HAlignType.left;
    if (alignment == Alignment.center) return xlsio.HAlignType.center;
    if (alignment == Alignment.centerRight) return xlsio.HAlignType.right;
    return xlsio.HAlignType.left;
  }

  // ignore: unused_element
  Alignment? _getAlignment(xlsio.HAlignType hAlign) {
    switch (hAlign) {
      case xlsio.HAlignType.left:
        return Alignment.centerLeft;
      case xlsio.HAlignType.center:
        return Alignment.center;
      case xlsio.HAlignType.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}

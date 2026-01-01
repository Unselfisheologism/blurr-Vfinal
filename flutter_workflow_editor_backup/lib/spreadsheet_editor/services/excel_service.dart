/// Excel import/export service using Syncfusion XLSIO
import 'dart:io';
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
    
    // Remove default worksheet if multiple sheets
    if (document.sheets.length > 1) {
      workbook.worksheets.clear();
    }
    
    // Add sheets
    for (int i = 0; i < document.sheets.length; i++) {
      final sheet = document.sheets[i];
      final xlsio.Worksheet worksheet = i == 0 && workbook.worksheets.isNotEmpty
          ? workbook.worksheets[0]
          : workbook.worksheets.add();
      
      worksheet.name = sheet.name;
      
      // Populate cells
      for (var entry in sheet.cells.entries) {
        final cellId = entry.key;
        final cell = entry.value;
        final (row, col) = _parseCellId(cellId);
        
        // XLSIO uses 1-based indexing
        final xlsioCell = worksheet.getRangeByIndex(row + 1, col + 1);
        
        // Set value
        if (cell.value != null) {
          if (cell.dataType == CellDataType.number && cell.value is num) {
            xlsioCell.setNumber(cell.value);
          } else if (cell.dataType == CellDataType.formula && cell.formula != null) {
            xlsioCell.setFormula(cell.formula!);
          } else {
            xlsioCell.setText(cell.displayValue);
          }
        }
        
        // Apply formatting
        final format = cell.format;
        if (format.bold) {
          xlsioCell.cellStyle.bold = true;
        }
        if (format.italic) {
          xlsioCell.cellStyle.italic = true;
        }
        if (format.underline) {
          xlsioCell.cellStyle.underline = true;
        }
        if (format.fontSize != null) {
          xlsioCell.cellStyle.fontSize = format.fontSize!;
        }
        if (format.textColor != null) {
          final color = _parseColor(format.textColor!);
          xlsioCell.cellStyle.fontColor = color;
        }
        if (format.backgroundColor != null) {
          final color = _parseColor(format.backgroundColor!);
          xlsioCell.cellStyle.backColor = color;
        }
        if (format.alignment != null) {
          xlsioCell.cellStyle.hAlign = _getHorizontalAlignment(format.alignment!);
        }
      }
    }
    
    // Save to file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    
    // Get application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${document.name}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    
    return filePath;
  }

  /// Import Excel file to SpreadsheetDocument
  Future<SpreadsheetDocument> importFromExcel(String filePath) async {
    final File file = File(filePath);
    final bytes = await file.readAsBytes();
    
    // Open the workbook
    final xlsio.Workbook workbook = xlsio.Workbook.fromBytes(bytes);
    
    final sheets = <SpreadsheetSheet>[];
    
    // Process each worksheet
    for (final worksheet in workbook.worksheets) {
      final cells = <String, SpreadsheetCell>{};
      
      // Get used range to avoid processing empty cells
      final usedRange = worksheet.usedRange;
      if (usedRange == null) continue;
      
      final rowCount = usedRange.lastRow;
      final colCount = usedRange.lastColumn;
      
      // Read all cells in used range
      for (int row = 1; row <= rowCount; row++) {
        for (int col = 1; col <= colCount; col++) {
          final xlsioCell = worksheet.getRangeByIndex(row, col);
          
          // Skip empty cells
          if (xlsioCell.text.isEmpty && xlsioCell.number == null) continue;
          
          final cellId = _getCellId(row - 1, col - 1); // Convert to 0-based
          
          // Determine cell type and value
          dynamic value;
          CellDataType dataType = CellDataType.text;
          String? formula;
          
          if (xlsioCell.hasFormula) {
            formula = xlsioCell.formula;
            dataType = CellDataType.formula;
            value = xlsioCell.calculatedValue;
          } else if (xlsioCell.number != null) {
            value = xlsioCell.number;
            dataType = CellDataType.number;
          } else {
            value = xlsioCell.text;
            dataType = CellDataType.text;
          }
          
          // Extract formatting
          final cellStyle = xlsioCell.cellStyle;
          final format = CellFormat(
            bold: cellStyle.bold,
            italic: cellStyle.italic,
            underline: cellStyle.underline,
            fontSize: cellStyle.fontSize.toDouble(),
            textColor: _colorToHex(cellStyle.fontColor),
            backgroundColor: _colorToHex(cellStyle.backColor),
            alignment: _getAlignment(cellStyle.hAlign),
          );
          
          cells[cellId] = SpreadsheetCell(
            id: cellId,
            value: value,
            dataType: dataType,
            format: format,
            formula: formula,
          );
        }
      }
      
      sheets.add(SpreadsheetSheet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: worksheet.name,
        rowCount: rowCount,
        columnCount: colCount,
        cells: cells,
      ));
    }
    
    workbook.dispose();
    
    // Create document
    final fileName = file.path.split('/').last.replaceAll('.xlsx', '');
    final now = DateTime.now();
    
    return SpreadsheetDocument(
      id: now.millisecondsSinceEpoch.toString(),
      name: fileName,
      sheets: sheets.isNotEmpty ? sheets : [SpreadsheetSheet.empty('Sheet1')],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Open exported file
  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  // Helper methods
  String _getCellId(int row, int col) {
    return '${_getColumnLabel(col)}${row + 1}';
  }

  String _getColumnLabel(int col) {
    String label = '';
    int tempCol = col;
    while (tempCol >= 0) {
      label = String.fromCharCode(65 + (tempCol % 26)) + label;
      tempCol = (tempCol ~/ 26) - 1;
    }
    return label;
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

  String _parseColor(String hexColor) {
    // Remove # and 0xFF prefix if present
    final color = hexColor.replaceAll('#', '').replaceAll('0xFF', '');
    return '#$color';
  }

  String? _colorToHex(String color) {
    if (color.isEmpty || color == '#000000') return null;
    return color;
  }

  xlsio.HAlignType _getHorizontalAlignment(Alignment alignment) {
    if (alignment == Alignment.centerLeft) return xlsio.HAlignType.left;
    if (alignment == Alignment.center) return xlsio.HAlignType.center;
    if (alignment == Alignment.centerRight) return xlsio.HAlignType.right;
    return xlsio.HAlignType.left;
  }

  Alignment? _getAlignment(xlsio.HAlignType hAlign) {
    switch (hAlign) {
      case xlsio.HAlignType.left:
        return Alignment.centerLeft;
      case xlsio.HAlignType.center:
        return Alignment.center;
      case xlsio.HAlignType.right:
        return Alignment.centerRight;
      default:
        return null;
    }
  }
}

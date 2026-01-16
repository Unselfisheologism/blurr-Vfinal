/// Excel import/export service using excel package (4.0.0+)
import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/spreadsheet_document.dart';
import '../models/spreadsheet_cell.dart';

class ExcelService {
  /// Export spreadsheet to Excel file
  Future<String> exportToExcel(SpreadsheetDocument document) async {
    // Create a new Excel document
    final excel.Excel excelFile = excel.Excel.createExcel();
    
    // Add sheets
    for (int i = 0; i < document.sheets.length; i++) {
      final sheet = document.sheets[i];
      
      if (i == 0 && excelFile.sheets.isNotEmpty) {
        // Use the default first sheet
        final excelSheet = excelFile[sheet.name]!;
        _populateSheet(excelSheet, sheet);
      } else {
        // Add new sheet
        final excelSheet = excelFile['${sheet.name}_$i'];
        _populateSheet(excelSheet, sheet);
      }
    }
    
    // Save the document
    final List<int>? bytes = excelFile.save();
    
    if (bytes == null) {
      throw Exception('Failed to save Excel file');
    }
    
    // Write to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${document.name}.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes!);
    
    return path;
  }
  
  void _populateSheet(excel.Sheet excelSheet, SpreadsheetSheet sheet) {
    // Clear default row
    excelSheet.removeRow(0);

    // Find max dimensions
    int maxRow = 0;
    int maxCol = 0;
    sheet.cells.forEach((cellId, cell) {
      final (row, col) = _parseCellId(cellId);
      maxRow = maxRow > row ? maxRow : row;
      maxCol = maxCol > col ? maxCol : col;
    });

    // Add data row by row
    for (int row = 0; row <= maxRow; row++) {
      final List<excel.CellValue> rowData = [];

      for (int col = 0; col <= maxCol; col++) {
        final cellId = _getCellId(row, col);
        final cell = sheet.cells[cellId];

        // Set value based on type
        if (cell == null) {
          rowData.add(excel.TextCellValue(''));
        } else if (cell.dataType == CellDataType.formula && cell.formula != null) {
          rowData.add(excel.TextCellValue(cell.formula!));
        } else if (cell.value is num) {
          final numValue = cell.value as num;
          if (numValue is int) {
            rowData.add(excel.IntCellValue(numValue.toInt()));
          } else {
            rowData.add(excel.DoubleCellValue(numValue.toDouble()));
          }
        } else if (cell.value is bool) {
          rowData.add(excel.BoolCellValue(cell.value as bool));
        } else if (cell.value is DateTime) {
          final dateTime = cell.value as DateTime;
          rowData.add(excel.DateTimeCellValue.fromDateTime(dateTime));
        } else {
          rowData.add(excel.TextCellValue(cell.displayValue));
        }
      }

      excelSheet.appendRow(rowData);

      // Apply formatting after appending
      for (int col = 0; col <= maxCol; col++) {
        final cellId = _getCellId(row, col);
        final cell = sheet.cells[cellId];
        if (cell != null && cell.format != null) {
          _applyFormatting(excelSheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row)), cell.format!);
        }
      }
    }
  }
  
  /// Import Excel file to SpreadsheetDocument
  Future<SpreadsheetDocument> importFromExcel(String filePath) async {
    final File file = File(filePath);
    final bytes = await file.readAsBytes();
    final excelFile = excel.Excel.decodeBytes(bytes);
    
    if (excelFile.tables.isEmpty) {
      final now = DateTime.now();
      return SpreadsheetDocument(
        id: now.millisecondsSinceEpoch.toString(),
        name: file.path.split('/').last.replaceAll('.xlsx', ''),
        sheets: [SpreadsheetSheet.empty('Sheet1')],
        createdAt: now,
        updatedAt: now,
      );
    }
    
    final sheets = <SpreadsheetSheet>[];
    
    excelFile.tables.forEach((sheetName, table) {
      final rows = <String, SpreadsheetCell>{};
      
      for (var rowIdx = 0; rowIdx < table.rows.length; rowIdx++) {
        final excelRow = table.rows[rowIdx];
        for (var colIdx = 0; colIdx < excelRow.length; colIdx++) {
          final cellData = excelRow[colIdx];
          final cellId = _getCellId(rowIdx, colIdx);
          final value = _convertCellValue(cellData?.value);
          
          rows[cellId] = SpreadsheetCell(
            id: cellId,
            value: value,
            dataType: _inferDataType(cellData?.value),
          );
        }
      }
      
      sheets.add(SpreadsheetSheet(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + sheets.length.toString(),
        name: sheetName,
        cells: rows,
        rowCount: table.maxRows,
        columnCount: table.maxCols,
      ));
    });
    
    final now = DateTime.now();
    return SpreadsheetDocument(
      id: now.millisecondsSinceEpoch.toString(),
      name: file.path.split('/').last.replaceAll('.xlsx', ''),
      sheets: sheets,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  dynamic _convertCellValue(excel.CellValue? value) {
    if (value == null) return '';
    
    switch (value) {
      case excel.TextCellValue():
        return (value as excel.TextCellValue).value;
      case excel.IntCellValue():
        return (value as excel.IntCellValue).value;
      case excel.DoubleCellValue():
        return (value as excel.DoubleCellValue).value;
      case excel.BoolCellValue():
        return (value as excel.BoolCellValue).value;
      case excel.DateCellValue():
        return (value as excel.DateCellValue).asDateTimeLocal();
      case excel.DateTimeCellValue():
        return (value as excel.DateTimeCellValue).asDateTimeLocal();
      case excel.TimeCellValue():
        return (value as excel.TimeCellValue).asDuration();
      default:
        return '';
    }
  }
  
  CellDataType _inferDataType(excel.CellValue? value) {
    if (value == null) return CellDataType.text;
    
    switch (value) {
      case excel.IntCellValue():
      case excel.DoubleCellValue():
        return CellDataType.number;
      case excel.BoolCellValue():
        return CellDataType.boolean;
      case excel.DateCellValue():
      case excel.DateTimeCellValue():
        return CellDataType.date;
      default:
        return CellDataType.text;
    }
  }
  
  /// Open exported file
  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }
  
  void _applyFormatting(dynamic cell, CellFormat format) {
    final cellStyle = cell.cellStyle?.copyWith(
      bold: format.bold,
      italic: format.italic,
      underline: format.underline ? excel.Underline.Single : excel.Underline.None,
      fontColorHex: format.textColorValue != null
          ? _colorToHex(format.textColorValue!)
          : '#000000',
      backgroundColorHex: format.backgroundColorValue != null
          ? _colorToHex(format.backgroundColorValue!)
          : null,
      fontSize: format.fontSize?.toInt(),
      horizontalAlign: _convertAlignment(format.alignment),
    ) ?? excel.CellStyle(
      bold: format.bold,
      italic: format.italic,
      underline: format.underline ? excel.Underline.Single : excel.Underline.None,
      fontColorHex: format.textColorValue != null
          ? _colorToHex(format.textColorValue!)
          : '#000000',
      backgroundColorHex: format.backgroundColorValue != null
          ? _colorToHex(format.backgroundColorValue!)
          : null,
      fontSize: format.fontSize?.toInt(),
      horizontalAlign: _convertAlignment(format.alignment),
    );

    cell.cellStyle = cellStyle;
  }
  
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
  
  excel.HorizontalAlign _convertAlignment(Alignment? alignment) {
    if (alignment == null) return excel.HorizontalAlign.Left;
    
    if (alignment == Alignment.centerLeft) return excel.HorizontalAlign.Left;
    if (alignment == Alignment.center) return excel.HorizontalAlign.Center;
    if (alignment == Alignment.centerRight) return excel.HorizontalAlign.Right;
    
    return excel.HorizontalAlign.Left;
  }
  
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
}

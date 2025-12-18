/// CSV import/export service
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/spreadsheet_document.dart';
import '../models/spreadsheet_cell.dart';

class CsvService {
  /// Export spreadsheet to CSV format
  Future<String> exportToCsv(SpreadsheetDocument document) async {
    final sheet = document.sheets.isNotEmpty ? document.sheets[0] : null;
    if (sheet == null) {
      throw Exception('No sheets to export');
    }

    final buffer = StringBuffer();
    
    // Generate CSV rows
    for (int row = 0; row < sheet.rowCount; row++) {
      final rowValues = <String>[];
      
      for (int col = 0; col < sheet.columnCount; col++) {
        final cellId = _getCellId(row, col);
        final cell = sheet.cells[cellId];
        
        if (cell != null && cell.value != null) {
          String value = cell.displayValue;
          
          // Escape quotes and wrap in quotes if contains comma, newline, or quote
          if (value.contains(',') || value.contains('\n') || value.contains('"')) {
            value = '"${value.replaceAll('"', '""')}"';
          }
          
          rowValues.add(value);
        } else {
          rowValues.add('');
        }
      }
      
      buffer.writeln(rowValues.join(','));
    }
    
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${document.name}.csv';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    
    return filePath;
  }

  /// Import CSV file to SpreadsheetDocument
  Future<SpreadsheetDocument> importFromCsv(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    
    final lines = content.split('\n');
    final cells = <String, SpreadsheetCell>{};
    
    int maxColumns = 0;
    
    for (int row = 0; row < lines.length; row++) {
      if (lines[row].trim().isEmpty) continue;
      
      final values = _parseCsvLine(lines[row]);
      maxColumns = values.length > maxColumns ? values.length : maxColumns;
      
      for (int col = 0; col < values.length; col++) {
        final value = values[col].trim();
        if (value.isEmpty) continue;
        
        final cellId = _getCellId(row, col);
        
        // Try to detect data type
        CellDataType dataType = CellDataType.text;
        dynamic cellValue = value;
        
        if (value.startsWith('=')) {
          dataType = CellDataType.formula;
        } else if (double.tryParse(value) != null) {
          dataType = CellDataType.number;
          cellValue = double.parse(value);
        }
        
        cells[cellId] = SpreadsheetCell(
          id: cellId,
          value: cellValue,
          dataType: dataType,
        );
      }
    }
    
    // Create sheet
    final sheet = SpreadsheetSheet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Sheet1',
      rowCount: lines.length,
      columnCount: maxColumns,
      cells: cells,
    );
    
    // Create document
    final fileName = file.path.split('/').last.replaceAll('.csv', '');
    final now = DateTime.now();
    
    return SpreadsheetDocument(
      id: now.millisecondsSinceEpoch.toString(),
      name: fileName,
      sheets: [sheet],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Parse CSV line handling quoted values
  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++;
        } else {
          // Toggle quotes
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // End of value
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    // Add last value
    values.add(buffer.toString());
    
    return values;
  }

  /// Helper: Get cell ID from row and column
  String _getCellId(int row, int col) {
    return '${_getColumnLabel(col)}${row + 1}';
  }

  /// Helper: Convert column index to letter
  String _getColumnLabel(int col) {
    String label = '';
    int tempCol = col;
    while (tempCol >= 0) {
      label = String.fromCharCode(65 + (tempCol % 26)) + label;
      tempCol = (tempCol ~/ 26) - 1;
    }
    return label;
  }
}

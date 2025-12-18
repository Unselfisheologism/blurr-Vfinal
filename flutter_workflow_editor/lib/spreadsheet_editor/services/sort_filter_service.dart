/// Sort and filter service for spreadsheet data
import '../models/spreadsheet_document.dart';
import '../models/spreadsheet_cell.dart';

enum SortOrder {
  ascending,
  descending,
}

class SortFilterService {
  /// Sort sheet by column
  SpreadsheetSheet sortByColumn(
    SpreadsheetSheet sheet,
    int columnIndex, {
    SortOrder order = SortOrder.ascending,
  }) {
    // Get all rows with data
    final rows = <int, Map<String, SpreadsheetCell>>{};
    
    for (var entry in sheet.cells.entries) {
      final (row, col) = _parseCellId(entry.key);
      if (!rows.containsKey(row)) {
        rows[row] = {};
      }
      rows[row]![entry.key] = entry.value;
    }
    
    // Sort rows by column value
    final sortedRowIndices = rows.keys.toList();
    sortedRowIndices.sort((a, b) {
      final cellIdA = _getCellId(a, columnIndex);
      final cellIdB = _getCellId(b, columnIndex);
      
      final cellA = rows[a]![cellIdA];
      final cellB = rows[b]![cellIdB];
      
      // Handle null values
      if (cellA == null && cellB == null) return 0;
      if (cellA == null) return order == SortOrder.ascending ? -1 : 1;
      if (cellB == null) return order == SortOrder.ascending ? 1 : -1;
      
      // Compare values
      final valueA = cellA.value;
      final valueB = cellB.value;
      
      int comparison = 0;
      
      if (valueA is num && valueB is num) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = valueA.toString().compareTo(valueB.toString());
      }
      
      return order == SortOrder.ascending ? comparison : -comparison;
    });
    
    // Rebuild cells map with new row positions
    final newCells = <String, SpreadsheetCell>{};
    
    for (int newRow = 0; newRow < sortedRowIndices.length; newRow++) {
      final oldRow = sortedRowIndices[newRow];
      final rowCells = rows[oldRow]!;
      
      for (var entry in rowCells.entries) {
        final (_, col) = _parseCellId(entry.key);
        final newCellId = _getCellId(newRow, col);
        newCells[newCellId] = entry.value.copyWith(id: newCellId);
      }
    }
    
    return sheet.copyWith(cells: newCells);
  }

  /// Filter sheet by column value
  SpreadsheetSheet filterByColumn(
    SpreadsheetSheet sheet,
    int columnIndex,
    bool Function(dynamic value) predicate,
  ) {
    final newCells = <String, SpreadsheetCell>{};
    int newRowIndex = 0;
    
    // Group cells by row
    final rows = <int, Map<String, SpreadsheetCell>>{};
    
    for (var entry in sheet.cells.entries) {
      final (row, col) = _parseCellId(entry.key);
      if (!rows.containsKey(row)) {
        rows[row] = {};
      }
      rows[row]![entry.key] = entry.value;
    }
    
    // Filter rows
    for (int row = 0; row < sheet.rowCount; row++) {
      final cellId = _getCellId(row, columnIndex);
      final cell = rows[row]?[cellId];
      
      // Apply filter predicate
      if (cell == null || predicate(cell.value)) {
        // Include this row
        final rowCells = rows[row] ?? {};
        
        for (var entry in rowCells.entries) {
          final (_, col) = _parseCellId(entry.key);
          final newCellId = _getCellId(newRowIndex, col);
          newCells[newCellId] = entry.value.copyWith(id: newCellId);
        }
        
        newRowIndex++;
      }
    }
    
    return sheet.copyWith(
      cells: newCells,
      rowCount: newRowIndex,
    );
  }

  /// Filter by text search
  SpreadsheetSheet filterBySearch(
    SpreadsheetSheet sheet,
    String searchTerm, {
    bool caseSensitive = false,
  }) {
    final term = caseSensitive ? searchTerm : searchTerm.toLowerCase();
    final newCells = <String, SpreadsheetCell>{};
    int newRowIndex = 0;
    
    // Group cells by row
    final rows = <int, Map<String, SpreadsheetCell>>{};
    
    for (var entry in sheet.cells.entries) {
      final (row, col) = _parseCellId(entry.key);
      if (!rows.containsKey(row)) {
        rows[row] = {};
      }
      rows[row]![entry.key] = entry.value;
    }
    
    // Filter rows that contain search term in any cell
    for (int row = 0; row < sheet.rowCount; row++) {
      final rowCells = rows[row] ?? {};
      
      bool rowMatches = false;
      for (var cell in rowCells.values) {
        final cellText = caseSensitive 
            ? cell.displayValue 
            : cell.displayValue.toLowerCase();
        
        if (cellText.contains(term)) {
          rowMatches = true;
          break;
        }
      }
      
      if (rowMatches) {
        // Include this row
        for (var entry in rowCells.entries) {
          final (_, col) = _parseCellId(entry.key);
          final newCellId = _getCellId(newRowIndex, col);
          newCells[newCellId] = entry.value.copyWith(id: newCellId);
        }
        
        newRowIndex++;
      }
    }
    
    return sheet.copyWith(
      cells: newCells,
      rowCount: newRowIndex,
    );
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

  /// Helper: Parse cell ID to (row, col)
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

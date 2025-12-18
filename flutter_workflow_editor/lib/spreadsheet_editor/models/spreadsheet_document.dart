/// Spreadsheet document model
import 'package:json_annotation/json_annotation.dart';
import 'spreadsheet_cell.dart';

part 'spreadsheet_document.g.dart';

/// Spreadsheet document containing multiple sheets
@JsonSerializable()
class SpreadsheetDocument {
  final String id;
  final String name;
  final List<SpreadsheetSheet> sheets;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpreadsheetDocument({
    required this.id,
    required this.name,
    required this.sheets,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpreadsheetDocument.fromJson(Map<String, dynamic> json) => _$SpreadsheetDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$SpreadsheetDocumentToJson(this);

  SpreadsheetDocument copyWith({
    String? id,
    String? name,
    List<SpreadsheetSheet>? sheets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpreadsheetDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      sheets: sheets ?? this.sheets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a new empty spreadsheet
  factory SpreadsheetDocument.empty(String name) {
    final now = DateTime.now();
    return SpreadsheetDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      sheets: [SpreadsheetSheet.empty('Sheet1')],
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Individual sheet within a spreadsheet
@JsonSerializable()
class SpreadsheetSheet {
  final String id;
  final String name;
  final int rowCount;
  final int columnCount;
  final Map<String, SpreadsheetCell> cells; // Key is cell ID (e.g., "A1")

  SpreadsheetSheet({
    required this.id,
    required this.name,
    this.rowCount = 100,
    this.columnCount = 26,
    Map<String, SpreadsheetCell>? cells,
  }) : cells = cells ?? {};

  factory SpreadsheetSheet.fromJson(Map<String, dynamic> json) => _$SpreadsheetSheetFromJson(json);
  Map<String, dynamic> toJson() => _$SpreadsheetSheetToJson(this);

  SpreadsheetSheet copyWith({
    String? id,
    String? name,
    int? rowCount,
    int? columnCount,
    Map<String, SpreadsheetCell>? cells,
  }) {
    return SpreadsheetSheet(
      id: id ?? this.id,
      name: name ?? this.name,
      rowCount: rowCount ?? this.rowCount,
      columnCount: columnCount ?? this.columnCount,
      cells: cells ?? this.cells,
    );
  }

  /// Create an empty sheet
  factory SpreadsheetSheet.empty(String name) {
    return SpreadsheetSheet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      rowCount: 100,
      columnCount: 26,
      cells: {},
    );
  }

  /// Get cell by row and column index
  SpreadsheetCell? getCell(int row, int col) {
    final cellId = _getCellId(row, col);
    return cells[cellId];
  }

  /// Set cell value
  SpreadsheetSheet setCell(int row, int col, SpreadsheetCell cell) {
    final newCells = Map<String, SpreadsheetCell>.from(cells);
    newCells[cell.id] = cell;
    return copyWith(cells: newCells);
  }

  /// Get cell ID from row and column (e.g., A1, B5)
  String _getCellId(int row, int col) {
    return '${_getColumnLabel(col)}${row + 1}';
  }

  /// Convert column index to letter (0 -> A, 25 -> Z, 26 -> AA)
  String _getColumnLabel(int col) {
    String label = '';
    while (col >= 0) {
      label = String.fromCharCode(65 + (col % 26)) + label;
      col = (col ~/ 26) - 1;
    }
    return label;
  }

  /// Get cell value by ID
  dynamic getCellValue(String cellId) {
    return cells[cellId]?.value;
  }
}

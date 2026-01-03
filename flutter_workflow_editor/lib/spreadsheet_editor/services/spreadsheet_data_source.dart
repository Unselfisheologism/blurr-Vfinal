/// DataGridSource implementation for Syncfusion DataGrid
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/spreadsheet_document.dart';
import '../models/spreadsheet_cell.dart';

class SpreadsheetDataSource extends DataGridSource {
  SpreadsheetDataSource({
    required this.sheet,
    required this.onCellValueChanged,
  }) {
    _buildDataGridRows();
  }

  final SpreadsheetSheet sheet;
  final Function(int row, int col, dynamic value) onCellValueChanged;

  List<DataGridRow> _dataGridRows = [];
  dynamic _newCellValue;
  final TextEditingController _editingController = TextEditingController();

  @override
  List<DataGridRow> get rows => _dataGridRows;

  /// Build DataGrid rows from sheet data
  void _buildDataGridRows() {
    _dataGridRows = List.generate(sheet.rowCount, (rowIndex) {
      return DataGridRow(
        cells: List.generate(sheet.columnCount, (colIndex) {
          final cellId = _getCellId(rowIndex, colIndex);
          final cell = sheet.cells[cellId];
          
          return DataGridCell(
            columnName: _getColumnLabel(colIndex),
            value: cell?.displayValue ?? '',
          );
        }),
      );
    });
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        final colIndex = _getColumnIndex(cell.columnName);
        final rowIndex = _dataGridRows.indexOf(row);
        final cellId = _getCellId(rowIndex, colIndex);
        final cellData = sheet.cells[cellId];
        
        // Apply cell formatting
        final format = cellData?.format ?? const CellFormat();
        
        return Container(
          alignment: format.alignment ?? Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          color: format.backgroundColorValue,
          child: Text(
            cell.value?.toString() ?? '',
            style: TextStyle(
              fontWeight: format.bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: format.italic ? FontStyle.italic : FontStyle.normal,
              decoration: format.underline ? TextDecoration.underline : TextDecoration.none,
              color: format.textColorValue ?? Colors.black,
              fontSize: format.fontSize ?? 14.0,
              fontFamily: format.fontFamily,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget? buildEditWidget(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final rowIndex = rowColumnIndex.rowIndex;
    final colIndex = _getColumnIndex(column.columnName);
    final cellId = _getCellId(rowIndex, colIndex);
    final cell = sheet.cells[cellId];
    
    final displayText = dataGridRow
        .getCells()
        .firstWhere(
          (c) => c.columnName == column.columnName,
          orElse: () => DataGridCell(columnName: column.columnName, value: ''),
        )
        .value
        ?.toString() ?? '';

    _newCellValue = null;
    _editingController.text = displayText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: cell?.format.alignment ?? Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: _editingController,
        textAlign: _getTextAlignFromAlignment(cell?.format.alignment),
        style: TextStyle(
          fontWeight: cell?.format.bold == true ? FontWeight.bold : FontWeight.normal,
          fontStyle: cell?.format.italic == true ? FontStyle.italic : FontStyle.normal,
          fontSize: cell?.format.fontSize ?? 14.0,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          _newCellValue = value;
        },
        onSubmitted: (value) {
          submitCell();
        },
      ),
    );
  }

  @override
  Future<void> onCellSubmit(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    final rowIndex = rowColumnIndex.rowIndex;
    final colIndex = _getColumnIndex(column.columnName);

    if (_newCellValue != null) {
      // Notify parent about cell value change
      onCellValueChanged(rowIndex, colIndex, _newCellValue);
      
      // Update local data
      _dataGridRows[rowIndex].getCells()[rowColumnIndex.columnIndex] = DataGridCell(
        columnName: column.columnName,
        value: _newCellValue,
      );
    }
  }

  @override
  bool onCellBeginEdit(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) {
    // Allow editing for all cells
    return true;
  }

  @override
  Future<bool> canSubmitCell(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    // Always allow submission
    return true;
  }

  /// Refresh data grid
  void refresh() {
    _buildDataGridRows();
    notifyListeners();
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

  /// Helper: Get column index from label
  int _getColumnIndex(String label) {
    int col = 0;
    for (int i = 0; i < label.length; i++) {
      col = col * 26 + (label.codeUnitAt(i) - 64);
    }
    return col - 1;
  }

  /// Helper: Convert Alignment to TextAlign
  TextAlign _getTextAlignFromAlignment(Alignment? alignment) {
    if (alignment == null) return TextAlign.left;
    if (alignment == Alignment.centerRight) return TextAlign.right;
    if (alignment == Alignment.center) return TextAlign.center;
    if (alignment == Alignment.centerLeft) return TextAlign.left;
    return TextAlign.left;
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }
}

/// PlutoGrid data adapter for converting SpreadsheetSheet to PlutoGrid format
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'models/spreadsheet_document.dart';
import 'models/spreadsheet_cell.dart';

class PlutoGridDataAdapter {
  final SpreadsheetSheet sheet;
  final Function(int row, int col, dynamic value) onCellValueChanged;
  
  PlutoGridDataAdapter({
    required this.sheet,
    required this.onCellValueChanged,
  });

  /// Create PlutoGrid columns from sheet data
  List<PlutoColumn> createColumns() {
    return List.generate(sheet.columnCount, (index) {
      final label = _getColumnLabel(index);
      return PlutoColumn(
        title: label,
        field: label,
        type: PlutoColumnType.text(),
        width: 120,
        enableRowChecked: false,
        enableSorting: true,
        enableEditingMode: true,
        enableDropToResize: true,
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.left,
        enableContextMenu: true,
        enableColumnDrag: false,
        enableRowDrag: false,
        enableAutoEditing: false,
        enableFilterMenuItem: true,
        enableSetColumnsMenuItem: true,
        enableHideColumnMenuItem: true,
        applyFormatterInEditing: false,
        enableAutoEditingOnDoubleTap: true,
      );
    });
  }

  /// Create PlutoGrid rows from sheet data
  List<PlutoRow> createRows() {
    return List.generate(sheet.rowCount, (rowIndex) {
      final Map<String, PlutoCell> cells = {};
      
      for (int colIndex = 0; colIndex < sheet.columnCount; colIndex++) {
        final columnLabel = _getColumnLabel(colIndex);
        final cellId = _getCellId(rowIndex, colIndex);
        final cell = sheet.cells[cellId];
        
        cells[columnLabel] = PlutoCell(
          value: cell?.value ?? '',
        );
      }
      
      return PlutoRow(cells: cells);
    });
  }

  /// Helper: Get cell ID from row and column
  static String _getCellId(int row, int col) {
    return '${_getColumnLabel(col)}${row + 1}';
  }

  /// Helper: Convert column index to letter (A, B, C, ... AA, AB, etc.)
  static String _getColumnLabel(int col) {
    String label = '';
    int tempCol = col;
    while (tempCol >= 0) {
      label = String.fromCharCode(65 + (tempCol % 26)) + label;
      tempCol = (tempCol ~/ 26) - 1;
    }
    return label;
  }

  /// Helper: Get column index from label
  static int _getColumnIndex(String label) {
    int col = 0;
    for (int i = 0; i < label.length; i++) {
      col = col * 26 + (label.codeUnitAt(i) - 64);
    }
    return col - 1;
  }

  /// Create cell renderer with formatting
  PlutoColumnRenderer createCellRenderer(int colIndex) {
    return (PlutoColumnRendererContext ctx) {
      final cellId = _getCellId(ctx.rowIdx, colIndex);
      final cell = sheet.cells[cellId];
      final format = cell?.format ?? const CellFormat();
      
      if (ctx.cell.value == null) {
        return Container();
      }

      return Container(
        alignment: format.alignment ?? Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        color: format.backgroundColorValue,
        child: Text(
          ctx.cell.value.toString(),
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
    };
  }

  /// Handle cell value change from PlutoGrid and propagate to SpreadsheetState
  void handleCellValueChange(PlutoGridOnChangedEvent event) {
    final colIndex = _getColumnIndex(event.column.field);
    final rowIndex = event.rowIdx;
    
    onCellValueChanged(rowIndex, colIndex, event.value);
  }

  /// Apply column renderers for formatting
  void applyColumnRenderers(List<PlutoColumn> columns) {
    for (int i = 0; i < columns.length; i++) {
      columns[i].renderer = createCellRenderer(i);
    }
  }

  /// Handle selection changes from PlutoGrid
  List<String> handleSelectionChange(PlutoGridOnSelectedEvent event) {
    final selectedCellIds = <String>[];
    
    if (event.cell != null && event.rowIdx != null) {
      final colIndex = _getColumnIndex(event.cell!.column.field);
      final cellId = _getCellId(event.rowIdx!, colIndex);
      selectedCellIds.add(cellId);
    }
    
    return selectedCellIds;
  }

  /// PSEUDO METHOD - FOR DOCUMENTATION ONLY
  /// This method is not used because PlutoGrid provides its own selection state
  /// PlutoGrid automatically handles cell selection and provides onSelected event
  /// The method signature shows what would be needed if manual selection were required
  void selectCell(String cellId) {
    // This would require mapping cellId to row/col and calling PlutoGrid API
    // But PlutoGrid manages selection internally, so we use selection events instead
    // final (row, col) = parseCellId(cellId);
    // _gridStateManager.setCurrentCell(_gridStateManager.rows[row].cells[_getColumnLabel(col)], row);
    // _gridStateManager.setKeepFocus(true);
    // _gridStateManager.notifyListeners();
  }
}
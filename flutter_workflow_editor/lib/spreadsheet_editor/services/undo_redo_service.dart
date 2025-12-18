/// Undo/Redo service for spreadsheet operations
import '../models/spreadsheet_document.dart';

/// Action types that can be undone/redone
enum ActionType {
  cellUpdate,
  rowAdd,
  rowDelete,
  columnAdd,
  columnDelete,
  formatChange,
  sheetAdd,
  sheetDelete,
}

/// Represents a single action that can be undone/redone
class SpreadsheetAction {
  final ActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SpreadsheetAction({
    required this.type,
    required this.data,
  }) : timestamp = DateTime.now();
}

/// Manages undo/redo stack for spreadsheet operations
class UndoRedoService {
  final List<SpreadsheetAction> _undoStack = [];
  final List<SpreadsheetAction> _redoStack = [];
  final int maxStackSize;

  UndoRedoService({this.maxStackSize = 50});

  /// Check if undo is available
  bool get canUndo => _undoStack.isNotEmpty;

  /// Check if redo is available
  bool get canRedo => _redoStack.isNotEmpty;

  /// Record a cell update action
  void recordCellUpdate({
    required int row,
    required int col,
    required dynamic oldValue,
    required dynamic newValue,
  }) {
    _addAction(SpreadsheetAction(
      type: ActionType.cellUpdate,
      data: {
        'row': row,
        'col': col,
        'oldValue': oldValue,
        'newValue': newValue,
      },
    ));
  }

  /// Record a row add action
  void recordRowAdd({required int rowIndex}) {
    _addAction(SpreadsheetAction(
      type: ActionType.rowAdd,
      data: {'rowIndex': rowIndex},
    ));
  }

  /// Record a row delete action
  void recordRowDelete({
    required int rowIndex,
    required Map<String, dynamic> rowData,
  }) {
    _addAction(SpreadsheetAction(
      type: ActionType.rowDelete,
      data: {
        'rowIndex': rowIndex,
        'rowData': rowData,
      },
    ));
  }

  /// Record a column add action
  void recordColumnAdd({required int columnIndex}) {
    _addAction(SpreadsheetAction(
      type: ActionType.columnAdd,
      data: {'columnIndex': columnIndex},
    ));
  }

  /// Record a column delete action
  void recordColumnDelete({
    required int columnIndex,
    required Map<String, dynamic> columnData,
  }) {
    _addAction(SpreadsheetAction(
      type: ActionType.columnDelete,
      data: {
        'columnIndex': columnIndex,
        'columnData': columnData,
      },
    ));
  }

  /// Record a format change action
  void recordFormatChange({
    required String cellId,
    required Map<String, dynamic> oldFormat,
    required Map<String, dynamic> newFormat,
  }) {
    _addAction(SpreadsheetAction(
      type: ActionType.formatChange,
      data: {
        'cellId': cellId,
        'oldFormat': oldFormat,
        'newFormat': newFormat,
      },
    ));
  }

  /// Add action to undo stack
  void _addAction(SpreadsheetAction action) {
    _undoStack.add(action);
    
    // Limit stack size
    if (_undoStack.length > maxStackSize) {
      _undoStack.removeAt(0);
    }
    
    // Clear redo stack when new action is performed
    _redoStack.clear();
  }

  /// Get the last action to undo
  SpreadsheetAction? undo() {
    if (!canUndo) return null;
    
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    
    return action;
  }

  /// Get the last action to redo
  SpreadsheetAction? redo() {
    if (!canRedo) return null;
    
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    
    return action;
  }

  /// Clear all history
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Get undo stack size (for debugging/UI)
  int get undoStackSize => _undoStack.length;

  /// Get redo stack size (for debugging/UI)
  int get redoStackSize => _redoStack.length;
}

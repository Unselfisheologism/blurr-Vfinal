/// State management for spreadsheet editor
import 'package:flutter/material.dart';
import '../models/spreadsheet_document.dart';
import '../models/spreadsheet_cell.dart';
import '../services/spreadsheet_storage_service.dart';
import '../services/undo_redo_service.dart';
import '../services/sort_filter_service.dart';

class SpreadsheetState extends ChangeNotifier {
  SpreadsheetDocument? _currentDocument;
  int _currentSheetIndex = 0;
  String? _selectedCellId;
  Set<String> _selectedCellIds = {};
  bool _isLoading = false;
  String? _error;
  bool _isPro = false;
  bool _initialized = false;

  final SpreadsheetStorageService _storageService = SpreadsheetStorageService();
  final UndoRedoService _undoRedoService = UndoRedoService();
  final SortFilterService _sortFilterService = SortFilterService();

  // Getters
  SpreadsheetDocument? get currentDocument => _currentDocument;
  SpreadsheetSheet? get currentSheet =>
      _currentDocument != null && _currentDocument!.sheets.isNotEmpty
          ? _currentDocument!.sheets[_currentSheetIndex]
          : null;
  int get currentSheetIndex => _currentSheetIndex;
  String? get selectedCellId => _selectedCellId;
  Set<String> get selectedCellIds => _selectedCellIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDocument => _currentDocument != null;
  bool get isPro => _isPro;
  bool get isInitialized => _initialized;
  bool get canUndo => _undoRedoService.canUndo;
  bool get canRedo => _undoRedoService.canRedo;
  
  // Pro limits
  int get maxSheets => _isPro ? 999 : 10;
  int get maxRows => _isPro ? 999999 : 1000;
  int get maxColumns => _isPro ? 999 : 26;

  /// Initialize the state
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _storageService.initialize();
      _initialized = true;
    } catch (e) {
      _error = 'Failed to initialize storage: $e';
      notifyListeners();
    }
  }

  /// Create a new spreadsheet
  Future<void> createNewSpreadsheet(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentDocument = SpreadsheetDocument.empty(name);
      _currentSheetIndex = 0;
      await _storageService.saveDocument(_currentDocument!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create spreadsheet: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load spreadsheet by ID
  Future<void> loadSpreadsheet(String documentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentDocument = await _storageService.loadDocument(documentId);
      _currentSheetIndex = 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load spreadsheet: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save current spreadsheet
  Future<void> saveSpreadsheet() async {
    if (_currentDocument == null) return;

    try {
      await _storageService.saveDocument(_currentDocument!);
    } catch (e) {
      _error = 'Failed to save spreadsheet: $e';
      notifyListeners();
    }
  }

  /// Set Pro status
  void setProStatus(bool isPro) {
    _isPro = isPro;
    notifyListeners();
  }

  /// Update cell value
  void updateCell(int row, int col, dynamic value, {CellDataType? dataType}) {
    if (currentSheet == null) return;

    final cellId = _getCellId(row, col);
    final existingCell = currentSheet!.cells[cellId];
    
    // Record for undo
    _undoRedoService.recordCellUpdate(
      row: row,
      col: col,
      oldValue: existingCell?.value,
      newValue: value,
    );
    
    final updatedCell = SpreadsheetCell(
      id: cellId,
      value: value,
      dataType: dataType ?? existingCell?.dataType ?? CellDataType.text,
      format: existingCell?.format ?? const CellFormat(),
    );

    final updatedSheet = currentSheet!.setCell(row, col, updatedCell);
    _updateCurrentSheet(updatedSheet);
  }

  /// Update cell formatting
  void updateCellFormat(String cellId, CellFormat format) {
    if (currentSheet == null) return;

    final cell = currentSheet!.cells[cellId];
    if (cell == null) return;

    final updatedCell = cell.copyWith(format: format);
    final (row, col) = _parseCellId(cellId);
    final updatedSheet = currentSheet!.setCell(row, col, updatedCell);
    _updateCurrentSheet(updatedSheet);
  }

  /// Apply formatting to selected cells
  void applyFormatToSelectedCells(CellFormat format) {
    if (currentSheet == null || _selectedCellIds.isEmpty) return;

    var updatedSheet = currentSheet!;
    for (final cellId in _selectedCellIds) {
      final cell = updatedSheet.cells[cellId];
      final updatedCell = (cell ?? SpreadsheetCell.empty(cellId)).copyWith(
        format: format,
      );
      final (row, col) = _parseCellId(cellId);
      updatedSheet = updatedSheet.setCell(row, col, updatedCell);
    }
    _updateCurrentSheet(updatedSheet);
  }

  /// Select cell
  void selectCell(String cellId) {
    _selectedCellId = cellId;
    _selectedCellIds = {cellId};
    notifyListeners();
  }

  /// Add cell to selection
  void addCellToSelection(String cellId) {
    _selectedCellIds.add(cellId);
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedCellId = null;
    _selectedCellIds.clear();
    notifyListeners();
  }

  /// Add new row
  void addRow() {
    if (currentSheet == null) return;
    
    // Check Pro limits
    if (currentSheet!.rowCount >= maxRows) {
      _error = 'Row limit reached. ${_isPro ? '' : 'Upgrade to Pro for unlimited rows.'}';
      notifyListeners();
      return;
    }
    
    _undoRedoService.recordRowAdd(rowIndex: currentSheet!.rowCount);
    
    final updatedSheet = currentSheet!.copyWith(
      rowCount: currentSheet!.rowCount + 1,
    );
    _updateCurrentSheet(updatedSheet);
  }

  /// Add new column
  void addColumn() {
    if (currentSheet == null) return;
    
    // Check Pro limits
    if (currentSheet!.columnCount >= maxColumns) {
      _error = 'Column limit reached. ${_isPro ? '' : 'Upgrade to Pro for unlimited columns.'}';
      notifyListeners();
      return;
    }
    
    _undoRedoService.recordColumnAdd(columnIndex: currentSheet!.columnCount);
    
    final updatedSheet = currentSheet!.copyWith(
      columnCount: currentSheet!.columnCount + 1,
    );
    _updateCurrentSheet(updatedSheet);
  }

  /// Delete row
  void deleteRow(int rowIndex) {
    if (currentSheet == null) return;

    // Remove all cells in this row and shift rows below up
    final newCells = <String, SpreadsheetCell>{};
    for (var entry in currentSheet!.cells.entries) {
      final (row, col) = _parseCellId(entry.key);
      if (row < rowIndex) {
        newCells[entry.key] = entry.value;
      } else if (row > rowIndex) {
        // Shift up
        final newCellId = _getCellId(row - 1, col);
        newCells[newCellId] = entry.value.copyWith(id: newCellId);
      }
    }

    final updatedSheet = currentSheet!.copyWith(
      cells: newCells,
      rowCount: currentSheet!.rowCount - 1,
    );
    _updateCurrentSheet(updatedSheet);
  }

  /// Delete column
  void deleteColumn(int colIndex) {
    if (currentSheet == null) return;

    // Remove all cells in this column and shift columns right to left
    final newCells = <String, SpreadsheetCell>{};
    for (var entry in currentSheet!.cells.entries) {
      final (row, col) = _parseCellId(entry.key);
      if (col < colIndex) {
        newCells[entry.key] = entry.value;
      } else if (col > colIndex) {
        // Shift left
        final newCellId = _getCellId(row, col - 1);
        newCells[newCellId] = entry.value.copyWith(id: newCellId);
      }
    }

    final updatedSheet = currentSheet!.copyWith(
      cells: newCells,
      columnCount: currentSheet!.columnCount - 1,
    );
    _updateCurrentSheet(updatedSheet);
  }

  /// Switch to sheet by index
  void switchToSheet(int index) {
    if (_currentDocument == null || index < 0 || index >= _currentDocument!.sheets.length) {
      return;
    }
    _currentSheetIndex = index;
    notifyListeners();
  }

  /// Add new sheet
  void addSheet(String name) {
    if (_currentDocument == null) return;

    // Check Pro limits
    if (_currentDocument!.sheets.length >= maxSheets) {
      _error = 'Sheet limit reached. ${_isPro ? '' : 'Upgrade to Pro for unlimited sheets.'}';
      notifyListeners();
      return;
    }

    final newSheet = SpreadsheetSheet.empty(name);
    final updatedSheets = List<SpreadsheetSheet>.from(_currentDocument!.sheets)..add(newSheet);
    _currentDocument = _currentDocument!.copyWith(
      sheets: updatedSheets,
      updatedAt: DateTime.now(),
    );
    _currentSheetIndex = updatedSheets.length - 1;
    notifyListeners();
  }
  
  /// Undo last action
  void undo() {
    final action = _undoRedoService.undo();
    if (action != null) {
      _applyUndoAction(action);
    }
  }
  
  /// Redo last undone action
  void redo() {
    final action = _undoRedoService.redo();
    if (action != null) {
      _applyRedoAction(action);
    }
  }
  
  /// Apply undo action
  void _applyUndoAction(SpreadsheetAction action) {
    switch (action.type) {
      case ActionType.cellUpdate:
        final row = action.data['row'] as int;
        final col = action.data['col'] as int;
        final oldValue = action.data['oldValue'];
        updateCell(row, col, oldValue);
        break;
      case ActionType.rowAdd:
        final rowIndex = action.data['rowIndex'] as int;
        deleteRow(rowIndex);
        break;
      case ActionType.columnAdd:
        final colIndex = action.data['columnIndex'] as int;
        deleteColumn(colIndex);
        break;
      default:
        break;
    }
  }
  
  /// Apply redo action
  void _applyRedoAction(SpreadsheetAction action) {
    switch (action.type) {
      case ActionType.cellUpdate:
        final row = action.data['row'] as int;
        final col = action.data['col'] as int;
        final newValue = action.data['newValue'];
        updateCell(row, col, newValue);
        break;
      case ActionType.rowAdd:
        addRow();
        break;
      case ActionType.columnAdd:
        addColumn();
        break;
      default:
        break;
    }
  }
  
  /// Sort current sheet by column
  void sortByColumn(int columnIndex, {SortOrder order = SortOrder.ascending}) {
    if (currentSheet == null) return;
    final sortedSheet = _sortFilterService.sortByColumn(currentSheet!, columnIndex, order: order);
    _updateCurrentSheet(sortedSheet);
  }
  
  /// Filter current sheet by search term
  void filterBySearch(String searchTerm) {
    if (currentSheet == null) return;
    final filteredSheet = _sortFilterService.filterBySearch(currentSheet!, searchTerm);
    _updateCurrentSheet(filteredSheet);
  }

  /// Update current sheet
  void _updateCurrentSheet(SpreadsheetSheet updatedSheet) {
    if (_currentDocument == null) return;

    final updatedSheets = List<SpreadsheetSheet>.from(_currentDocument!.sheets);
    updatedSheets[_currentSheetIndex] = updatedSheet;
    _currentDocument = _currentDocument!.copyWith(
      sheets: updatedSheets,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Helper: Get cell ID from row and column
  String _getCellId(int row, int col) {
    return '${_getColumnLabel(col)}${row + 1}';
  }

  /// Helper: Convert column index to letter
  String _getColumnLabel(int col) {
    String label = '';
    while (col >= 0) {
      label = String.fromCharCode(65 + (col % 26)) + label;
      col = (col ~/ 26) - 1;
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
    
    // Convert column label to index (A=0, Z=25, AA=26)
    int col = 0;
    for (int i = 0; i < colLabel.length; i++) {
      col = col * 26 + (colLabel.codeUnitAt(i) - 64);
    }
    col -= 1;
    
    return (row, col);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

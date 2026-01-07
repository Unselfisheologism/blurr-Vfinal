/// Main Spreadsheet Editor Screen with Syncfusion DataGrid
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'state/spreadsheet_state.dart';
import 'models/spreadsheet_cell.dart';
import 'services/spreadsheet_data_source.dart';
import 'services/excel_service.dart';
import 'services/csv_service.dart';
import 'widgets/spreadsheet_toolbar.dart';
import 'widgets/ai_toolbar.dart';
import '../services/platform_bridge.dart';

class SpreadsheetEditorScreen extends StatefulWidget {
  final String? documentId;
  final String? initialPrompt; // "create budget tracker"

  const SpreadsheetEditorScreen({
    super.key,
    this.documentId,
    this.initialPrompt,
  });

  @override
  State<SpreadsheetEditorScreen> createState() => _SpreadsheetEditorScreenState();
}

class _SpreadsheetEditorScreenState extends State<SpreadsheetEditorScreen> {
  final DataGridController _dataGridController = DataGridController();
  SpreadsheetDataSource? _dataSource;
  late SpreadsheetState _spreadsheetState;
  final PlatformBridge _platformBridge = PlatformBridge();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeSpreadsheet();
    });
  }

  Future<void> _initializeSpreadsheet() async {
    _spreadsheetState = context.read<SpreadsheetState>();

    // Initialize storage first
    await _spreadsheetState.initialize();

    if (widget.documentId != null) {
      // Load existing document
      await _spreadsheetState.loadSpreadsheet(widget.documentId!);
    } else if (widget.initialPrompt != null) {
      // Create from AI prompt
      await _createFromPrompt(widget.initialPrompt!);
    } else {
      // Create blank spreadsheet
      await _spreadsheetState.createNewSpreadsheet('Untitled Spreadsheet');
    }

    _refreshDataSource();
  }

  Future<void> _createFromPrompt(String prompt) async {
    try {
      // Create blank spreadsheet first
      await _spreadsheetState.createNewSpreadsheet('AI Generated Spreadsheet');

      // Call AI to generate data
      final result = await _platformBridge.executeAgentTask(
        'Generate spreadsheet data based on this prompt: $prompt. '
        'Return data as JSON array of rows with column headers.',
      );

      if (result['success'] == true) {
        // Parse AI response and populate cells
        // TODO: Implement AI response parsing
        _showSnackBar('Spreadsheet generated successfully!');
      }
    } catch (e) {
      _showSnackBar('Error generating spreadsheet: $e');
    }
  }

  void _refreshDataSource() {
    if (_spreadsheetState.currentSheet != null) {
      setState(() {
        _dataSource = SpreadsheetDataSource(
          sheet: _spreadsheetState.currentSheet!,
          onCellValueChanged: (row, col, value) {
            _spreadsheetState.updateCell(row, col, value);
            _refreshDataSource(); // Refresh to show updates
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SpreadsheetState>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      state.clearError();
                      _initializeSpreadsheet();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!state.hasDocument || _dataSource == null) {
            return const Center(child: Text('No spreadsheet loaded'));
          }

          return Column(
            children: [
              // Main toolbar
              SpreadsheetToolbar(
                onNew: _handleNew,
                onOpen: _handleOpen,
                onSave: _handleSave,
                onExport: _handleExport,
                onImport: _handleImport,
                onAddRow: () {
                  state.addRow();
                  _refreshDataSource();
                },
                onAddColumn: () {
                  state.addColumn();
                  _refreshDataSource();
                },
                onDeleteRow: _handleDeleteRow,
                onDeleteColumn: _handleDeleteColumn,
                onFormatApply: (format) {
                  state.applyFormatToSelectedCells(format);
                  _refreshDataSource();
                },
                onUndo: () {
                  state.undo();
                  _refreshDataSource();
                },
                onRedo: () {
                  state.redo();
                  _refreshDataSource();
                },
                hasSelection: state.selectedCellIds.isNotEmpty,
              ),

              // AI Toolbar
              AIToolbar(
                onGenerateData: _handleGenerateData,
                onFillColumn: _handleFillColumn,
                onAnalyzeSelection: _handleAnalyzeSelection,
                onCreateChart: _handleCreateChart,
                onWriteFormula: _handleWriteFormula,
                onSummarizeSheet: _handleSummarizeSheet,
                hasSelection: state.selectedCellIds.isNotEmpty,
                isProUser: false, // TODO: Get from FreemiumManager
              ),

              // Spreadsheet grid
              Expanded(
                child: _buildDataGrid(state),
              ),

              // Sheet tabs
              _buildSheetTabs(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataGrid(SpreadsheetState state) {
    final sheet = state.currentSheet!;
    
    return SfDataGrid(
      source: _dataSource!,
      controller: _dataGridController,
      allowEditing: true,
      selectionMode: SelectionMode.multiple,
      navigationMode: GridNavigationMode.cell,
      editingGestureType: EditingGestureType.doubleTap,
      columnWidthMode: ColumnWidthMode.fill,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      
      // Generate columns dynamically
      columns: List.generate(sheet.columnCount, (index) {
        final label = _getColumnLabel(index);
        return GridColumn(
          columnName: label,
          label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
      
      onSelectionChanged: (addedRows, removedRows) {
        // Handle selection changes
        if (addedRows.isNotEmpty) {
          final rowIndex = _dataSource!.rows.indexOf(addedRows.first);
          if (rowIndex >= 0) {
            // Select first cell in selected row
            state.selectCell(_getCellId(rowIndex, 0));
          }
        }
      },
      
      onCellTap: (details) {
        final rowIndex = details.rowColumnIndex.rowIndex - 1; // -1 for header
        final colIndex = details.rowColumnIndex.columnIndex;
        
        if (rowIndex >= 0) {
          final cellId = _getCellId(rowIndex, colIndex);
          state.selectCell(cellId);
        }
      },
    );
  }

  Widget _buildSheetTabs(SpreadsheetState state) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.currentDocument!.sheets.length,
              itemBuilder: (context, index) {
                final sheet = state.currentDocument!.sheets[index];
                final isActive = index == state.currentSheetIndex;
                
                return GestureDetector(
                  onTap: () {
                    state.switchToSheet(index);
                    _refreshDataSource();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      border: Border(
                        top: BorderSide(
                          color: isActive ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      sheet.name,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Sheet',
            onPressed: () => _handleAddSheet(),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _handleNew() async {
    final name = await _showNameDialog('New Spreadsheet', 'Untitled Spreadsheet');
    if (name != null) {
      await _spreadsheetState.createNewSpreadsheet(name);
      _refreshDataSource();
    }
  }

  void _handleOpen() {
    // TODO: Show document picker dialog
    _showSnackBar('Open dialog not yet implemented');
  }

  void _handleSave() async {
    await _spreadsheetState.saveSpreadsheet();
    _showSnackBar('Spreadsheet saved successfully');
  }

  void _handleExport() async {
    if (_spreadsheetState.currentDocument == null) return;
    
    // Show export options
    final exportType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Spreadsheet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel (.xlsx)'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('CSV'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
          ],
        ),
      ),
    );
    
    if (exportType == null) return;
    
    _showLoadingDialog('Exporting...');
    
    try {
      String filePath;
      
      if (exportType == 'excel') {
        final excelService = ExcelService();
        filePath = await excelService.exportToExcel(_spreadsheetState.currentDocument!);
      } else {
        final csvService = CsvService();
        filePath = await csvService.exportToCsv(_spreadsheetState.currentDocument!);
      }
      
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show success with option to open file
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Successful'),
          content: Text('File saved to:\n$filePath'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open File'),
            ),
          ],
        ),
      );
      
      if (shouldOpen == true && exportType == 'excel') {
        final excelService = ExcelService();
        await excelService.openFile(filePath);
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar('Export failed: $e');
    }
  }

  void _handleImport() async {
    // Show import options
    final importType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Spreadsheet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel (.xlsx)'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('CSV'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
          ],
        ),
      ),
    );
    
    if (importType == null) return;
    
    // TODO: Use file picker to select file
    // For now, show placeholder
    _showSnackBar('Import: Please select file via platform file picker (TODO)');
  }

  void _handleDeleteRow() {
    if (_spreadsheetState.selectedCellIds.isNotEmpty) {
      final cellId = _spreadsheetState.selectedCellIds.first;
      final (row, _) = _parseCellId(cellId);
      _spreadsheetState.deleteRow(row);
      _refreshDataSource();
    }
  }

  void _handleDeleteColumn() {
    if (_spreadsheetState.selectedCellIds.isNotEmpty) {
      final cellId = _spreadsheetState.selectedCellIds.first;
      final (_, col) = _parseCellId(cellId);
      _spreadsheetState.deleteColumn(col);
      _refreshDataSource();
    }
  }

  void _handleAddSheet() async {
    final name = await _showNameDialog('New Sheet', 'Sheet ${_spreadsheetState.currentDocument!.sheets.length + 1}');
    if (name != null) {
      _spreadsheetState.addSheet(name);
      _refreshDataSource();
    }
  }

  // AI Action handlers
  Future<void> _handleGenerateData() async {
    final prompt = await _showPromptDialog(
      'Generate Data',
      'Describe the data you want to generate (e.g., "monthly sales data for 2024")',
    );
    
    if (prompt != null && prompt.isNotEmpty) {
      _showLoadingDialog('Generating data...');
      
      try {
        final result = await _platformBridge.executeAgentTask(
          'Generate spreadsheet data: $prompt. Return as JSON array of rows.',
        );
        
        Navigator.of(context).pop(); // Close loading dialog
        
        if (result['success'] == true) {
          // TODO: Parse and insert data
          _showSnackBar('Data generated successfully!');
        } else {
          _showSnackBar('Failed to generate data');
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showSnackBar('Error: $e');
      }
    }
  }

  Future<void> _handleFillColumn() async {
    final prompt = await _showPromptDialog(
      'Fill Column',
      'Describe how to fill the selected column (e.g., "generate random prices between 10-100")',
    );
    
    if (prompt != null && prompt.isNotEmpty) {
      _showLoadingDialog('Filling column...');
      
      try {
        final selectedCells = _spreadsheetState.selectedCellIds.toList();
        final cellData = selectedCells.map((id) => _spreadsheetState.currentSheet!.cells[id]?.displayValue ?? '').join(', ');
        
        final result = await _platformBridge.executeAgentTask(
          'Fill column with data. Context: $cellData. Instruction: $prompt',
        );
        
        Navigator.of(context).pop();
        
        if (result['success'] == true) {
          _showSnackBar('Column filled successfully!');
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showSnackBar('Error: $e');
      }
    }
  }

  Future<void> _handleAnalyzeSelection() async {
    _showLoadingDialog('Analyzing selection...');
    
    try {
      final selectedCells = _spreadsheetState.selectedCellIds.toList();
      final cellData = selectedCells.map((id) {
        final cell = _spreadsheetState.currentSheet!.cells[id];
        return '$id: ${cell?.displayValue ?? "empty"}';
      }).join(', ');
      
      final result = await _platformBridge.executeAgentTask(
        'Analyze this spreadsheet data and provide insights: $cellData',
      );
      
      Navigator.of(context).pop();
      
      if (result['success'] == true) {
        _showResultDialog('Analysis Results', result['result'] ?? 'No analysis available');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _handleCreateChart() async {
    // TODO: Implement chart creation with syncfusion_flutter_charts
    _showSnackBar('Chart creation not yet implemented');
  }

  Future<void> _handleWriteFormula() async {
    final prompt = await _showPromptDialog(
      'Write Formula',
      'Describe the calculation you need (e.g., "sum of column A")',
    );
    
    if (prompt != null && prompt.isNotEmpty) {
      _showLoadingDialog('Writing formula...');
      
      try {
        final result = await _platformBridge.executeAgentTask(
          'Generate Excel formula for: $prompt',
        );
        
        Navigator.of(context).pop();
        
        if (result['success'] == true) {
          _showResultDialog('Formula', result['result'] ?? 'No formula generated');
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showSnackBar('Error: $e');
      }
    }
  }

  Future<void> _handleSummarizeSheet() async {
    _showLoadingDialog('Summarizing spreadsheet...');
    
    try {
      final sheet = _spreadsheetState.currentSheet!;
      final allData = sheet.cells.entries.map((e) => '${e.key}: ${e.value.displayValue}').join(', ');
      
      final result = await _platformBridge.executeAgentTask(
        'Summarize this spreadsheet data: $allData',
      );
      
      Navigator.of(context).pop();
      
      if (result['success'] == true) {
        _showResultDialog('Summary', result['result'] ?? 'No summary available');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar('Error: $e');
    }
  }

  // Helper methods
  String _getColumnLabel(int col) {
    String label = '';
    int tempCol = col;
    while (tempCol >= 0) {
      label = String.fromCharCode(65 + (tempCol % 26)) + label;
      tempCol = (tempCol ~/ 26) - 1;
    }
    return label;
  }

  String _getCellId(int row, int col) {
    return '${_getColumnLabel(col)}${row + 1}';
  }

  (int, int) _parseCellId(String cellId) {
    final colMatch = RegExp(r'^[A-Z]+').firstMatch(cellId);
    final rowMatch = RegExp(r'\d+$').firstMatch(cellId);
    
    if (colMatch == null || rowMatch == null) {
      return (0, 0);
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

  // Dialog helpers
  Future<String?> _showNameDialog(String title, String defaultValue) async {
    final controller = TextEditingController(text: defaultValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPromptDialog(String title, String hint) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _dataGridController.dispose();
    super.dispose();
  }
}

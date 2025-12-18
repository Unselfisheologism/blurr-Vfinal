/// Workflow toolbar with actions
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../services/workflow_execution_engine.dart';

class WorkflowToolbar extends StatelessWidget {
  final VoidCallback onTogglePalette;
  final VoidCallback onToggleInspector;
  final VoidCallback onToggleExecution;
  final bool showPalette;
  final bool showInspector;
  final bool showExecutionPanel;
  
  const WorkflowToolbar({
    Key? key,
    required this.onTogglePalette,
    required this.onToggleInspector,
    required this.onToggleExecution,
    required this.showPalette,
    required this.showInspector,
    required this.showExecutionPanel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Consumer<WorkflowState>(
        builder: (context, state, _) {
          return Row(
            children: [
              const SizedBox(width: 16),
              
              // Workflow name
              Expanded(
                child: Text(
                  state.currentWorkflow?.name ?? 'Untitled Workflow',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Actions
              IconButton(
                icon: Icon(showPalette ? Icons.widgets : Icons.widgets_outlined),
                tooltip: 'Toggle Palette',
                onPressed: onTogglePalette,
              ),
              
              IconButton(
                icon: Icon(showInspector ? Icons.info : Icons.info_outline),
                tooltip: 'Toggle Inspector',
                onPressed: onToggleInspector,
              ),
              
              const VerticalDivider(),
              
              // Undo/Redo
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: state.canUndo ? state.undo : null,
              ),
              
              IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Redo',
                onPressed: state.canRedo ? state.redo : null,
              ),
              
              const VerticalDivider(),
              
              // Save
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save',
                onPressed: () => _saveWorkflow(context),
              ),
              
              // Export
              IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Export',
                onPressed: () => _exportWorkflow(context),
              ),
              
              // Import
              IconButton(
                icon: const Icon(Icons.file_upload),
                tooltip: 'Import',
                onPressed: () => _importWorkflow(context),
              ),
              
              const VerticalDivider(),
              
              // Run
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run'),
                onPressed: () => _runWorkflow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              
              // Stop
              IconButton(
                icon: const Icon(Icons.stop),
                tooltip: 'Stop',
                onPressed: state.isExecuting ? () => _stopWorkflow(context) : null,
              ),
              
              // Execution panel toggle
              IconButton(
                icon: Icon(showExecutionPanel ? Icons.terminal : Icons.code),
                tooltip: 'Toggle Execution Panel',
                onPressed: onToggleExecution,
              ),
              
              const VerticalDivider(),
              
              // More menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'new', child: Text('New Workflow')),
                  const PopupMenuItem(value: 'open', child: Text('Open...')),
                  const PopupMenuItem(value: 'save_as', child: Text('Save As...')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'templates', child: Text('Templates...')),
                  const PopupMenuItem(value: 'schedule', child: Text('Schedule... (Pro)')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'settings', child: Text('Settings')),
                  const PopupMenuItem(value: 'help', child: Text('Help')),
                ],
              ),
              
              const SizedBox(width: 8),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _saveWorkflow(BuildContext context) async {
    final state = context.read<WorkflowState>();
    await state.saveWorkflow();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workflow saved')),
      );
    }
  }
  
  Future<void> _exportWorkflow(BuildContext context) async {
    final state = context.read<WorkflowState>();
    await state.exportWorkflow();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workflow exported')),
      );
    }
  }
  
  Future<void> _importWorkflow(BuildContext context) async {
    final state = context.read<WorkflowState>();
    await state.importWorkflow();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workflow imported')),
      );
    }
  }
  
  Future<void> _runWorkflow(BuildContext context) async {
    final state = context.read<WorkflowState>();
    await state.executeWorkflow();
  }
  
  void _stopWorkflow(BuildContext context) {
    final state = context.read<WorkflowState>();
    state.stopExecution();
  }
  
  void _handleMenuAction(BuildContext context, String action) {
    final state = context.read<WorkflowState>();
    
    switch (action) {
      case 'new':
        state.createNewWorkflow();
        break;
      case 'open':
        _showOpenDialog(context);
        break;
      case 'save_as':
        _showSaveAsDialog(context);
        break;
      case 'templates':
        _showTemplatesDialog(context);
        break;
      case 'schedule':
        _showScheduleDialog(context);
        break;
      case 'settings':
        _showSettingsDialog(context);
        break;
      case 'help':
        _showHelpDialog(context);
        break;
    }
  }
  
  void _showOpenDialog(BuildContext context) {
    // TODO: Implement
  }
  
  void _showSaveAsDialog(BuildContext context) {
    // TODO: Implement
  }
  
  void _showTemplatesDialog(BuildContext context) {
    // TODO: Implement
  }
  
  void _showScheduleDialog(BuildContext context) {
    // TODO: Implement
  }
  
  void _showSettingsDialog(BuildContext context) {
    // TODO: Implement
  }
  
  void _showHelpDialog(BuildContext context) {
    // TODO: Implement
  }
}

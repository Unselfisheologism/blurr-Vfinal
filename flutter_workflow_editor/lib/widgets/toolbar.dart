/// Toolbar widget for workflow actions
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';

class WorkflowToolbar extends StatelessWidget {
  final VoidCallback onTogglePalette;
  final VoidCallback onToggleInspector;
  final VoidCallback onToggleExecution;
  final bool showPalette;
  final bool showInspector;
  final bool showExecutionPanel;

  const WorkflowToolbar({
    super.key,
    required this.onTogglePalette,
    required this.onToggleInspector,
    required this.onToggleExecution,
    required this.showPalette,
    required this.showInspector,
    required this.showExecutionPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              // Workflow name
              Expanded(
                child: Text(
                  workflowState.currentWorkflow?.name ?? 'Workflow',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Actions
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: workflowState.canUndo
                    ? () => workflowState.undo()
                    : null,
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: workflowState.canRedo
                    ? () => workflowState.redo()
                    : null,
                tooltip: 'Redo',
              ),

              const VerticalDivider(),

              // Execute
              ElevatedButton.icon(
                onPressed: workflowState.isExecuting
                    ? null
                    : () => workflowState.executeWorkflow(),
                icon: workflowState.isExecuting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(workflowState.isExecuting ? 'Running...' : 'Execute'),
              ),

              const SizedBox(width: 8),

              // Save
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => workflowState.saveWorkflow(),
                tooltip: 'Save',
              ),

              // Export
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _showExportDialog(context),
                tooltip: 'Export',
              ),

              const VerticalDivider(),

              // Toggle panels
              IconButton(
                icon: Icon(showPalette ? Icons.menu_open : Icons.menu),
                onPressed: onTogglePalette,
                tooltip: 'Toggle Palette',
              ),
              IconButton(
                icon: Icon(showInspector ? Icons.info : Icons.info_outline),
                onPressed: onToggleInspector,
                tooltip: 'Toggle Inspector',
              ),
              IconButton(
                icon: Icon(showExecutionPanel ? Icons.terminal : Icons.terminal_outlined),
                onPressed: onToggleExecution,
                tooltip: 'Toggle Execution Panel',
              ),

              const SizedBox(width: 8),

              // Settings
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSettings(context),
                tooltip: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Workflow'),
        content: const Text('Export workflow as JSON'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Export workflow
              Navigator.pop(context);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workflow Settings'),
        content: const Text('Workflow settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

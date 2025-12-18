/// Execution panel for showing logs and results
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';

class ExecutionPanel extends StatelessWidget {
  const ExecutionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.terminal, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Execution Logs',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (workflowState.executionLogs.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_all, size: 20),
                      onPressed: () => workflowState.clearExecutionResults(),
                      tooltip: 'Clear logs',
                    ),
                ],
              ),
            ),

            // Logs
            Expanded(
              child: workflowState.executionLogs.isEmpty
                  ? Center(
                      child: Text(
                        'No execution logs',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: workflowState.executionLogs.length,
                      itemBuilder: (context, index) {
                        final log = workflowState.executionLogs[index];
                        return _buildLogEntry(log);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogEntry(String log) {
    Color color = Colors.grey;
    IconData icon = Icons.info_outline;

    if (log.startsWith('ERROR')) {
      color = Colors.red;
      icon = Icons.error;
    } else if (log.startsWith('Executing')) {
      color = Colors.blue;
      icon = Icons.play_arrow;
    } else if (log.contains('completed')) {
      color = Colors.green;
      icon = Icons.check_circle;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              log,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

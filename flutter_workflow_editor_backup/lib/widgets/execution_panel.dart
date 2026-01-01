/// Execution panel showing logs and output
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../services/workflow_execution_engine.dart';
import 'package:intl/intl.dart';

class ExecutionPanel extends StatefulWidget {
  const ExecutionPanel({super.key});
  
  @override
  State<ExecutionPanel> createState() => _ExecutionPanelState();
}

class _ExecutionPanelState extends State<ExecutionPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _logsScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(child: _buildTabView()),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Consumer<WorkflowState>(
      builder: (context, state, _) {
        final executionState = state.executionEngine?.state ?? ExecutionState.idle;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              Icon(
                _getStateIcon(executionState),
                color: _getStateColor(executionState),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getStateText(executionState),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStateColor(executionState),
                ),
              ),
              const Spacer(),
              if (state.executionEngine?.context != null) ...[
                Text(
                  'Duration: ${_formatDuration(state.executionEngine!.context!.duration)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
              ],
              IconButton(
                icon: const Icon(Icons.clear_all, size: 20),
                tooltip: 'Clear Logs',
                onPressed: state.clearExecutionLogs,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Logs', icon: Icon(Icons.list_alt, size: 18)),
        Tab(text: 'Output', icon: Icon(Icons.output, size: 18)),
        Tab(text: 'Variables', icon: Icon(Icons.data_object, size: 18)),
      ],
    );
  }
  
  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildLogsTab(),
        _buildOutputTab(),
        _buildVariablesTab(),
      ],
    );
  }
  
  Widget _buildLogsTab() {
    return Consumer<WorkflowState>(
      builder: (context, state, _) {
        final logs = state.executionEngine?.context?.logs ?? [];
        
        if (logs.isEmpty) {
          return _buildEmptyState('No logs yet', Icons.list_alt);
        }
        
        // Auto-scroll to bottom when new logs arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logsScrollController.hasClients) {
            _logsScrollController.animateTo(
              _logsScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
        return ListView.builder(
          controller: _logsScrollController,
          padding: const EdgeInsets.all(8),
          itemCount: logs.length,
          itemBuilder: (context, index) => _buildLogEntry(logs[index]),
        );
      },
    );
  }
  
  Widget _buildLogEntry(ExecutionLog log) {
    final timeFormat = DateFormat('HH:mm:ss.SSS');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      color: _getLogLevelColor(log.level).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getLogLevelIcon(log.level),
              size: 16,
              color: _getLogLevelColor(log.level),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeFormat.format(log.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (log.nodeName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.nodeName,
                            style: const TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.message,
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (log.data != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.data.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOutputTab() {
    return Consumer<WorkflowState>(
      builder: (context, state, _) {
        final outputs = state.executionEngine?.context?.nodeOutputs ?? {};
        
        if (outputs.isEmpty) {
          return _buildEmptyState('No output yet', Icons.output);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: outputs.length,
          itemBuilder: (context, index) {
            final entry = outputs.entries.elementAt(index);
            return _buildOutputEntry(entry.key, entry.value);
          },
        );
      },
    );
  }
  
  Widget _buildOutputEntry(String nodeId, dynamic output) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          nodeId,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.black.withOpacity(0.2),
            child: SelectableText(
              _formatOutput(output),
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVariablesTab() {
    return Consumer<WorkflowState>(
      builder: (context, state, _) {
        final variables = state.executionEngine?.context?.variables ?? {};
        
        if (variables.isEmpty) {
          return _buildEmptyState('No variables yet', Icons.data_object);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: variables.length,
          itemBuilder: (context, index) {
            final entry = variables.entries.elementAt(index);
            return _buildVariableEntry(entry.key, entry.value);
          },
        );
      },
    );
  }
  
  Widget _buildVariableEntry(String key, dynamic value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          key,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatOutput(value),
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () {
            // TODO: Copy to clipboard
          },
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
  
  IconData _getStateIcon(ExecutionState state) {
    switch (state) {
      case ExecutionState.idle:
        return Icons.power_settings_new;
      case ExecutionState.running:
        return Icons.play_circle;
      case ExecutionState.paused:
        return Icons.pause_circle;
      case ExecutionState.completed:
        return Icons.check_circle;
      case ExecutionState.failed:
        return Icons.error;
      case ExecutionState.cancelled:
        return Icons.cancel;
    }
  }
  
  Color _getStateColor(ExecutionState state) {
    switch (state) {
      case ExecutionState.idle:
        return Colors.grey;
      case ExecutionState.running:
        return Colors.blue;
      case ExecutionState.paused:
        return Colors.orange;
      case ExecutionState.completed:
        return Colors.green;
      case ExecutionState.failed:
        return Colors.red;
      case ExecutionState.cancelled:
        return Colors.orange;
    }
  }
  
  String _getStateText(ExecutionState state) {
    switch (state) {
      case ExecutionState.idle:
        return 'Ready';
      case ExecutionState.running:
        return 'Running...';
      case ExecutionState.paused:
        return 'Paused';
      case ExecutionState.completed:
        return 'Completed';
      case ExecutionState.failed:
        return 'Failed';
      case ExecutionState.cancelled:
        return 'Cancelled';
    }
  }
  
  IconData _getLogLevelIcon(ExecutionLogLevel level) {
    switch (level) {
      case ExecutionLogLevel.debug:
        return Icons.bug_report;
      case ExecutionLogLevel.info:
        return Icons.info;
      case ExecutionLogLevel.warning:
        return Icons.warning;
      case ExecutionLogLevel.error:
        return Icons.error;
    }
  }
  
  Color _getLogLevelColor(ExecutionLogLevel level) {
    switch (level) {
      case ExecutionLogLevel.debug:
        return Colors.grey;
      case ExecutionLogLevel.info:
        return Colors.blue;
      case ExecutionLogLevel.warning:
        return Colors.orange;
      case ExecutionLogLevel.error:
        return Colors.red;
    }
  }
  
  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    final milliseconds = duration.inMilliseconds % 1000;
    return '${seconds}s ${milliseconds}ms';
  }
  
  String _formatOutput(dynamic output) {
    if (output == null) return 'null';
    if (output is String) return output;
    if (output is Map || output is List) {
      // Pretty print JSON
      return output.toString();
    }
    return output.toString();
  }
}

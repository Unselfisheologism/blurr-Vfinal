/// Workflow Canvas using vyuh_node_flow
/// Fully functional node-based workflow editor with vyuh_node_flow integration
library;

import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../state/workflow_state.dart';
import '../state/node_flow_controller.dart';
import '../state/provider_mobx_adapter.dart';
import '../models/node_definitions.dart';
import '../models/workflow_node_data.dart';

/// Main workflow canvas using vyuh_node_flow
class WorkflowCanvas extends StatefulWidget {
  const WorkflowCanvas({super.key});

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  late WorkflowNodeFlowController _nodeFlowController;
  ProviderMobXAdapter? _adapter;

  @override
  void initState() {
    super.initState();

    // Initialize node flow controller
    _nodeFlowController = WorkflowNodeFlowController(
      config: NodeFlowConfig(
        showAttribution: false,
      ),
    );

    // Setup adapter for bidirectional sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final workflowState = context.read<WorkflowState>();
      final adapter = ProviderMobXAdapter(
        workflowState: workflowState,
        nodeFlowController: _nodeFlowController,
      );
      _adapter = adapter;

      // Sync initial workflow
      adapter.syncFromWorkflowState();
    });
  }

  @override
  void dispose() {
    _adapter?.dispose();
    _nodeFlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Node flow editor - constrained to available space
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: _buildNodeFlowEditor(context),
                  ),

                  // Overlay controls - positioned within bounds
                  _buildOverlays(context, constraints),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Build the node flow editor
  Widget _buildNodeFlowEditor(BuildContext context) {
    return NodeFlowEditor<WorkflowNodeData, dynamic>(
      controller: _nodeFlowController.controller,
      theme: _buildTheme(context),
      nodeBuilder: (context, node) => _buildNodeWidget(context, node),
      events: _nodeFlowController.events,
      behavior: NodeFlowBehavior.design,
    );
  }

  /// Build custom theme for the editor
  NodeFlowTheme _buildTheme(BuildContext context) {
    final base = NodeFlowTheme.light;
    final theme = Theme.of(context);

    return base.copyWith(
      backgroundColor: theme.colorScheme.surface,
      gridTheme: base.gridTheme.copyWith(
        style: GridStyles.dots,
        color: theme.dividerColor.withOpacity(0.3),
      ),
      connectionTheme: base.connectionTheme.copyWith(
        style: ConnectionStyles.smoothstep,
        color: theme.colorScheme.primary.withOpacity(0.8),
        strokeWidth: 3.0, // Increased from 2.0 for better visibility
        selectedStrokeWidth: 4.0, // Increased from 3.0
        highlightColor: theme.colorScheme.secondary,
      ),
      portTheme: base.portTheme.copyWith(
        size: const Size(12, 12), // Increased from 10x10 for better visibility
        highlightColor: theme.colorScheme.primary,
      ),
    );
  }

  /// Build node widget
  Widget _buildNodeWidget(BuildContext context, Node<WorkflowNodeData> node) {
    final definition = NodeDefinitions.getById(node.data.nodeType);
    final color = definition?.color ?? Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNodeHeader(context, node, definition, color),
          Expanded(
            child: _buildNodeBody(context, node),
          ),
        ],
      ),
    );
  }

  /// Build node header
  Widget _buildNodeHeader(
    BuildContext context,
    Node<WorkflowNodeData> node,
    NodeDefinition? definition,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: color,
      child: Row(
        children: [
          Icon(
            definition?.icon ?? Icons.circle,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.data.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (node.data.isExecuting)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Delete node',
            icon: const Icon(Icons.close, size: 16, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            onPressed: () async {
              await _nodeFlowController.controller.requestDeleteNode(node.id);
            },
          ),
        ],
      ),
    );
  }

  /// Build node body
  Widget _buildNodeBody(BuildContext context, Node<WorkflowNodeData> node) {
    final workflowState = context.watch<WorkflowState>();

    switch (node.type) {
      case 'manual_trigger':
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start the workflow manually.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: workflowState.isExecuting
                      ? null
                      : () async {
                          await workflowState.executeWorkflow();
                        },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Run'),
                ),
              ),
            ],
          ),
        );

      case 'unified_shell':
        final language = node.data.parameters['language']?.toString() ?? 'auto';
        final code = node.data.parameters['code']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language: $language',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code.isEmpty ? 'No code' : code,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'if_else':
        final expression = node.data.parameters['expression']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Condition',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  expression.isEmpty ? 'No expression' : expression,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );

      case 'loop':
        final items = node.data.parameters['items'];
        final count = items is List ? items.length : 0;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Iterate over a list.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Text(
                'Items: $count',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        );

      case 'output':
        final ctx = workflowState.executionEngine?.context;
        final latest = (ctx != null && ctx.nodeOutputs.isNotEmpty)
            ? ctx.nodeOutputs.entries.last.value
            : null;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Result',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    latest == null ? 'No output yet' : latest.toString(),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'schedule_trigger':
        final cron = node.data.parameters['cron']?.toString() ?? '0 0 * * *';
        final enabled = node.data.parameters['enabled'] ?? true;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    enabled ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: enabled ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    enabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Schedule',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  cron,
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        );

      case 'webhook_trigger':
        final webhookUrl = node.data.parameters['webhookUrl']?.toString() ?? 'Not generated';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Webhook URL',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  webhookUrl.length > 30 ? '${webhookUrl.substring(0, 30)}...' : webhookUrl,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        );

      case 'http_request':
        final method = node.data.parameters['method']?.toString() ?? 'GET';
        final url = node.data.parameters['url']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getMethodColor(method),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      method,
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      url.isEmpty ? 'No URL' : url,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'set_variable':
        final varName = node.data.parameters['key']?.toString() ?? 'unnamed';
        final scope = node.data.parameters['scope']?.toString() ?? 'local';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.save, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text(
                    varName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Scope: $scope',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        );

      case 'get_variable':
        final varName = node.data.parameters['key']?.toString() ?? 'unnamed';
        final defaultValue = node.data.parameters['default']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.input, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Text(
                    varName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                defaultValue.isEmpty ? 'No default' : 'Default: $defaultValue',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        );

      case 'error_handler':
        final errorType = node.data.parameters['errorType']?.toString() ?? 'all';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'ERROR',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Handles: $errorType',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        );

      case 'ai_assist':
        final task = node.data.parameters['task']?.toString() ?? 'No task';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, size: 14, color: Colors.purple.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'AI',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  task,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );

      case 'llm_call':
        final model = node.data.parameters['model']?.toString() ?? 'gpt-4';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy, size: 14, color: Colors.teal.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'LLM',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                model,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        );

      case 'switch':
        final cases = node.data.parameters['cases'] as List? ?? [];

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.call_split, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'SWITCH',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Cases: ${cases.length}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        );

      case 'merge':
        final strategy = node.data.parameters['strategy']?.toString() ?? 'concat';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.merge, size: 14, color: Colors.blueGrey.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'MERGE',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Strategy: $strategy',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Combine 3 inputs',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
              ),
            ],
          ),
        );

      case 'retry':
        final maxAttempts = node.data.parameters['maxAttempts']?.toString() ?? '3';
        final backoff = node.data.parameters['backoff']?.toString() ?? 'linear';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.refresh, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'RETRY',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Max: $maxAttempts | $backoff',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        );

      case 'notification':
        final type = node.data.parameters['type']?.toString() ?? 'toast';
        final title = node.data.parameters['title']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications, size: 14, color: Colors.lightBlue.shade700),
                  const SizedBox(width: 6),
                  Text(
                    type.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title.isEmpty ? 'No title' : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        );

      case 'function':
        final functionName = node.data.parameters['functionName']?.toString() ?? 'unnamed';
        final language = node.data.parameters['language']?.toString() ?? 'js';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.functions, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 6),
                  Text(
                    functionName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Language: $language',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                '3 parameters',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
              ),
            ],
          ),
        );

      case 'transform_data':
        final transformType = node.data.parameters['transformType']?.toString() ?? 'map';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.transform, size: 14, color: Colors.amber.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'TRANSFORM',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Type: $transformType',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        );

      case 'composio_action':
        final actionType = node.data.parameters['actionType']?.toString() ?? 'unknown';

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.extension, size: 14, color: Colors.deepPurple.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'COMPOSIO',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                actionType.isEmpty ? 'No action' : actionType,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        );

      default:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            node.data.description,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        );
    }
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Build overlay controls
  Widget _buildOverlays(BuildContext context, BoxConstraints constraints) {
    // Ensure buttons stay within screen bounds
    const buttonWidth = 60.0; // Approximate width of button column
    const padding = 16.0;
    
    return Positioned(
      top: padding,
      right: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: buttonWidth,
          maxHeight: constraints.maxHeight - (padding * 2),
        ),
        child: _buildControlButtons(context),
      ),
    );
  }

  /// Build control buttons
  Widget _buildControlButtons(BuildContext context) {
    final workflowState = context.watch<WorkflowState>();

    return Card(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Execute workflow button
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.green),
            tooltip: 'Execute Workflow',
            onPressed: workflowState.isExecuting
                ? null
                : () async {
                    await workflowState.executeWorkflow();
                  },
          ),
          // Stop execution button
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            tooltip: 'Stop Execution',
            onPressed: workflowState.isExecuting
                ? () {
                    workflowState.stopExecution();
                  }
                : null,
          ),
          // Clear logs button
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Logs',
            onPressed: () {
              workflowState.clearExecutionLogs();
            },
          ),
          const Divider(height: 1),
          // Save button
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Workflow',
            onPressed: () async {
              try {
                await workflowState.saveWorkflow();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workflow saved')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save: $e')),
                  );
                }
              }
            },
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Workflow',
            onPressed: () => _handleExport(context),
          ),
          // Import button
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Import Workflow',
            onPressed: () => _handleImport(context),
          ),
        ],
      ),
    );
  }

  /// Handle workflow export to file
  Future<void> _handleExport(BuildContext context) async {
    final workflowState = context.read<WorkflowState>();
    
    try {
      // Get workflow JSON
      final jsonString = await workflowState.exportWorkflow();
      
      // Get workflow name for filename
      final workflowName = workflowState.currentWorkflow?.name ?? 'workflow';
      final sanitizedName = workflowName.replaceAll(RegExp(r'[^\w\s-]'), '');
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = '${sanitizedName}_$timestamp.json';
      
      // On Android, save to Downloads directory
      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        
        final file = File('${downloadsDir.path}/$filename');
        await file.writeAsString(jsonString);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Workflow exported to Downloads/$filename')),
          );
        }
      } else {
        // For other platforms, use file picker
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Export Workflow',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        
        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonString);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workflow exported successfully')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    }
  }

  /// Handle workflow import from file
  Future<void> _handleImport(BuildContext context) async {
    final workflowState = context.read<WorkflowState>();

    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      // Read file
      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();

      // Validate JSON
      try {
        jsonDecode(jsonString);
      } catch (e) {
        throw Exception('Invalid JSON file');
      }

      // Import workflow
      await workflowState.importWorkflow(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workflow imported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import: $e')),
        );
      }
    }
  }

}

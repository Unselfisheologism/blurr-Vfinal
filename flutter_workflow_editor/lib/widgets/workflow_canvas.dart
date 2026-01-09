/// Workflow Canvas using vyuh_node_flow
/// Fully functional node-based workflow editor with vyuh_node_flow integration
library;

import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';
import 'package:provider/provider.dart';
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
          body: Stack(
            children: [
              // Node flow editor
              _buildNodeFlowEditor(context),

              // Overlay controls
              _buildOverlays(context),
            ],
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
        color: theme.colorScheme.primary,
        strokeWidth: 2.0,
        selectedStrokeWidth: 3.0,
        highlightColor: theme.colorScheme.primary.withOpacity(0.7),
      ),
      portTheme: base.portTheme.copyWith(
        size: const Size(10, 10),
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

  /// Build overlay controls
  Widget _buildOverlays(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: _buildControlButtons(context),
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
            onPressed: () async {
              try {
                await workflowState.exportWorkflow();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workflow exported')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to export: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

}

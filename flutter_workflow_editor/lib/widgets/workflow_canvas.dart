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
import 'package:uuid/uuid.dart';

/// Main workflow canvas using vyuh_node_flow
class WorkflowCanvas extends StatefulWidget {
  const WorkflowCanvas({super.key});

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  late WorkflowNodeFlowController _nodeFlowController;
  late ProviderMobXAdapter _adapter;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    // Initialize node flow controller
    _nodeFlowController = WorkflowNodeFlowController(
      config: NodeFlowConfig(
        theme: NodeFlowTheme.light,
        gridStyle: GridStyle.dots,
        connectionStyle: ConnectionStyles.smoothstep,
      ),
    );

    // Setup adapter for bidirectional sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workflowState = context.read<WorkflowState>();
      _adapter = ProviderMobXAdapter(
        workflowState: workflowState,
        nodeFlowController: _nodeFlowController,
      );

      // Sync initial workflow
      _adapter.syncFromWorkflowState();
    });
  }

  @override
  void dispose() {
    _adapter.dispose();
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
    return NodeFlowEditor<WorkflowNodeData>(
      controller: _nodeFlowController.controller,
      theme: _buildTheme(context),
      nodeBuilder: (context, node) => _buildNodeWidget(context, node),
      onNodeAdded: (node) {
        debugPrint('Node added: ${node.id}');
        _onNodeAdded(node);
      },
      onNodeRemoved: (nodeId) {
        debugPrint('Node removed: $nodeId');
        _onNodeRemoved(nodeId);
      },
      onConnectionCreated: (connection) {
        debugPrint('Connection created: ${connection.id}');
        _onConnectionCreated(connection);
      },
      onConnectionRemoved: (connectionId) {
        debugPrint('Connection removed: $connectionId');
        _onConnectionRemoved(connectionId);
      },
    );
  }

  /// Build custom theme for the editor
  NodeFlowTheme _buildTheme(BuildContext context) {
    return NodeFlowTheme.light.copyWith(
      gridStyle: GridStyle.dots,
      gridColor: Theme.of(context).dividerColor.withOpacity(0.3),
      connectionTheme: NodeFlowTheme.light.connectionTheme.copyWith(
        color: Theme.of(context).primaryColor,
        strokeWidth: 2.0,
        hoveredStrokeWidth: 3.0,
      ),
      portTheme: NodeFlowTheme.light.portTheme.copyWith(
        size: 10.0,
        hoveredSize: 14.0,
      ),
    );
  }

  /// Build node widget
  Widget _buildNodeWidget(BuildContext context, Node<WorkflowNodeData> node) {
    final definition = NodeDefinitions.getById(node.data.nodeType);

    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      decoration: BoxDecoration(
        color: definition?.color.withOpacity(0.1) ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: definition?.color ?? Colors.grey,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node header
          _buildNodeHeader(node, definition),
          // Node body
          _buildNodeBody(node),
        ],
      ),
    );
  }

  /// Build node header
  Widget _buildNodeHeader(
    Node<WorkflowNodeData> node,
    NodeDefinition? definition,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: definition?.color ?? Colors.grey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      child: Row(
        children: [
          if (definition?.icon != null)
            Icon(
              definition!.icon,
              color: Colors.white,
              size: 16,
            ),
          if (definition?.icon != null) const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  /// Build node body
  Widget _buildNodeBody(Node<WorkflowNodeData> node) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (node.data.description.isNotEmpty)
            Text(
              node.data.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          if (node.data.parameters.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...node.data.parameters.entries.take(3).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (node.data.executionResult.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 12, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Executed',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
            icon: const Icon(Icons.file_export),
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

  /// Handle node added event
  void _onNodeAdded(Node<WorkflowNodeData> node) {
    final workflowState = context.read<WorkflowState>();

    // Add to workflow state
    workflowState.addNode(
      type: node.type,
      name: node.data.name,
      data: node.data.parameters,
      position: node.position,
    );
  }

  /// Handle node removed event
  void _onNodeRemoved(String nodeId) {
    final workflowState = context.read<WorkflowState>();
    workflowState.removeNode(nodeId);
  }

  /// Handle connection created event
  void _onConnectionCreated(Connection connection) {
    final workflowState = context.read<WorkflowState>();

    workflowState.addConnection(
      sourceNodeId: connection.sourceNodeId,
      targetNodeId: connection.targetNodeId,
      sourcePortId: connection.sourcePortId,
      targetPortId: connection.targetPortId,
    );
  }

  /// Handle connection removed event
  void _onConnectionRemoved(String connectionId) {
    final workflowState = context.read<WorkflowState>();
    workflowState.removeConnection(connectionId);
  }
}

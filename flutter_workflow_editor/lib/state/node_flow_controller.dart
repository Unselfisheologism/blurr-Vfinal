/// Workflow Node Flow Controller
/// Wrapper around vyuh_node_flow's NodeFlowController for workflow-specific operations
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

import '../models/node_definitions.dart';
import '../models/workflow.dart';
import '../models/workflow_connection.dart';
import '../models/workflow_node.dart' hide PortType;
import '../models/workflow_node_data.dart';

/// Controller for managing workflow nodes with vyuh_node_flow
class WorkflowNodeFlowController {
  late final NodeFlowController<WorkflowNodeData, dynamic> _controller;
  late NodeFlowEvents<WorkflowNodeData, dynamic> _events;

  final _changeController = StreamController<void>.broadcast();

  /// Stream of change events (emitted from editor callbacks)
  Stream<void> get onChange => _changeController.stream;

  /// Get the underlying vyuh_node_flow controller
  NodeFlowController<WorkflowNodeData, dynamic> get controller => _controller;

  /// Editor events used to emit changes for syncing
  NodeFlowEvents<WorkflowNodeData, dynamic> get events => _events;

  /// Get all nodes
  List<Node<WorkflowNodeData>> get nodes => _controller.nodes.values.toList();

  /// Get all connections
  List<Connection<dynamic>> get connections => _controller.connections;

  WorkflowNodeFlowController({NodeFlowConfig? config}) {
    _controller = NodeFlowController<WorkflowNodeData, dynamic>(
      config: config ?? NodeFlowConfig(),
    );

    _events = NodeFlowEvents<WorkflowNodeData, dynamic>(
      node: NodeEvents<WorkflowNodeData>(
        onCreated: (_) => _emitChanged(),
        onDeleted: (_) => _emitChanged(),
        onDragStop: (_) => _emitChanged(),
      ),
      connection: ConnectionEvents<WorkflowNodeData, dynamic>(
        onCreated: (_) => _emitChanged(),
        onDeleted: (_) => _emitChanged(),
      ),
    );
  }

  void _emitChanged() {
    if (!_changeController.isClosed) {
      _changeController.add(null);
    }
  }

  void setSelectionChangeHandler(
    ValueChanged<SelectionState<WorkflowNodeData, dynamic>>? handler,
  ) {
    _events = _events.copyWith(onSelectionChange: handler);
    _controller.updateEvents(_events);
  }

  /// Add a new node to the workflow
  Node<WorkflowNodeData> addNode({
    required String id,
    required String type,
    required String name,
    Offset? position,
    Map<String, dynamic> parameters = const {},
    List<Port>? inputPorts,
    List<Port>? outputPorts,
  }) {
    final nodeDefinition = NodeDefinitions.getById(type);

    final resolvedPosition = position ?? _calculateNextPosition();

    final nodeData = WorkflowNodeData(
      name: name,
      description: nodeDefinition?.description ?? '',
      nodeType: type,
      parameters: parameters,
    );

    final node = Node<WorkflowNodeData>(
      id: id,
      type: type,
      position: resolvedPosition,
      data: nodeData,
      size: const Size(220, 140),
      inputPorts: inputPorts ?? _getDefaultInputPorts(type),
      outputPorts: outputPorts ?? _getDefaultOutputPorts(type),
      theme: _getNodeTheme(type),
    );

    _controller.addNode(node);
    return node;
  }

  /// Remove a node by ID
  void removeNode(String nodeId) {
    _controller.removeNode(nodeId);
  }

  /// Update node data.
  ///
  /// vyuh_node_flow nodes store data as a final field, so we replace the node
  /// inside the controller's nodesObservable map.
  void updateNodeData(String nodeId, WorkflowNodeData newData) {
    final node = _controller.getNode(nodeId);
    if (node == null) {
      throw ArgumentError('Node not found: $nodeId');
    }

    final updatedNode = Node<WorkflowNodeData>(
      id: node.id,
      type: node.type,
      position: node.position.value,
      data: newData,
      size: node.size.value,
      inputPorts: node.inputPorts,
      outputPorts: node.outputPorts,
      initialZIndex: node.currentZIndex,
      visible: node.isVisible,
      layer: node.layer,
      locked: node.locked,
      selectable: node.selectable,
      widgetBuilder: node.widgetBuilder,
      theme: node.theme,
    );

    _controller.nodesObservable[nodeId] = updatedNode;
    _emitChanged();
  }

  /// Update node position
  void updateNodePosition(String nodeId, Offset position) {
    _controller.setNodePosition(nodeId, position);
  }

  /// Create a connection between two nodes
  void createConnection({
    required String sourceNodeId,
    required String sourcePortId,
    required String targetNodeId,
    required String targetPortId,
  }) {
    _controller.createConnection(
      sourceNodeId,
      sourcePortId,
      targetNodeId,
      targetPortId,
    );
  }

  /// Remove a connection
  void removeConnection(String connectionId) {
    _controller.removeConnection(connectionId);
  }

  /// Clear all nodes and connections
  void clear() {
    _controller.clearGraph();
  }

  /// Import nodes and connections from a Workflow
  void importFromWorkflow(Workflow workflow) {
    clear();

    for (final workflowNode in workflow.nodes) {
      addNode(
        id: workflowNode.id,
        type: workflowNode.type,
        name: workflowNode.name,
        position: Offset(workflowNode.x, workflowNode.y),
        parameters: workflowNode.data,
      );
    }

    for (final conn in workflow.connections) {
      try {
        createConnection(
          sourceNodeId: conn.sourceNodeId,
          sourcePortId: conn.sourcePortId,
          targetNodeId: conn.targetNodeId,
          targetPortId: conn.targetPortId,
        );
      } catch (e) {
        debugPrint('Failed to import connection: $e');
      }
    }
  }

  /// Export to a Workflow model
  Workflow exportToWorkflow({
    required String workflowId,
    required String name,
    required String description,
  }) {
    final exportedNodes = _controller.nodes.values.map((node) {
      final pos = node.position.value;
      return WorkflowNode(
        id: node.id,
        type: node.type,
        name: node.data.name,
        x: pos.dx,
        y: pos.dy,
        data: node.data.parameters,
      );
    }).toList();

    final exportedConnections = _controller.connections.map((conn) {
      return WorkflowConnection(
        id: conn.id,
        sourceNodeId: conn.sourceNodeId,
        targetNodeId: conn.targetNodeId,
        sourcePortId: conn.sourcePortId,
        targetPortId: conn.targetPortId,
      );
    }).toList();

    return Workflow(
      id: workflowId,
      name: name,
      description: description,
      nodes: exportedNodes,
      connections: exportedConnections,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Export graph to JSON
  Map<String, dynamic> toJson() {
    final graph = _controller.exportGraph();
    return graph.toJson(
      (t) => t.toJson(),
      (c) => c,
    );
  }

  /// Import graph from JSON
  Future<void> fromJson(Map<String, dynamic> json) async {
    final graph = NodeGraph<WorkflowNodeData, dynamic>.fromJson(
      json,
      (data) => WorkflowNodeData.fromJson(
        Map<String, dynamic>.from(data as Map? ?? const {}),
      ),
      (data) => data,
    );

    _controller.loadGraph(graph);
  }

  Offset _calculateNextPosition() {
    final nodeCount = _controller.nodes.length;

    const columns = 3;
    const startX = 120.0;
    const startY = 120.0;
    const spacingX = 260.0;
    const spacingY = 200.0;

    final row = nodeCount ~/ columns;
    final col = nodeCount % columns;

    return Offset(
      startX + (col * spacingX),
      startY + (row * spacingY),
    );
  }

  NodeTheme? _getNodeTheme(String nodeType) {
    final def = NodeDefinitions.getById(nodeType);
    if (def == null) return null;

    final color = def.color;

    return NodeTheme.light.copyWith(
      backgroundColor: color.withOpacity(0.08),
      selectedBackgroundColor: color.withOpacity(0.16),
      highlightBackgroundColor: color.withOpacity(0.12),
      borderColor: color.withOpacity(0.85),
      selectedBorderColor: color,
      highlightBorderColor: color.withOpacity(0.9),
      selectedBorderWidth: 3.0,
    );
  }

  List<Port> _getDefaultInputPorts(String nodeType) {
    Port input(String id, String name) => Port(
          id: id,
          name: name,
          type: PortType.input,
          position: PortPosition.left,
        );

    switch (nodeType) {
      case 'manual_trigger':
      case 'schedule_trigger':
      case 'webhook_trigger':
        return [];

      case 'unified_shell':
        return [input('in', 'Code')];

      case 'http_request':
        return [
          input('url', 'URL'),
          input('headers', 'Headers'),
        ];

      case 'if_else':
        return [input('in', 'Condition')];

      case 'loop':
        return [
          input('list', 'List'),
          input('body', 'Body'),
        ];

      case 'set_variable':
        return [
          input('name', 'Name'),
          input('value', 'Value'),
        ];

      case 'get_variable':
        return [input('name', 'Name')];

      case 'ui_automation':
        return [
          input('selector', 'Selector'),
          input('action', 'Action'),
        ];

      case 'phone_control':
        return [
          input('feature', 'Feature'),
          input('params', 'Params'),
        ];

      case 'error_handler':
        return [input('error', 'Error')];

      case 'ai_assist':
        return [
          input('task', 'Task'),
          input('context', 'Context'),
        ];

      case 'llm_call':
        return [
          input('prompt', 'Prompt'),
          input('model', 'Model'),
        ];

      case 'switch':
        return [input('value', 'Value')];

      case 'merge':
        return [
          input('merge1', 'Merge 1'),
          input('merge2', 'Merge 2'),
          input('merge3', 'Merge 3'),
        ];

      case 'retry':
        return [input('operation', 'Operation')];

      case 'notification':
        return [
          input('title', 'Title'),
          input('message', 'Message'),
        ];

      case 'function':
        return [
          input('param1', 'Param 1'),
          input('param2', 'Param 2'),
          input('param3', 'Param 3'),
        ];

      case 'transform_data':
        return [input('data', 'Data')];

      case 'composio_action':
        return [
          input('action_type', 'Action'),
          input('parameters', 'Parameters'),
        ];

      case 'mcp_action':
        return [
          input('tool_name', 'Tool'),
          input('arguments', 'Arguments'),
        ];

      case 'output':
        return [input('in', 'Data')];

      default:
        return [input('in', 'Input')];
    }
  }

  List<Port> _getDefaultOutputPorts(String nodeType) {
    Port output(String id, String name) => Port(
          id: id,
          name: name,
          type: PortType.output,
          position: PortPosition.right,
        );

    switch (nodeType) {
      case 'manual_trigger':
        return [output('out', 'Trigger')];

      case 'schedule_trigger':
      case 'webhook_trigger':
        return [output('out', 'Output')];

      case 'unified_shell':
        return [output('out', 'Result')];

      case 'http_request':
        return [
          output('response', 'Response'),
          output('status', 'Status'),
        ];

      case 'if_else':
        return [
          output('true', 'True'),
          output('false', 'False'),
        ];

      case 'loop':
        return [
          output('each', 'Each Item'),
          output('completed', 'Completed'),
        ];

      case 'set_variable':
        return [output('saved', 'Saved')];

      case 'get_variable':
        return [output('value', 'Value')];

      case 'ui_automation':
        return [
          output('result', 'Result'),
          output('error', 'Error'),
        ];

      case 'phone_control':
        return [
          output('result', 'Result'),
          output('error', 'Error'),
        ];

      case 'error_handler':
        return [
          output('handle', 'Handle'),
          output('rethrow', 'Rethrow'),
        ];

      case 'ai_assist':
        return [
          output('result', 'Result'),
          output('error', 'Error'),
        ];

      case 'llm_call':
        return [
          output('response', 'Response'),
          output('tokens', 'Tokens'),
        ];

      case 'switch':
        return [
          output('case1', 'Case 1'),
          output('case2', 'Case 2'),
          output('case3', 'Case 3'),
          output('default', 'Default'),
        ];

      case 'merge':
        return [output('merged', 'Merged')];

      case 'retry':
        return [
          output('success', 'Success'),
          output('failed', 'Failed'),
        ];

      case 'notification':
        return [output('sent', 'Sent')];

      case 'function':
        return [
          output('result', 'Result'),
          output('error', 'Error'),
        ];

      case 'transform_data':
        return [output('transformed', 'Transformed')];

      case 'composio_action':
        return [
          output('result', 'Result'),
          output('error', 'Error'),
        ];

      case 'mcp_action':
        return [
          output('result', 'Result'),
          output('error', 'Error'),
        ];

      case 'output':
        return [];

      default:
        return [output('out', 'Output')];
    }
  }

  /// Dispose resources
  void dispose() {
    _changeController.close();
  }
}

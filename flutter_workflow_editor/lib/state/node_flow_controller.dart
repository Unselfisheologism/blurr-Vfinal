/// Workflow Node Flow Controller
/// Wrapper around vyuh_node_flow's NodeFlowController for workflow-specific operations
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';
import '../models/workflow_node_data.dart';
import '../models/node_definitions.dart';
import '../models/workflow.dart';

/// Controller for managing workflow nodes with vyuh_node_flow
class WorkflowNodeFlowController {
  late final NodeFlowController<WorkflowNodeData> _controller;
  final _changeController = StreamController<void>.broadcast();

  /// Stream of change events
  Stream<void> get onChange => _changeController.stream;

  /// Get the underlying vyuh_node_flow controller
  NodeFlowController<WorkflowNodeData> get controller => _controller;

  /// Get all nodes
  List<Node<WorkflowNodeData>> get nodes => _controller.nodes;

  /// Get all connections
  List<Connection> get connections => _controller.connections;

  WorkflowNodeFlowController({
    NodeFlowConfig? config,
  }) {
    _controller = NodeFlowController<WorkflowNodeData>(
      config: config ??
          NodeFlowConfig(
            theme: NodeFlowTheme.light,
            gridStyle: GridStyle.dots,
            connectionStyle: ConnectionStyles.smoothstep,
          ),
    );

    // Listen to controller changes
    _controller.addListener(_onControllerChanged);
  }

  /// Add a new node to the workflow
  Node<WorkflowNodeData> addNode({
    required String id,
    required String type,
    required String name,
    required Offset position,
    Map<String, dynamic> parameters = const {},
    List<Port>? inputPorts,
    List<Port>? outputPorts,
  }) {
    final nodeDefinition = NodeDefinitions.getById(type);

    final nodeData = WorkflowNodeData(
      name: name,
      description: nodeDefinition?.description ?? '',
      nodeType: type,
      parameters: parameters,
    );

    final node = Node<WorkflowNodeData>(
      id: id,
      type: type,
      position: position,
      data: nodeData,
      inputPorts: inputPorts ?? _getDefaultInputPorts(type),
      outputPorts: outputPorts ?? _getDefaultOutputPorts(type),
    );

    _controller.addNode(node);
    return node;
  }

  /// Remove a node by ID
  void removeNode(String nodeId) {
    _controller.removeNode(nodeId);
  }

  /// Update node data
  void updateNodeData(String nodeId, WorkflowNodeData newData) {
    final node = _controller.nodes.firstWhere(
      (n) => n.id == nodeId,
      orElse: () => throw ArgumentError('Node not found: $nodeId'),
    );

    final updatedNode = node.copyWith(data: newData);
    _controller.updateNode(updatedNode);
  }

  /// Update node position
  void updateNodePosition(String nodeId, Offset position) {
    final node = _controller.nodes.firstWhere(
      (n) => n.id == nodeId,
      orElse: () => throw ArgumentError('Node not found: $nodeId'),
    );

    final updatedNode = node.copyWith(position: position);
    _controller.updateNode(updatedNode);
  }

  /// Create a connection between two nodes
  Connection createConnection({
    required String sourceNodeId,
    required String sourcePortId,
    required String targetNodeId,
    required String targetPortId,
  }) {
    return _controller.createConnection(
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
    for (final node in List.from(_controller.nodes)) {
      _controller.removeNode(node.id);
    }
  }

  /// Import nodes and connections from a Workflow
  void importFromWorkflow(Workflow workflow) {
    clear();

    // Import nodes
    for (final workflowNode in workflow.nodes) {
      addNode(
        id: workflowNode.id,
        type: workflowNode.type,
        name: workflowNode.name,
        position: Offset(workflowNode.x, workflowNode.y),
        parameters: workflowNode.data,
      );
    }

    // Import connections
    for (final connection in workflow.connections) {
      try {
        createConnection(
          sourceNodeId: connection.sourceNodeId,
          sourcePortId: connection.sourcePortId,
          targetNodeId: connection.targetNodeId,
          targetPortId: connection.targetPortId,
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
    final nodes = _controller.nodes.map((node) {
      return WorkflowNode(
        id: node.id,
        type: node.type,
        name: node.data.name,
        x: node.position.dx,
        y: node.position.dy,
        data: node.data.parameters,
      );
    }).toList();

    final connections = _controller.connections.map((conn) {
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
      nodes: nodes,
      connections: connections,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Export to JSON
  Map<String, dynamic> toJson() {
    return _controller.toJson();
  }

  /// Import from JSON
  Future<void> fromJson(Map<String, dynamic> json) async {
    await _controller.fromJson(json);
  }

  /// Get default input ports for a node type
  List<Port> _getDefaultInputPorts(String nodeType) {
    switch (nodeType) {
      case 'manual_trigger':
      case 'schedule_trigger':
      case 'webhook_trigger':
        return [];

      case 'if_else':
        return [
          const Port(id: 'in', name: 'Input'),
        ];

      case 'switch':
        return [
          const Port(id: 'in', name: 'Input'),
        ];

      case 'loop':
        return [
          const Port(id: 'in', name: 'Input'),
          const Port(id: 'list', name: 'List'),
        ];

      case 'error_handler':
        return [
          const Port(id: 'in', name: 'Input'),
          const Port(id: 'error', name: 'Error'),
        ];

      default:
        return [
          const Port(id: 'in', name: 'Input'),
        ];
    }
  }

  /// Get default output ports for a node type
  List<Port> _getDefaultOutputPorts(String nodeType) {
    switch (nodeType) {
      case 'if_else':
        return [
          const Port(id: 'true', name: 'True'),
          const Port(id: 'false', name: 'False'),
        ];

      case 'switch':
        return [
          const Port(id: 'case1', name: 'Case 1'),
          const Port(id: 'case2', name: 'Case 2'),
          const Port(id: 'case3', name: 'Case 3'),
          const Port(id: 'default', name: 'Default'),
        ];

      case 'loop':
        return [
          const Port(id: 'loopBody', name: 'Loop Body'),
          const Port(id: 'completed', name: 'Completed'),
          const Port(id: 'element', name: 'Element'),
          const Port(id: 'index', name: 'Index'),
        ];

      case 'error_handler':
        return [
          const Port(id: 'success', name: 'Success'),
        ];

      case 'merge':
        return [
          const Port(id: 'out', name: 'Output'),
        ];

      default:
        return [
          const Port(id: 'out', name: 'Output'),
        ];
    }
  }

  /// Handle controller changes
  void _onControllerChanged() {
    _changeController.add(null);
  }

  /// Dispose resources
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _changeController.close();
  }
}

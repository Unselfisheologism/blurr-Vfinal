/// Workflow model
library;

import 'package:json_annotation/json_annotation.dart';
import 'workflow_node.dart';
import 'workflow_connection.dart';

part 'workflow.g.dart';

@JsonSerializable()
class Workflow {
  final String id;
  String name;
  String? description;
  List<WorkflowNode> nodes;
  List<WorkflowConnection> connections;
  Map<String, dynamic> variables;
  Map<String, dynamic> settings;
  
  final DateTime createdAt;
  DateTime updatedAt;
  
  bool active;
  String? tags;

  Workflow({
    required this.id,
    required this.name,
    this.description,
    List<WorkflowNode>? nodes,
    List<WorkflowConnection>? connections,
    Map<String, dynamic>? variables,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.active = false,
    this.tags,
  })  : nodes = nodes ?? [],
        connections = connections ?? [],
        variables = variables ?? {},
        settings = settings ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Workflow.fromJson(Map<String, dynamic> json) =>
      _$WorkflowFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowToJson(this);

  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkflowNode>? nodes,
    List<WorkflowConnection>? connections,
    Map<String, dynamic>? variables,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    String? tags,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      variables: variables ?? this.variables,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
      tags: tags ?? this.tags,
    );
  }

  /// Add a node to the workflow
  void addNode(WorkflowNode node) {
    nodes.add(node);
    updatedAt = DateTime.now();
  }

  /// Remove a node and its connections
  void removeNode(String nodeId) {
    nodes.removeWhere((node) => node.id == nodeId);
    connections.removeWhere(
      (conn) => conn.sourceNodeId == nodeId || conn.targetNodeId == nodeId,
    );
    updatedAt = DateTime.now();
  }

  /// Add a connection between nodes
  void addConnection(WorkflowConnection connection) {
    // Validate connection doesn't already exist
    final exists = connections.any(
      (conn) =>
          conn.sourceNodeId == connection.sourceNodeId &&
          conn.targetNodeId == connection.targetNodeId &&
          conn.sourcePortId == connection.sourcePortId &&
          conn.targetPortId == connection.targetPortId,
    );
    
    if (!exists) {
      connections.add(connection);
      updatedAt = DateTime.now();
    }
  }

  /// Remove a connection
  void removeConnection(String connectionId) {
    connections.removeWhere((conn) => conn.id == connectionId);
    updatedAt = DateTime.now();
  }

  /// Get execution order for vertical flow (top to bottom)
  List<WorkflowNode> getExecutionOrder() {
    // Sort nodes by Y position (top to bottom)
    final sortedNodes = List<WorkflowNode>.from(nodes)
      ..sort((a, b) => a.y.compareTo(b.y));
    
    // Topological sort for proper execution order
    final visited = <String>{};
    final order = <WorkflowNode>[];
    
    void visit(WorkflowNode node) {
      if (visited.contains(node.id)) return;
      visited.add(node.id);
      
      // Visit dependencies first (nodes that connect to this node)
      final incomingConnections = connections.where(
        (conn) => conn.targetNodeId == node.id,
      );
      
      for (final conn in incomingConnections) {
        final sourceNode = nodes.firstWhere(
          (n) => n.id == conn.sourceNodeId,
        );
        visit(sourceNode);
      }
      
      order.add(node);
    }
    
    for (final node in sortedNodes) {
      visit(node);
    }
    
    return order;
  }

  /// Validate workflow structure
  List<String> validate() {
    final errors = <String>[];
    
    // Check for orphaned connections
    for (final conn in connections) {
      if (!nodes.any((n) => n.id == conn.sourceNodeId)) {
        errors.add('Connection references missing source node: ${conn.id}');
      }
      if (!nodes.any((n) => n.id == conn.targetNodeId)) {
        errors.add('Connection references missing target node: ${conn.id}');
      }
    }
    
    // Check for required data
    for (final node in nodes) {
      // Validate based on node type
      if (node.type == 'composio_action') {
        if (!node.data.containsKey('tool')) {
          errors.add('${node.name}: Composio action requires tool parameter');
        }
      }
    }
    
    return errors;
  }
}

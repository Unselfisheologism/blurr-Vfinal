/// NodeFlowController integration for vyuh_node_flow
/// Provides wrapper around vyuh_node_flow's NodeFlowController with workflow-specific functionality
library;

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';
import '../models/node_definitions.dart';
import '../models/workflow_node_data.dart';

/// Wrapper around vyuh_node_flow's NodeFlowController
/// Manages workflow nodes and connections using MobX state management
class WorkflowNodeFlowController {
  final NodeFlowController<WorkflowNodeData> _controller;
  final Set<VoidCallback> _listeners = {};
  
  WorkflowNodeFlowController() 
      : _controller = NodeFlowController<WorkflowNodeData>() {
    _setupListeners();
  }
  
  /// Get the underlying NodeFlowController
  NodeFlowController<WorkflowNodeData> get controller => _controller;
  
  /// Setup listeners for state changes
  void _setupListeners() {
    // Listen to controller changes and notify our listeners
    _controller.addListener(() {
      for (final listener in _listeners) {
        listener();
      }
    });
  }
  
  /// Add a listener for state changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  /// Remove a listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  /// Clear all listeners
  void clearListeners() {
    _listeners.clear();
  }
  
  // Node Operations
  
  /// Add a new node to the workflow
  void addNode({
    required String id,
    required String nodeType,
    required String name,
    required Offset position,
    required Map<String, dynamic> data,
    required NodeDefinition definition,
  }) {
    final nodeData = WorkflowNodeData(
      workflowNodeId: id,
      nodeType: nodeType,
      data: data,
      displayName: name,
    );
    
    _controller.addNode(Node<WorkflowNodeData>(
      id: id,
      type: nodeType,
      position: position,
      data: nodeData,
      inputPorts: _createInputPorts(definition),
      outputPorts: _createOutputPorts(definition),
    ));
  }
  
  /// Remove a node from the workflow
  void removeNode(String nodeId) {
    _controller.removeNode(nodeId);
  }
  
  /// Update node position
  void updateNodePosition(String nodeId, Offset position) {
    _controller.updateNodePosition(nodeId, position);
  }
  
  /// Update node data
  void updateNodeData(String nodeId, Map<String, dynamic> data) {
    final node = _controller.getNode(nodeId);
    if (node != null) {
      final updatedData = WorkflowNodeData(
        workflowNodeId: node.data.workflowNodeId,
        nodeType: node.data.nodeType,
        data: data,
        displayName: node.data.displayName,
      );
      
      _controller.updateNode(nodeId, data: updatedData);
    }
  }
  
  /// Select a node
  void selectNode(String nodeId) {
    _controller.selectNode(nodeId);
  }
  
  /// Clear node selection
  void clearSelection() {
    _controller.clearSelection();
  }
  
  // Connection Operations
  
  /// Create a connection between nodes
  void createConnection({
    required String sourceNodeId,
    required String sourcePortId,
    required String targetNodeId,
    required String targetPortId,
  }) {
    _controller.createConnection(sourceNodeId, sourcePortId, targetNodeId, targetPortId);
  }
  
  /// Remove a connection
  void removeConnection(String sourceNodeId, String sourcePortId, String targetNodeId, String targetPortId) {
    _controller.removeConnection(sourceNodeId, sourcePortId, targetNodeId, targetPortId);
  }
  
  /// Remove all connections for a node
  void removeNodeConnections(String nodeId) {
    _controller.removeNodeConnections(nodeId);
  }
  
  // Theme and Configuration
  
  /// Set the editor theme
  void setTheme(NodeFlowTheme theme) {
    _controller.setTheme(theme);
  }
  
  /// Enable/disable debug mode
  void setDebugMode(bool enabled) {
    _controller.setDebugMode(enabled);
  }
  
  /// Enable/disable minimap
  void setMinimapEnabled(bool enabled) {
    _controller.setMinimapEnabled(enabled);
  }
  
  // Viewport Operations
  
  /// Zoom to fit all nodes
  void zoomToFit() {
    _controller.zoomToFit();
  }
  
  /// Zoom to specific nodes
  void zoomToNodes(List<String> nodeIds) {
    _controller.zoomToNodes(nodeIds);
  }
  
  /// Center viewport on specific position
  void centerOn(Offset position) {
    _controller.centerOn(position);
  }
  
  // Serialization
  
  /// Convert workflow to JSON
  Map<String, dynamic> toJson() {
    return {
      'nodes': _controller.nodes.map((node) => node.toJson()).toList(),
      'connections': _controller.connections.map((conn) => conn.toJson()).toList(),
      'theme': _controller.currentTheme?.toJson(),
    };
  }
  
  /// Load workflow from JSON
  void fromJson(Map<String, dynamic> json) {
    _controller.clear();
    
    // Load nodes
    final nodesJson = json['nodes'] as List?;
    if (nodesJson != null) {
      for (final nodeJson in nodesJson) {
        final node = Node<WorkflowNodeData>.fromJson(nodeJson);
        _controller.addNode(node);
      }
    }
    
    // Load connections
    final connectionsJson = json['connections'] as List?;
    if (connectionsJson != null) {
      for (final connJson in connectionsJson) {
        final connection = Connection.fromJson(connJson);
        _controller.addConnection(connection);
      }
    }
    
    // Load theme
    final themeJson = json['theme'];
    if (themeJson != null) {
      final theme = NodeFlowTheme.fromJson(themeJson);
      _controller.setTheme(theme);
    }
  }
  
  // Utility Methods
  
  /// Get all nodes
  List<Node<WorkflowNodeData>> get nodes => _controller.nodes;
  
  /// Get all connections
  List<Connection> get connections => _controller.connections;
  
  /// Get node by ID
  Node<WorkflowNodeData>? getNode(String nodeId) {
    return _controller.getNode(nodeId);
  }
  
  /// Get selected nodes
  List<Node<WorkflowNodeData>> get selectedNodes => _controller.selectedNodes;
  
  /// Check if node exists
  bool hasNode(String nodeId) {
    return _controller.hasNode(nodeId);
  }
  
  /// Get node count
  int get nodeCount => _controller.nodeCount;
  
  /// Get connection count
  int get connectionCount => _controller.connectionCount;
  
  /// Clear all nodes and connections
  void clear() {
    _controller.clear();
  }
  
  /// Dispose controller
  void dispose() {
    clearListeners();
    _controller.dispose();
  }
  
  /// Create input ports for node definition
  List<Port> _createInputPorts(NodeDefinition definition) {
    final ports = <Port>[];
    
    // Control input port (except for trigger nodes)
    if (definition.category != NodeCategory.triggers) {
      ports.add(Port(id: 'exec', name: 'Execute'));
    }
    
    // Add specific data input ports based on node type
    switch (definition.id) {
      case 'unified_shell':
        ports.addAll([
          Port(id: 'code', name: 'Code'),
          Port(id: 'inputs', name: 'Inputs'),
        ]);
        break;
      
      case 'http_request':
        ports.addAll([
          Port(id: 'url', name: 'URL'),
          Port(id: 'method', name: 'Method'),
          Port(id: 'headers', name: 'Headers'),
          Port(id: 'body', name: 'Body'),
        ]);
        break;
      
      case 'loop':
        ports.add(Port(id: 'list', name: 'List'));
        break;
      
      case 'if_else':
        ports.add(Port(id: 'condition', name: 'Condition'));
        break;
      
      case 'switch':
        ports.add(Port(id: 'value', name: 'Value'));
        break;
      
      case 'set_variable':
        ports.addAll([
          Port(id: 'value', name: 'Value'),
          Port(id: 'variableName', name: 'Variable Name'),
        ]);
        break;
      
      case 'get_variable':
        ports.add(Port(id: 'variableName', name: 'Variable Name'));
        break;
      
      case 'transform_data':
        ports.addAll([
          Port(id: 'input', name: 'Input'),
          Port(id: 'mapping', name: 'Mapping'),
        ]);
        break;
      
      case 'function':
        ports.addAll([
          Port(id: 'expression', name: 'Expression'),
          Port(id: 'variables', name: 'Variables'),
        ]);
        break;
      
      case 'ai_assist':
        ports.addAll([
          Port(id: 'prompt', name: 'Prompt'),
          Port(id: 'context', name: 'Context'),
        ]);
        break;
      
      case 'llm_call':
        ports.addAll([
          Port(id: 'prompt', name: 'Prompt'),
          Port(id: 'model', name: 'Model'),
          Port(id: 'parameters', name: 'Parameters'),
        ]);
        break;
      
      case 'phone_control':
        ports.addAll([
          Port(id: 'action', name: 'Action'),
          Port(id: 'parameters', name: 'Parameters'),
        ]);
        break;
      
      case 'notification':
        ports.addAll([
          Port(id: 'title', name: 'Title'),
          Port(id: 'message', name: 'Message'),
          Port(id: 'priority', name: 'Priority'),
        ]);
        break;
      
      case 'ui_automation':
        ports.addAll([
          Port(id: 'target', name: 'Target'),
          Port(id: 'action', name: 'Action'),
          Port(id: 'parameters', name: 'Parameters'),
        ]);
        break;
    }
    
    return ports;
  }
  
  /// Create output ports for node definition
  List<Port> _createOutputPorts(NodeDefinition definition) {
    final ports = <Port>[];
    
    // Add control output ports based on node type
    switch (definition.id) {
      case 'if_else':
        ports.addAll([
          Port(id: 'true', name: 'True'),
          Port(id: 'false', name: 'False'),
        ]);
        break;
      
      case 'switch':
        ports.addAll([
          Port(id: 'case1', name: 'Case 1'),
          Port(id: 'case2', name: 'Case 2'),
          Port(id: 'case3', name: 'Case 3'),
          Port(id: 'default', name: 'Default'),
        ]);
        break;
      
      case 'loop':
        ports.addAll([
          Port(id: 'loopBody', name: 'Loop Body'),
          Port(id: 'completed', name: 'Completed'),
        ]);
        break;
      
      case 'error_handler':
        ports.addAll([
          Port(id: 'success', name: 'Success'),
          Port(id: 'error', name: 'Error'),
        ]);
        break;
      
      default:
        // Single output port for most nodes
        ports.add(Port(id: 'out', name: 'Out'));
    }
    
    // Add data output ports
    switch (definition.id) {
      case 'unified_shell':
        ports.add(Port(id: 'result', name: 'Result'));
        break;
      
      case 'http_request':
        ports.addAll([
          Port(id: 'response', name: 'Response'),
          Port(id: 'statusCode', name: 'Status'),
        ]);
        break;
      
      case 'loop':
        ports.addAll([
          Port(id: 'element', name: 'Element'),
          Port(id: 'index', name: 'Index'),
        ]);
        break;
      
      case 'get_variable':
        ports.add(Port(id: 'value', name: 'Value'));
        break;
      
      case 'transform_data':
        ports.add(Port(id: 'output', name: 'Output'));
        break;
      
      case 'function':
        ports.add(Port(id: 'result', name: 'Result'));
        break;
      
      case 'ai_assist':
      case 'llm_call':
        ports.add(Port(id: 'response', name: 'Response'));
        break;
      
      case 'phone_control':
        ports.add(Port(id: 'result', name: 'Result'));
        break;
      
      case 'notification':
        ports.add(Port(id: 'sent', name: 'Sent'));
        break;
      
      case 'ui_automation':
        ports.add(Port(id: 'result', name: 'Result'));
        break;
    }
    
    return ports;
  }
}
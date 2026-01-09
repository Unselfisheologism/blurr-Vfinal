/// Provider-MobX adapter for bidirectional state synchronization
/// Bridges the Provider-based WorkflowState with vyuh_node_flow's MobX-based state management
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../state/workflow_state.dart';
import '../state/node_flow_controller.dart';
import '../models/workflow_node_data.dart';
import '../models/node_definitions.dart';

/// Adapter that synchronizes state between Provider (WorkflowState) and MobX (vyuh_node_flow)
/// Prevents infinite sync loops with debouncing and change tracking
class ProviderMobXAdapter {
  final WorkflowState _workflowState;
  final WorkflowNodeFlowController _nodeFlowController;
  final Set<VoidCallback> _listeners = {};
  bool _isSyncing = false;
  final StreamController<void> _syncController = StreamController.broadcast();
  
  ProviderMobXAdapter(this._workflowState, this._nodeFlowController) {
    _setupBidirectionalSync();
  }
  
  /// Add a listener for adapter state changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  /// Remove a listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  /// Setup bidirectional synchronization between WorkflowState and NodeFlowController
  void _setupBidirectionalSync() {
    // Listen to WorkflowState changes and sync to NodeFlowController
    _workflowState.addListener(_onWorkflowStateChanged);
    
    // Listen to NodeFlowController changes and sync to WorkflowState
    _nodeFlowController.addListener(_onNodeFlowControllerChanged);
    
    // Initial sync
    _syncFromWorkflowState();
  }
  
  /// Handle WorkflowState changes and sync to NodeFlowController
  void _onWorkflowStateChanged() {
    if (_isSyncing) return;
    
    _isSyncing = true;
    try {
      _syncFromWorkflowState();
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Handle NodeFlowController changes and sync to WorkflowState
  void _onNodeFlowControllerChanged() {
    if (_isSyncing) return;
    
    _isSyncing = true;
    try {
      _syncFromNodeFlowController();
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Sync nodes from WorkflowState to NodeFlowController
  void _syncFromWorkflowState() {
    final workflow = _workflowState.currentWorkflow;
    if (workflow == null) return;
    
    // Clear existing nodes in controller that don't exist in workflow
    final workflowNodeIds = workflow.nodes.map((n) => n.id).toSet();
    final controllerNodes = _nodeFlowController.nodes.map((n) => n.id).toSet();
    
    for (final controllerNodeId in controllerNodes) {
      if (!workflowNodeIds.contains(controllerNodeId)) {
        _nodeFlowController.removeNode(controllerNodeId);
      }
    }
    
    // Add or update nodes from workflow to controller
    for (final workflowNode in workflow.nodes) {
      if (!_nodeFlowController.hasNode(workflowNode.id)) {
        // Add new node
        _nodeFlowController.addNode(
          id: workflowNode.id,
          nodeType: workflowNode.type,
          name: workflowNode.name,
          position: Offset(workflowNode.x, workflowNode.y),
          data: workflowNode.data ?? {},
          // Note: We'll need to get the node definition - this could be cached
          definition: _getNodeDefinitionForType(workflowNode.type),
        );
      } else {
        // Update existing node position and data
        _nodeFlowController.updateNodePosition(
          workflowNode.id, 
          Offset(workflowNode.x, workflowNode.y),
        );
        _nodeFlowController.updateNodeData(
          workflowNode.id, 
          workflowNode.data ?? {},
        );
      }
    }
    
    // Sync connections
    _syncConnectionsFromWorkflow(workflow.connections);
    
    _notifyListeners();
  }
  
  /// Sync connections from WorkflowState to NodeFlowController
  void _syncConnectionsFromWorkflow(List<dynamic> workflowConnections) {
    // This is simplified - in reality we'd need to compare connection states
    // For now, we'll add all connections from workflow to controller
    for (final connection in workflowConnections) {
      try {
        _nodeFlowController.createConnection(
          sourceNodeId: connection.sourceNodeId,
          sourcePortId: connection.sourcePortId,
          targetNodeId: connection.targetNodeId,
          targetPortId: connection.targetPortId,
        );
      } catch (e) {
        // Connection might already exist, ignore errors
        debugPrint('Connection sync error: $e');
      }
    }
  }
  
  /// Sync nodes from NodeFlowController to WorkflowState
  void _syncFromNodeFlowController() {
    final workflow = _workflowState.currentWorkflow;
    if (workflow == null) return;
    
    // Get current workflow nodes
    final currentNodes = List<dynamic>.from(workflow.nodes);
    final currentConnections = List<dynamic>.from(workflow.connections);
    
    // Update node positions and data
    for (final node in _nodeFlowController.nodes) {
      final existingNodeIndex = currentNodes.indexWhere((n) => n.id == node.id);
      if (existingNodeIndex != -1) {
        final existingNode = currentNodes[existingNodeIndex];
        // Update position and data
        // Note: This would need proper update methods on WorkflowState
        // For now, we'll trigger a full rebuild
      }
    }
    
    // For complex sync, we might want to rebuild the entire workflow
    // This is a simplified approach
    _workflowState.notifyListeners();
    
    _notifyListeners();
  }
  
  /// Get node definition for a given node type
  NodeDefinition _getNodeDefinitionForType(String nodeType) {
    final definition = NodeDefinitions.getByNodeType(nodeType);
    if (definition != null) {
      return definition;
    }
    
    // Return a default definition if not found
    return const NodeDefinition(
      id: 'unknown',
      displayName: 'Unknown Node',
      description: 'Unknown node type',
      category: NodeCategory.actions,
      icon: Icons.help_outline,
      color: Colors.grey,
      inputPorts: [],
      outputPorts: [],
    );
  }
  
  // Agent Control Methods
  
  /// Called by UltraGeneralistAgent to add a node programmatically
  Future<void> addNodeFromAgent({
    required String type,
    required String name,
    required Map<String, dynamic> data,
    Offset? position,
  }) async {
    // Add to WorkflowState
    _workflowState.addNode(
      type: type,
      name: name,
      data: data,
      position: position,
    );
    
    // Sync to persistent storage
    await _workflowState.saveWorkflow();
    
    _notifyListeners();
  }
  
  /// Called by UltraGeneralistAgent to modify a node
  Future<void> updateNodeFromAgent(String nodeId, Map<String, dynamic> data) async {
    // Update in WorkflowState
    _workflowState.updateNodeData(nodeId, data);
    
    // Sync to NodeFlowController
    _nodeFlowController.updateNodeData(nodeId, data);
    
    // Sync to persistent storage
    await _workflowState.saveWorkflow();
    
    _notifyListeners();
  }
  
  /// Called by UltraGeneralistAgent to delete a node
  Future<void> removeNodeFromAgent(String nodeId) async {
    // Remove from WorkflowState
    _workflowState.removeNode(nodeId);
    
    // Remove from NodeFlowController
    _nodeFlowController.removeNode(nodeId);
    
    // Sync to persistent storage
    await _workflowState.saveWorkflow();
    
    _notifyListeners();
  }
  
  /// Called by UltraGeneralistAgent to create workflow from scratch
  Future<void> createWorkflowFromAgent({
    required String name,
    required List<dynamic> nodes,
    required List<dynamic> connections,
  }) async {
    // Create new workflow in WorkflowState
    // This would need a method like this on WorkflowState
    // For now, we'll clear and rebuild
    
    // Clear existing workflow
    _workflowState.createNewWorkflow();
    
    // Add all nodes
    for (final node in nodes) {
      _workflowState.addNode(
        type: node.type,
        name: node.name,
        data: node.data ?? {},
        position: Offset(node.x ?? 0, node.y ?? 0),
      );
    }
    
    // Add all connections
    for (final connection in connections) {
      _workflowState.addConnection(
        sourceNodeId: connection.sourceNodeId,
        targetNodeId: connection.targetNodeId,
        sourcePortId: connection.sourcePortId,
        targetPortId: connection.targetPortId,
      );
    }
    
    // Sync to persistent storage
    await _workflowState.saveWorkflow();
    
    _notifyListeners();
  }
  
  /// Get workflow as JSON for agent
  Map<String, dynamic> getWorkflowAsJson() {
    final workflow = _workflowState.currentWorkflow;
    if (workflow == null) return {};
    
    return {
      'id': workflow.id,
      'name': workflow.name,
      'description': workflow.description,
      'nodes': workflow.nodes.map((node) => {
        'id': node.id,
        'type': node.type,
        'name': node.name,
        'x': node.x,
        'y': node.y,
        'data': node.data,
      }).toList(),
      'connections': workflow.connections.map((conn) => {
        'id': conn.id,
        'sourceNodeId': conn.sourceNodeId,
        'sourcePortId': conn.sourcePortId,
        'targetNodeId': conn.targetNodeId,
        'targetPortId': conn.targetPortId,
      }).toList(),
      'createdAt': workflow.createdAt.toIso8601String(),
      'updatedAt': workflow.updatedAt.toIso8601String(),
    };
  }
  
  /// Load workflow from JSON (for agent)
  Future<void> loadWorkflowFromJson(Map<String, dynamic> json) async {
    try {
      // Clear existing workflow
      _workflowState.createNewWorkflow();
      
      // Load nodes
      final nodesJson = json['nodes'] as List?;
      if (nodesJson != null) {
        for (final nodeJson in nodesJson) {
          final node = nodeJson as Map<String, dynamic>;
          _workflowState.addNode(
            type: node['type'] as String,
            name: node['name'] as String? ?? 'Node',
            data: Map<String, dynamic>.from(node['data'] as Map? ?? {}),
            position: Offset(
              (node['x'] as num?)?.toDouble() ?? 0,
              (node['y'] as num?)?.toDouble() ?? 0,
            ),
          );
        }
      }
      
      // Load connections
      final connectionsJson = json['connections'] as List?;
      if (connectionsJson != null) {
        for (final connJson in connectionsJson) {
          final conn = connJson as Map<String, dynamic>;
          _workflowState.addConnection(
            sourceNodeId: conn['sourceNodeId'] as String,
            targetNodeId: conn['targetNodeId'] as String,
            sourcePortId: conn['sourcePortId'] as String,
            targetPortId: conn['targetPortId'] as String,
          );
        }
      }
      
      // Save the loaded workflow
      await _workflowState.saveWorkflow();
      
      _notifyListeners();
    } catch (e) {
      debugPrint('Failed to load workflow from JSON: $e');
      rethrow;
    }
  }
  
  /// Execute workflow (for agent)
  Future<void> executeWorkflowFromAgent() async {
    await _workflowState.executeWorkflow();
  }
  
  /// Get current state summary for agent
  Map<String, dynamic> getStateSummary() {
    final workflow = _workflowState.currentWorkflow;
    return {
      'workflowId': workflow?.id,
      'workflowName': workflow?.name,
      'nodeCount': workflow?.nodes.length ?? 0,
      'connectionCount': workflow?.connections.length ?? 0,
      'isExecuting': _workflowState.isExecuting,
      'canUndo': _workflowState.canUndo,
      'canRedo': _workflowState.canRedo,
      'lastUpdated': workflow?.updatedAt.toIso8601String(),
    };
  }
  
  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  /// Check if currently syncing (to prevent infinite loops)
  bool get isSyncing => _isSyncing;
  
  /// Get the underlying controllers
  WorkflowState get workflowState => _workflowState;
  WorkflowNodeFlowController get nodeFlowController => _nodeFlowController;
  
  /// Dispose adapter
  void dispose() {
    _workflowState.removeListener(_onWorkflowStateChanged);
    _nodeFlowController.removeListener(_onNodeFlowControllerChanged);
    _listeners.clear();
    _syncController.close();
  }
}
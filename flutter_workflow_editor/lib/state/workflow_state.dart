/// Workflow state management with undo/redo
library;

import 'package:flutter/material.dart';
import '../models/workflow.dart';
import '../models/workflow_node.dart';
import '../models/workflow_connection.dart';
import '../services/workflow_execution_engine.dart';
import '../services/platform_bridge.dart';
import 'package:uuid/uuid.dart';

class WorkflowState extends ChangeNotifier {
  final PlatformBridge platformBridge;
  final Uuid _uuid = const Uuid();
  
  Workflow? _currentWorkflow;
  WorkflowNode? _selectedNode;
  WorkflowExecutionEngine? _executionEngine;

  // Undo/Redo stacks
  final List<Workflow> _undoStack = [];
  final List<Workflow> _redoStack = [];
  final int _maxUndoStackSize = 50;
  
  WorkflowState({required this.platformBridge}) {
    _executionEngine = WorkflowExecutionEngine(platformBridge: platformBridge);
    _executionEngine!.addListener(_onExecutionStateChanged);
    _initializeDefaultWorkflow();
  }
  
  // Getters
  Workflow? get currentWorkflow => _currentWorkflow;
  WorkflowNode? get selectedNode => _selectedNode;
  WorkflowExecutionEngine? get executionEngine => _executionEngine;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get isExecuting => _executionEngine?.state == ExecutionState.running;
  
  void _initializeDefaultWorkflow() {
    _currentWorkflow = Workflow(
      id: _uuid.v4(),
      name: 'New Workflow',
      description: '',
      nodes: [],
      connections: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  // Node operations
  void addNode({
    required String type,
    required String name,
    required Map<String, dynamic> data,
    Offset? position,
  }) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    
    final node = WorkflowNode(
      id: _uuid.v4(),
      type: type,
      name: name,
      x: position?.dx ?? 0,
      y: position?.dy ?? 0,
      data: data,
    );
    
    _currentWorkflow = _currentWorkflow!.copyWith(
      nodes: [..._currentWorkflow!.nodes, node],
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  void addNodeFromFlNode(dynamic flNode) {
    addNode(
      type: flNode.prototype.idName,
      name: flNode.prototype.displayName,
      data: {},
      position: flNode.position,
    );
  }
  
  void removeNode(String nodeId) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    
    _currentWorkflow = _currentWorkflow!.copyWith(
      nodes: _currentWorkflow!.nodes.where((n) => n.id != nodeId).toList(),
      connections: _currentWorkflow!.connections
          .where((c) => c.sourceNodeId != nodeId && c.targetNodeId != nodeId)
          .toList(),
      updatedAt: DateTime.now(),
    );
    
    if (_selectedNode?.id == nodeId) {
      _selectedNode = null;
    }
    
    notifyListeners();
  }
  
  void updateNodePosition(String nodeId, Offset position) {
    if (_currentWorkflow == null) return;
    
    final nodeIndex = _currentWorkflow!.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) return;
    
    final updatedNodes = List<WorkflowNode>.from(_currentWorkflow!.nodes);
    updatedNodes[nodeIndex] = updatedNodes[nodeIndex].copyWith(position: position);
    
    _currentWorkflow = _currentWorkflow!.copyWith(
      nodes: updatedNodes,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  void updateNodeData(String nodeId, Map<String, dynamic> data) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    
    final nodeIndex = _currentWorkflow!.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) return;
    
    final updatedNodes = List<WorkflowNode>.from(_currentWorkflow!.nodes);
    final currentData = Map<String, dynamic>.from(updatedNodes[nodeIndex].data);
    currentData.addAll(data);
    
    updatedNodes[nodeIndex] = updatedNodes[nodeIndex].copyWith(data: currentData);
    
    _currentWorkflow = _currentWorkflow!.copyWith(
      nodes: updatedNodes,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  void selectNode(String nodeId) {
    final node = _currentWorkflow?.nodes.firstWhere(
      (n) => n.id == nodeId,
      orElse: () => throw StateError('Node not found'),
    );
    
    _selectedNode = node;
    notifyListeners();
  }
  
  void deselectNode() {
    _selectedNode = null;
    notifyListeners();
  }
  
  // Connection operations
  void addConnection({
    required String sourceNodeId,
    required String targetNodeId,
    required String sourcePortId,
    required String targetPortId,
  }) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    
    final connection = WorkflowConnection(
      id: _uuid.v4(),
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      sourcePortId: sourcePortId,
      targetPortId: targetPortId,
    );
    
    _currentWorkflow = _currentWorkflow!.copyWith(
      connections: [..._currentWorkflow!.connections, connection],
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  void addConnectionFromFlLink(dynamic flLink) {
    addConnection(
      sourceNodeId: flLink.sourceNodeId,
      targetNodeId: flLink.targetNodeId,
      sourcePortId: flLink.sourcePortId,
      targetPortId: flLink.targetPortId,
    );
  }
  
  void removeConnection(String connectionId) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    
    _currentWorkflow = _currentWorkflow!.copyWith(
      connections: _currentWorkflow!.connections
          .where((c) => c.id != connectionId)
          .toList(),
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  // Workflow operations
  void createNewWorkflow() {
    _saveToUndoStack();
    _initializeDefaultWorkflow();
    _selectedNode = null;
    _redoStack.clear();
    notifyListeners();
  }
  
  Future<void> saveWorkflow() async {
    if (_currentWorkflow == null) return;
    
    try {
      await platformBridge.saveWorkflow(
        workflowId: _currentWorkflow!.id,
        workflowData: _currentWorkflow!.toJson(),
      );
    } catch (e) {
      debugPrint('Failed to save workflow: $e');
      rethrow;
    }
  }
  
  Future<void> loadWorkflow(String workflowId) async {
    try {
      final data = await platformBridge.loadWorkflow(workflowId);
      if (data != null) {
        _currentWorkflow = Workflow.fromJson(data);
        _selectedNode = null;
        _undoStack.clear();
        _redoStack.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load workflow: $e');
      rethrow;
    }
  }
  
  Future<void> exportWorkflow() async {
    if (_currentWorkflow == null) return;
    
    try {
      await platformBridge.exportWorkflow(_currentWorkflow!.id);
    } catch (e) {
      debugPrint('Failed to export workflow: $e');
      rethrow;
    }
  }
  
  Future<void> importWorkflow() async {
    try {
      // This would typically use file_picker
      // For now, just a placeholder
      debugPrint('Import workflow not implemented');
    } catch (e) {
      debugPrint('Failed to import workflow: $e');
      rethrow;
    }
  }
  
  // Execution
  Future<void> executeWorkflow() async {
    if (_currentWorkflow == null || _executionEngine == null) return;
    
    try {
      await _executionEngine!.executeWorkflow(_currentWorkflow!);
    } catch (e) {
      debugPrint('Workflow execution failed: $e');
      rethrow;
    }
  }
  
  void stopExecution() {
    _executionEngine?.cancel();
  }
  
  void clearExecutionLogs() {
    _executionEngine?.context?.logs.clear();
    notifyListeners();
  }
  
  void _onExecutionStateChanged() {
    notifyListeners();
  }
  
  // Agent Control Methods
  
  /// Called by UltraGeneralistAgent to add a node programmatically
  Future<void> addNodeFromAgent({
    required String type,
    required String name,
    required Map<String, dynamic> data,
    Offset? position,
  }) async {
    addNode(type: type, name: name, data: data, position: position);
    await saveWorkflow();
  }
  
  /// Called by UltraGeneralistAgent to modify a node
  Future<void> updateNodeFromAgent(String nodeId, Map<String, dynamic> data) async {
    updateNodeData(nodeId, data);
    await saveWorkflow();
  }
  
  /// Called by UltraGeneralistAgent to delete a node
  Future<void> removeNodeFromAgent(String nodeId) async {
    removeNode(nodeId);
    await saveWorkflow();
  }
  
  /// Called by UltraGeneralistAgent to create workflow from scratch
  Future<void> createWorkflowFromAgent({
    required String name,
    required List<dynamic> nodes,
    required List<dynamic> connections,
  }) async {
    _saveToUndoStack();
    
    _currentWorkflow = Workflow(
      id: _uuid.v4(),
      name: name,
      description: '',
      nodes: nodes,
      connections: connections,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await saveWorkflow();
    notifyListeners();
  }
  
  /// Get workflow as JSON for agent
  Map<String, dynamic> getWorkflowAsJson() {
    if (_currentWorkflow == null) return {};
    
    return {
      'id': _currentWorkflow!.id,
      'name': _currentWorkflow!.name,
      'description': _currentWorkflow!.description,
      'nodes': _currentWorkflow!.nodes.map((node) => {
        'id': node.id,
        'type': node.type,
        'name': node.name,
        'x': node.x,
        'y': node.y,
        'data': node.data,
      }).toList(),
      'connections': _currentWorkflow!.connections.map((conn) => {
        'id': conn.id,
        'sourceNodeId': conn.sourceNodeId,
        'sourcePortId': conn.sourcePortId,
        'targetNodeId': conn.targetNodeId,
        'targetPortId': conn.targetPortId,
      }).toList(),
      'createdAt': _currentWorkflow!.createdAt.toIso8601String(),
      'updatedAt': _currentWorkflow!.updatedAt.toIso8601String(),
    };
  }
  
  /// Load workflow from JSON (for agent)
  Future<void> loadWorkflowFromJson(Map<String, dynamic> json) async {
    try {
      _saveToUndoStack();
      
      final nodes = <dynamic>[];
      final nodesJson = json['nodes'] as List?;
      if (nodesJson != null) {
        for (final nodeJson in nodesJson) {
          final node = nodeJson as Map<String, dynamic>;
          nodes.add(WorkflowNode(
            id: node['id'] as String,
            type: node['type'] as String,
            name: node['name'] as String? ?? 'Node',
            x: (node['x'] as num?)?.toDouble() ?? 0,
            y: (node['y'] as num?)?.toDouble() ?? 0,
            data: Map<String, dynamic>.from(node['data'] as Map? ?? {}),
          ));
        }
      }
      
      final connections = <dynamic>[];
      final connectionsJson = json['connections'] as List?;
      if (connectionsJson != null) {
        for (final connJson in connectionsJson) {
          final conn = connJson as Map<String, dynamic>;
          connections.add(WorkflowConnection(
            id: conn['id'] as String,
            sourceNodeId: conn['sourceNodeId'] as String,
            sourcePortId: conn['sourcePortId'] as String,
            targetNodeId: conn['targetNodeId'] as String,
            targetPortId: conn['targetPortId'] as String,
          ));
        }
      }
      
      _currentWorkflow = Workflow(
        id: json['id'] as String? ?? _uuid.v4(),
        name: json['name'] as String? ?? 'Loaded Workflow',
        description: json['description'] as String? ?? '',
        nodes: nodes,
        connections: connections,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _selectedNode = null;
      _redoStack.clear();
      
      await saveWorkflow();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load workflow from JSON: $e');
      rethrow;
    }
  }
  
  /// Execute workflow (for agent)
  Future<void> executeWorkflowFromAgent() async {
    await executeWorkflow();
  }
  
  /// Get current state summary for agent
  Map<String, dynamic> getStateSummary() {
    return {
      'workflowId': _currentWorkflow?.id,
      'workflowName': _currentWorkflow?.name,
      'nodeCount': _currentWorkflow?.nodes.length ?? 0,
      'connectionCount': _currentWorkflow?.connections.length ?? 0,
      'isExecuting': isExecuting,
      'canUndo': canUndo,
      'canRedo': canRedo,
      'lastUpdated': _currentWorkflow?.updatedAt.toIso8601String(),
    };
  }
  
  // Undo/Redo
  void _saveToUndoStack() {
    if (_currentWorkflow == null) return;
    
    _undoStack.add(_currentWorkflow!);
    if (_undoStack.length > _maxUndoStackSize) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }
  
  void undo() {
    if (!canUndo) return;
    
    _redoStack.add(_currentWorkflow!);
    _currentWorkflow = _undoStack.removeLast();
    _selectedNode = null;
    notifyListeners();
  }
  
  void redo() {
    if (!canRedo) return;
    
    _undoStack.add(_currentWorkflow!);
    _currentWorkflow = _redoStack.removeLast();
    _selectedNode = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _executionEngine?.removeListener(_onExecutionStateChanged);
    _executionEngine?.dispose();
    super.dispose();
  }
}

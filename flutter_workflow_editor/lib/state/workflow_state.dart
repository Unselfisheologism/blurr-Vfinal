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
    // Legacy method - kept for compatibility but no longer used
    addNode(
      type: flNode.prototype.idName,
      name: flNode.prototype.displayName,
      data: {},
      position: flNode.position,
    );
  }

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
    required List<WorkflowNode> nodes,
    required List<WorkflowConnection> connections,
  }) async {
    _currentWorkflow = Workflow(
      id: _uuid.v4(),
      name: name,
      description: 'Created by agent',
      nodes: nodes,
      connections: connections,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await saveWorkflow();
    notifyListeners();
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

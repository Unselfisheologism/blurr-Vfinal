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

  /// Replace the current workflow from the editor/controller without recording
  /// an undo action.
  ///
  /// This is used by the vyuh_node_flow adapter when syncing changes from the
  /// canvas back into the Provider state.
  void setCurrentWorkflowFromEditor(Workflow workflow) {
    _currentWorkflow = workflow;

    if (_selectedNode != null) {
      final selectedId = _selectedNode!.id;
      final index = workflow.nodes.indexWhere((n) => n.id == selectedId);
      _selectedNode = index == -1 ? null : workflow.nodes[index];
    }

    notifyListeners();
  }
  
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

  Offset _calculateNextNodePosition() {
    final nodeCount = _currentWorkflow?.nodes.length ?? 0;

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

  void _refreshSelectedNode() {
    if (_currentWorkflow == null) {
      _selectedNode = null;
      return;
    }

    if (_selectedNode == null) return;

    final selectedId = _selectedNode!.id;
    final index = _currentWorkflow!.nodes.indexWhere((n) => n.id == selectedId);
    _selectedNode = index == -1 ? null : _currentWorkflow!.nodes[index];
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
    
    final resolvedPosition = position ?? _calculateNextNodePosition();

    final node = WorkflowNode(
      id: _uuid.v4(),
      type: type,
      name: name,
      x: resolvedPosition.dx,
      y: resolvedPosition.dy,
      data: data,
    );
    
    _currentWorkflow = _currentWorkflow!.copyWith(
      nodes: [..._currentWorkflow!.nodes, node],
      updatedAt: DateTime.now(),
    );

    _refreshSelectedNode();
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

    _refreshSelectedNode();
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

    _refreshSelectedNode();
    notifyListeners();
  }
  
  void updateNodeData(String nodeId, Map<String, dynamic> data) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    
    final nodeIndex = _currentWorkflow!.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) return;
    
    final updatedNodes = List<WorkflowNode>.from(_currentWorkflow!.nodes);

    final patch = Map<String, dynamic>.from(data);
    final newName = patch.remove('name') as String?;

    final currentNode = updatedNodes[nodeIndex];
    final currentData = Map<String, dynamic>.from(currentNode.data);
    currentData.addAll(patch);

    updatedNodes[nodeIndex] = currentNode.copyWith(
      name: newName,
      data: currentData,
    );

    _currentWorkflow = _currentWorkflow!.copyWith(
      nodes: updatedNodes,
      updatedAt: DateTime.now(),
    );

    _refreshSelectedNode();
    notifyListeners();
  }
  
  void selectNode(String nodeId) {
    if (_currentWorkflow == null) return;

    final index = _currentWorkflow!.nodes.indexWhere((n) => n.id == nodeId);
    if (index == -1) return;

    _selectedNode = _currentWorkflow!.nodes[index];
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

    _refreshSelectedNode();
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

    _refreshSelectedNode();
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
  
  Future<String> exportWorkflow() async {
    if (_currentWorkflow == null) {
      throw Exception('No workflow to export');
    }
    
    try {
      // Get workflow JSON from platform bridge
      final jsonString = await platformBridge.exportWorkflow(_currentWorkflow!.id);
      return jsonString;
    } catch (e) {
      debugPrint('Failed to export workflow: $e');
      rethrow;
    }
  }
  
  Future<void> importWorkflow(String jsonString) async {
    try {
      // Import workflow via platform bridge and get new workflow ID
      final newWorkflowId = await platformBridge.importWorkflow(jsonString);
      
      // Load the newly imported workflow
      await loadWorkflow(newWorkflowId);
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

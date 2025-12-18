/// Workflow state management
library;

import 'package:flutter/foundation.dart';
import '../models/workflow.dart';
import '../models/workflow_node.dart';
import '../models/workflow_connection.dart';
import '../services/storage_service.dart';
import '../services/execution_engine.dart';
import 'package:uuid/uuid.dart';

class WorkflowState extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ExecutionEngine _executionEngine = ExecutionEngine();
  final Uuid _uuid = const Uuid();

  Workflow? _currentWorkflow;
  WorkflowNode? _selectedNode;
  WorkflowConnection? _selectedConnection;
  
  // Undo/redo stacks
  final List<Workflow> _undoStack = [];
  final List<Workflow> _redoStack = [];
  final int _maxUndoHistory = 50;

  // Execution state
  bool _isExecuting = false;
  Map<String, dynamic> _executionResults = {};
  List<String> _executionLogs = [];

  // Getters
  Workflow? get currentWorkflow => _currentWorkflow;
  WorkflowNode? get selectedNode => _selectedNode;
  WorkflowConnection? get selectedConnection => _selectedConnection;
  bool get isExecuting => _isExecuting;
  Map<String, dynamic> get executionResults => _executionResults;
  List<String> get executionLogs => _executionLogs;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Initialize with a new or existing workflow
  Future<void> initialize({Workflow? workflow}) async {
    if (workflow != null) {
      _currentWorkflow = workflow;
    } else {
      _currentWorkflow = Workflow(
        id: _uuid.v4(),
        name: 'New Workflow',
        description: 'Untitled workflow',
      );
    }
    notifyListeners();
  }

  /// Load workflow from storage
  Future<void> loadWorkflow(String workflowId) async {
    try {
      final workflow = await _storageService.loadWorkflow(workflowId);
      if (workflow != null) {
        _currentWorkflow = workflow;
        _clearUndoRedo();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading workflow: $e');
    }
  }

  /// Save current workflow
  Future<void> saveWorkflow() async {
    if (_currentWorkflow == null) return;
    
    try {
      await _storageService.saveWorkflow(_currentWorkflow!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving workflow: $e');
    }
  }

  /// Create a new workflow
  void createNewWorkflow() {
    _saveToUndoStack();
    _currentWorkflow = Workflow(
      id: _uuid.v4(),
      name: 'New Workflow',
      description: 'Untitled workflow',
    );
    _selectedNode = null;
    _selectedConnection = null;
    notifyListeners();
  }

  /// Add a node to the workflow
  void addNode(WorkflowNode node) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    _currentWorkflow!.addNode(node);
    _autoLayoutVertical();
    notifyListeners();
  }

  /// Remove a node
  void removeNode(String nodeId) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    _currentWorkflow!.removeNode(nodeId);
    
    if (_selectedNode?.id == nodeId) {
      _selectedNode = null;
    }
    
    notifyListeners();
  }

  /// Update node position
  void updateNodePosition(String nodeId, double x, double y) {
    if (_currentWorkflow == null) return;
    
    final nodeIndex = _currentWorkflow!.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex != -1) {
      _currentWorkflow!.nodes[nodeIndex].x = x;
      _currentWorkflow!.nodes[nodeIndex].y = y;
      notifyListeners();
    }
  }

  /// Update node parameters
  void updateNodeParameters(String nodeId, Map<String, dynamic> parameters) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    final nodeIndex = _currentWorkflow!.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex != -1) {
      final node = _currentWorkflow!.nodes[nodeIndex];
      _currentWorkflow!.nodes[nodeIndex] = node.copyWith(
        parameters: {...node.parameters, ...parameters},
      );
      notifyListeners();
    }
  }

  /// Add a connection
  void addConnection(WorkflowConnection connection) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    _currentWorkflow!.addConnection(connection);
    notifyListeners();
  }

  /// Remove a connection
  void removeConnection(String connectionId) {
    if (_currentWorkflow == null) return;
    
    _saveToUndoStack();
    _currentWorkflow!.removeConnection(connectionId);
    
    if (_selectedConnection?.id == connectionId) {
      _selectedConnection = null;
    }
    
    notifyListeners();
  }

  /// Select a node
  void selectNode(String? nodeId) {
    if (nodeId == null) {
      _selectedNode = null;
    } else {
      _selectedNode = _currentWorkflow?.nodes.firstWhere(
        (n) => n.id == nodeId,
        orElse: () => _selectedNode!,
      );
    }
    _selectedConnection = null;
    notifyListeners();
  }

  /// Select a connection
  void selectConnection(String? connectionId) {
    if (connectionId == null) {
      _selectedConnection = null;
    } else {
      _selectedConnection = _currentWorkflow?.connections.firstWhere(
        (c) => c.id == connectionId,
        orElse: () => _selectedConnection!,
      );
    }
    _selectedNode = null;
    notifyListeners();
  }

  /// Execute the workflow
  Future<void> executeWorkflow({bool debugMode = false}) async {
    if (_currentWorkflow == null || _isExecuting) return;

    _isExecuting = true;
    _executionResults = {};
    _executionLogs = [];
    notifyListeners();

    try {
      // Validate workflow first
      final errors = _currentWorkflow!.validate();
      if (errors.isNotEmpty) {
        _executionLogs.addAll(errors.map((e) => 'ERROR: $e'));
        _isExecuting = false;
        notifyListeners();
        return;
      }

      // Execute workflow
      _executionLogs.add('Starting workflow execution: ${_currentWorkflow!.name}');
      
      final results = await _executionEngine.execute(
        _currentWorkflow!,
        onNodeStart: (nodeId) {
          _executionLogs.add('Executing node: $nodeId');
          _updateNodeState(nodeId, NodeExecutionState.running);
        },
        onNodeComplete: (nodeId, result) {
          _executionLogs.add('Node $nodeId completed');
          _executionResults[nodeId] = result;
          _updateNodeState(nodeId, NodeExecutionState.success, result);
        },
        onNodeError: (nodeId, error) {
          _executionLogs.add('ERROR in node $nodeId: $error');
          _updateNodeState(nodeId, NodeExecutionState.error, null, error);
        },
      );

      _executionLogs.add('Workflow execution completed');
    } catch (e) {
      _executionLogs.add('FATAL ERROR: $e');
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  /// Stop workflow execution
  void stopExecution() {
    _executionEngine.stop();
    _isExecuting = false;
    notifyListeners();
  }

  /// Clear execution results
  void clearExecutionResults() {
    _executionResults = {};
    _executionLogs = [];
    
    // Reset node execution states
    if (_currentWorkflow != null) {
      for (var node in _currentWorkflow!.nodes) {
        node.executionState = NodeExecutionState.idle;
        node.executionResult = null;
        node.executionError = null;
      }
    }
    
    notifyListeners();
  }

  /// Undo last change
  void undo() {
    if (_undoStack.isEmpty) return;
    
    if (_currentWorkflow != null) {
      _redoStack.add(_currentWorkflow!);
    }
    
    _currentWorkflow = _undoStack.removeLast();
    notifyListeners();
  }

  /// Redo last undone change
  void redo() {
    if (_redoStack.isEmpty) return;
    
    if (_currentWorkflow != null) {
      _undoStack.add(_currentWorkflow!);
    }
    
    _currentWorkflow = _redoStack.removeLast();
    notifyListeners();
  }

  /// Auto-layout nodes vertically (top to bottom)
  void _autoLayoutVertical() {
    if (_currentWorkflow == null || _currentWorkflow!.nodes.isEmpty) return;

    const double horizontalSpacing = 300.0;
    const double verticalSpacing = 150.0;
    const double startX = 400.0;
    double currentY = 100.0;

    // Group nodes by level (depth in graph)
    final levels = <int, List<WorkflowNode>>{};
    final nodeDepths = <String, int>{};

    // Calculate depth for each node
    void calculateDepth(String nodeId, int depth) {
      if (nodeDepths.containsKey(nodeId)) {
        nodeDepths[nodeId] = depth > nodeDepths[nodeId]! ? depth : nodeDepths[nodeId]!;
        return;
      }

      nodeDepths[nodeId] = depth;

      final outgoingConnections = _currentWorkflow!.connections.where(
        (conn) => conn.sourceNodeId == nodeId,
      );

      for (final conn in outgoingConnections) {
        calculateDepth(conn.targetNodeId, depth + 1);
      }
    }

    // Start from trigger nodes (nodes with no incoming connections)
    final triggerNodes = _currentWorkflow!.nodes.where((node) {
      return !_currentWorkflow!.connections.any((conn) => conn.targetNodeId == node.id);
    });

    for (final node in triggerNodes) {
      calculateDepth(node.id, 0);
    }

    // Group by depth
    for (final node in _currentWorkflow!.nodes) {
      final depth = nodeDepths[node.id] ?? 0;
      levels.putIfAbsent(depth, () => []);
      levels[depth]!.add(node);
    }

    // Position nodes
    for (final depth in levels.keys.toList()..sort()) {
      final nodesAtLevel = levels[depth]!;
      final levelWidth = nodesAtLevel.length * horizontalSpacing;
      double startXForLevel = startX - (levelWidth / 2);

      for (int i = 0; i < nodesAtLevel.length; i++) {
        final node = nodesAtLevel[i];
        node.x = startXForLevel + (i * horizontalSpacing);
        node.y = currentY;
      }

      currentY += verticalSpacing;
    }
  }

  /// Update node execution state
  void _updateNodeState(
    String nodeId,
    NodeExecutionState state, [
    dynamic result,
    String? error,
  ]) {
    if (_currentWorkflow == null) return;

    final nodeIndex = _currentWorkflow!.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex != -1) {
      final node = _currentWorkflow!.nodes[nodeIndex];
      node.executionState = state;
      node.executionResult = result;
      node.executionError = error;
      notifyListeners();
    }
  }

  /// Save current state to undo stack
  void _saveToUndoStack() {
    if (_currentWorkflow == null) return;

    _undoStack.add(_currentWorkflow!);
    
    if (_undoStack.length > _maxUndoHistory) {
      _undoStack.removeAt(0);
    }
    
    _redoStack.clear();
  }

  /// Clear undo/redo history
  void _clearUndoRedo() {
    _undoStack.clear();
    _redoStack.clear();
  }

  @override
  void dispose() {
    _executionEngine.dispose();
    super.dispose();
  }
}

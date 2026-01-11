/// Workflow execution engine with async support and data flow
/// Orchestrates node execution with state management and error handling
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/workflow.dart';
import '../models/workflow_node.dart';
import 'platform_bridge.dart';

/// Execution state for tracking workflow runs
enum ExecutionState {
  idle,
  running,
  paused,
  completed,
  failed,
  cancelled,
}

/// Execution log entry
class ExecutionLog {
  final DateTime timestamp;
  final String nodeId;
  final String nodeName;
  final ExecutionLogLevel level;
  final String message;
  final dynamic data;
  
  ExecutionLog({
    required this.timestamp,
    required this.nodeId,
    required this.nodeName,
    required this.level,
    required this.message,
    this.data,
  });
}

enum ExecutionLogLevel {
  debug,
  info,
  warning,
  error,
}

/// Result of node execution
class NodeExecutionResult {
  final bool success;
  final dynamic output;
  final String? error;
  final Map<String, dynamic> metadata;
  
  NodeExecutionResult({
    required this.success,
    this.output,
    this.error,
    this.metadata = const {},
  });
  
  factory NodeExecutionResult.success(dynamic output, {Map<String, dynamic>? metadata}) {
    return NodeExecutionResult(
      success: true,
      output: output,
      metadata: metadata ?? {},
    );
  }
  
  factory NodeExecutionResult.failure(String error, {Map<String, dynamic>? metadata}) {
    return NodeExecutionResult(
      success: false,
      error: error,
      metadata: metadata ?? {},
    );
  }
}

/// Workflow execution context
class ExecutionContext {
  final Map<String, dynamic> variables = {};
  final Map<String, dynamic> nodeOutputs = {};
  final List<ExecutionLog> logs = [];
  final DateTime startTime;
  DateTime? endTime;
  
  ExecutionContext({
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();
  
  void setVariable(String key, dynamic value) {
    variables[key] = value;
  }
  
  dynamic getVariable(String key, [dynamic defaultValue]) {
    return variables[key] ?? defaultValue;
  }
  
  void setNodeOutput(String nodeId, dynamic output) {
    nodeOutputs[nodeId] = output;
  }
  
  dynamic getNodeOutput(String nodeId) {
    return nodeOutputs[nodeId];
  }
  
  void addLog(ExecutionLog log) {
    logs.add(log);
  }
  
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}

/// Main workflow execution engine
class WorkflowExecutionEngine extends ChangeNotifier {
  final PlatformBridge platformBridge;
  
  ExecutionState _state = ExecutionState.idle;
  ExecutionContext? _context;
  String? _currentNodeId;
  
  final StreamController<ExecutionLog> _logController = StreamController<ExecutionLog>.broadcast();
  final StreamController<String> _nodeExecutionController = StreamController<String>.broadcast();
  
  WorkflowExecutionEngine({required this.platformBridge});
  
  ExecutionState get state => _state;
  ExecutionContext? get context => _context;
  String? get currentNodeId => _currentNodeId;
  Stream<ExecutionLog> get logStream => _logController.stream;
  Stream<String> get nodeExecutionStream => _nodeExecutionController.stream;
  
  /// Execute a workflow
  Future<ExecutionContext> executeWorkflow(
    Workflow workflow, {
    Map<String, dynamic>? initialVariables,
  }) async {
    if (_state == ExecutionState.running) {
      throw StateError('Workflow is already running');
    }
    
    _state = ExecutionState.running;
    _context = ExecutionContext();
    
    // Set initial variables
    if (initialVariables != null) {
      _context!.variables.addAll(initialVariables);
    }
    
    _log(
      '',
      'Workflow',
      ExecutionLogLevel.info,
      'Starting workflow: ${workflow.name}',
    );
    
    notifyListeners();
    
    try {
      // Find trigger nodes (nodes with no incoming connections)
      final triggerNodes = _findTriggerNodes(workflow);
      
      if (triggerNodes.isEmpty) {
        throw Exception('No trigger nodes found in workflow');
      }
      
      // Execute from each trigger
      for (final triggerNode in triggerNodes) {
        await _executeNode(triggerNode, workflow, input: null);
      }
      
      _state = ExecutionState.completed;
      _context!.endTime = DateTime.now();
      
      _log(
        '',
        'Workflow',
        ExecutionLogLevel.info,
        'Workflow completed in ${_context!.duration.inMilliseconds}ms',
      );
    } catch (e, stackTrace) {
      _state = ExecutionState.failed;
      _context!.endTime = DateTime.now();
      
      _log(
        '',
        'Workflow',
        ExecutionLogLevel.error,
        'Workflow failed: $e',
        {'stackTrace': stackTrace.toString()},
      );
      
      rethrow;
    } finally {
      _currentNodeId = null;
      notifyListeners();
    }
    
    return _context!;
  }
  
  /// Execute a single node
  Future<NodeExecutionResult> _executeNode(
    WorkflowNode node,
    Workflow workflow, {
    required dynamic input,
  }) async {
    _currentNodeId = node.id;
    _nodeExecutionController.add(node.id);

    _context?.setVariable('input', input);

    _log(
      node.id,
      node.name,
      ExecutionLogLevel.info,
      'Executing node: ${node.type}',
    );

    notifyListeners();

    try {
      // Execute based on node type
      final result = await _executeNodeByType(node, workflow, input: input);

      // Store output
      _context!.setNodeOutput(node.id, result.output);

      if (result.success) {
        _log(
          node.id,
          node.name,
          ExecutionLogLevel.info,
          'Node completed successfully',
          result.output,
        );

        // Loop handles execution of its outgoing edges internally.
        if (node.type != 'loop') {
          await _executeConnectedNodes(node, workflow, result);
        }
      } else {
        _log(
          node.id,
          node.name,
          ExecutionLogLevel.error,
          'Node failed: ${result.error}',
        );
      }

      return result;
    } catch (e, stackTrace) {
      _log(
        node.id,
        node.name,
        ExecutionLogLevel.error,
        'Node execution error: $e',
        {'stackTrace': stackTrace.toString()},
      );

      return NodeExecutionResult.failure(e.toString());
    }
  }

  /// Execute node by its type
  Future<NodeExecutionResult> _executeNodeByType(
    WorkflowNode node,
    Workflow workflow, {
    required dynamic input,
  }) async {
    switch (node.type) {
      case 'manual_trigger':
        return NodeExecutionResult.success({'triggered': true});
      
      case 'unified_shell':
        return await _executeUnifiedShell(node);
      
      case 'composio_action':
        return await _executeComposioAction(node);
      
      case 'http_request':
        return await _executeHttpRequest(node);
      
      case 'if_else':
        return await _executeIfElse(node, input);

      case 'switch':
        return await _executeSwitch(node);

      case 'loop':
        return await _executeLoop(node, workflow, input: input);

      case 'output':
        return _executeOutput(node, input);
      
      case 'set_variable':
        return _executeSetVariable(node);
      
      case 'get_variable':
        return _executeGetVariable(node);
      
      case 'transform_data':
        return _executeTransformData(node);
      
      default:
        return NodeExecutionResult.failure('Unknown node type: ${node.type}');
    }
  }
  
  /// Execute Unified Shell node
  Future<NodeExecutionResult> _executeUnifiedShell(WorkflowNode node) async {
    final code = node.data['code'] as String? ?? '';
    final language = node.data['language'] as String? ?? 'auto';
    final timeout = node.data['timeout'] as int? ?? 30;
    
    if (code.isEmpty) {
      return NodeExecutionResult.failure('No code provided');
    }
    
    try {
      final result = await platformBridge.executeUnifiedShell(
        code: code,
        language: language,
        timeout: timeout,
      );
      
      return NodeExecutionResult.success(result);
    } catch (e) {
      return NodeExecutionResult.failure('Shell execution failed: $e');
    }
  }
  
  /// Execute Composio action node
  Future<NodeExecutionResult> _executeComposioAction(WorkflowNode node) async {
    final toolId = node.data['tool'] as String?;
    final actionId = node.data['action'] as String?;
    final parameters = node.data['parameters'] as Map<String, dynamic>? ?? {};
    
    if (toolId == null || actionId == null) {
      return NodeExecutionResult.failure('Tool or action not selected');
    }
    
    try {
      final result = await platformBridge.executeComposioAction(
        toolId: toolId,
        actionId: actionId,
        parameters: parameters,
      );
      
      return NodeExecutionResult.success(result);
    } catch (e) {
      return NodeExecutionResult.failure('Composio action failed: $e');
    }
  }
  
  /// Execute HTTP request node
  Future<NodeExecutionResult> _executeHttpRequest(WorkflowNode node) async {
    final url = node.data['url'] as String?;
    final method = node.data['method'] as String? ?? 'GET';
    final headers = node.data['headers'] as Map<String, String>? ?? {};
    final body = node.data['body'];
    
    if (url == null || url.isEmpty) {
      return NodeExecutionResult.failure('URL not provided');
    }
    
    try {
      final result = await platformBridge.executeHttpRequest(
        url: url,
        method: method,
        headers: headers,
        body: body,
      );
      
      return NodeExecutionResult.success(result);
    } catch (e) {
      return NodeExecutionResult.failure('HTTP request failed: $e');
    }
  }
  
  /// Execute IF/ELSE node
  Future<NodeExecutionResult> _executeIfElse(WorkflowNode node, dynamic input) async {
    final expression = node.data['expression'] as String? ?? 'true';

    try {
      // Evaluate expression with context
      final result = _evaluateExpression(expression, {'input': input});
      return NodeExecutionResult.success(
        result,
        metadata: {'branch': result ? 'true' : 'false'},
      );
    } catch (e) {
      return NodeExecutionResult.failure('Expression evaluation failed: $e');
    }
  }

  /// Execute Output node
  NodeExecutionResult _executeOutput(WorkflowNode node, dynamic input) {
    return NodeExecutionResult.success(input);
  }
  
  /// Execute Switch node
  Future<NodeExecutionResult> _executeSwitch(WorkflowNode node) async {
    final value = node.data['value'];
    final cases = node.data['cases'] as List? ?? [];
    
    for (var i = 0; i < cases.length; i++) {
      final caseData = cases[i] as Map<String, dynamic>;
      final expression = caseData['expression'] as String;
      
      if (_evaluateExpression(expression, {'value': value})) {
        return NodeExecutionResult.success(
          value,
          metadata: {'matchedCase': 'case${i + 1}'},
        );
      }
    }
    
    return NodeExecutionResult.success(
      value,
      metadata: {'matchedCase': 'default'},
    );
  }
  
  /// Execute Loop node
  Future<NodeExecutionResult> _executeLoop(
    WorkflowNode node,
    Workflow workflow, {
    required dynamic input,
  }) async {
    final itemsFromNode = node.data['items'] as List?;
    final items = itemsFromNode ?? (input is List ? input : const []);

    final results = <dynamic>[];

    final eachConnections = workflow.connections
        .where((c) => c.sourceNodeId == node.id && c.sourcePortId == 'each')
        .toList();

    final completedConnections = workflow.connections
        .where((c) => c.sourceNodeId == node.id && c.sourcePortId == 'completed')
        .toList();

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      results.add(item);

      _context!.setVariable('currentItem', item);
      _context!.setVariable('index', index);
      _context!.setVariable('total', items.length);

      for (final connection in eachConnections) {
        final targetNode = workflow.nodes.firstWhere(
          (n) => n.id == connection.targetNodeId,
        );

        await _executeNode(targetNode, workflow, input: item);
      }
    }

    for (final connection in completedConnections) {
      final targetNode = workflow.nodes.firstWhere(
        (n) => n.id == connection.targetNodeId,
      );

      await _executeNode(targetNode, workflow, input: results);
    }

    return NodeExecutionResult.success(
      results,
      metadata: {'iterations': items.length},
    );
  }
  
  /// Execute Set Variable node
  NodeExecutionResult _executeSetVariable(WorkflowNode node) {
    final key = node.data['key'] as String?;
    final value = node.data['value'];
    
    if (key == null || key.isEmpty) {
      return NodeExecutionResult.failure('Variable key not provided');
    }
    
    _context!.setVariable(key, value);
    return NodeExecutionResult.success({'key': key, 'value': value});
  }
  
  /// Execute Get Variable node
  NodeExecutionResult _executeGetVariable(WorkflowNode node) {
    final key = node.data['key'] as String?;
    
    if (key == null || key.isEmpty) {
      return NodeExecutionResult.failure('Variable key not provided');
    }
    
    final value = _context!.getVariable(key);
    return NodeExecutionResult.success(value);
  }
  
  /// Execute Transform Data node
  NodeExecutionResult _executeTransformData(WorkflowNode node) {
    final inputData = node.data['input'];
    final mappings = node.data['mappings'] as Map<String, String>? ?? {};
    
    final output = <String, dynamic>{};
    
    for (final entry in mappings.entries) {
      try {
        output[entry.key] = _evaluateExpression(entry.value, {'input': inputData});
      } catch (e) {
        return NodeExecutionResult.failure('Transform failed for ${entry.key}: $e');
      }
    }
    
    return NodeExecutionResult.success(output);
  }
  
  /// Execute connected nodes after current node
  Future<void> _executeConnectedNodes(
    WorkflowNode node,
    Workflow workflow,
    NodeExecutionResult result,
  ) async {
    var outgoingConnections = workflow.connections
        .where((c) => c.sourceNodeId == node.id)
        .toList();

    // Respect branching for IF/ELSE using port IDs ('true' / 'false').
    if (node.type == 'if_else') {
      final branch = result.metadata['branch'] as String?;
      if (branch != null) {
        outgoingConnections = outgoingConnections
            .where((c) => c.sourcePortId == branch)
            .toList();
      }
    }

    for (final connection in outgoingConnections) {
      final targetNode = workflow.nodes.firstWhere(
        (n) => n.id == connection.targetNodeId,
      );

      await _executeNode(targetNode, workflow, input: result.output);
    }
  }
  
  /// Find trigger nodes (no incoming connections)
  List<WorkflowNode> _findTriggerNodes(Workflow workflow) {
    final hasIncoming = workflow.connections
        .map((c) => c.targetNodeId)
        .toSet();
    
    return workflow.nodes
        .where((n) => !hasIncoming.contains(n.id))
        .toList();
  }
  
  /// Evaluate expression (simplified - use expressions package in production)
  bool _evaluateExpression(String expression, [Map<String, dynamic>? context]) {
    // Simplified evaluation - in production, use expressions package
    // For now, just check basic conditions
    
    final combinedContext = {
      ..._context!.variables,
      if (context != null) ...context,
    };
    
    // Very basic evaluation
    if (expression == 'true') return true;
    if (expression == 'false') return false;
    
    // TODO: Implement proper expression evaluation with expressions package
    return true;
  }
  
  /// Log execution event
  void _log(
    String nodeId,
    String nodeName,
    ExecutionLogLevel level,
    String message, [
    dynamic data,
  ]) {
    final log = ExecutionLog(
      timestamp: DateTime.now(),
      nodeId: nodeId,
      nodeName: nodeName,
      level: level,
      message: message,
      data: data,
    );
    
    _context?.addLog(log);
    _logController.add(log);
  }
  
  /// Cancel execution
  void cancel() {
    if (_state == ExecutionState.running) {
      _state = ExecutionState.cancelled;
      _context?.endTime = DateTime.now();
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _logController.close();
    _nodeExecutionController.close();
    super.dispose();
  }
}

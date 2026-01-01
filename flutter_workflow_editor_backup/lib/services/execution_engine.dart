/// Workflow execution engine
/// Handles workflow execution with async support for Composio/MCP
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/workflow.dart';
import '../models/workflow_node.dart';
import '../models/workflow_connection.dart';
import '../state/app_state.dart';

typedef NodeStartCallback = void Function(String nodeId);
typedef NodeCompleteCallback = void Function(String nodeId, dynamic result);
typedef NodeErrorCallback = void Function(String nodeId, String error);

class ExecutionEngine {
  bool _isRunning = false;
  bool _shouldStop = false;
  
  AppState? _appState;
  
  /// Set app state for Composio/MCP execution
  void setAppState(AppState appState) {
    _appState = appState;
  }

  /// Execute a workflow
  Future<Map<String, dynamic>> execute(
    Workflow workflow, {
    NodeStartCallback? onNodeStart,
    NodeCompleteCallback? onNodeComplete,
    NodeErrorCallback? onNodeError,
  }) async {
    if (_isRunning) {
      throw Exception('Execution already in progress');
    }

    _isRunning = true;
    _shouldStop = false;

    final results = <String, dynamic>{};
    final context = ExecutionContext();

    try {
      // Get execution order (vertical flow, top to bottom)
      final executionOrder = workflow.getExecutionOrder();

      for (final node in executionOrder) {
        if (_shouldStop) break;
        if (node.disabled) continue;

        onNodeStart?.call(node.id);

        try {
          // Execute node based on type
          final result = await _executeNode(node, context);
          results[node.id] = result;
          context.setNodeResult(node.id, result);

          onNodeComplete?.call(node.id, result);

          // Check if we should continue based on conditions
          if (!_shouldContinue(node, result, workflow)) {
            break;
          }
        } catch (e) {
          final error = e.toString();
          results[node.id] = {'error': error};
          onNodeError?.call(node.id, error);

          // Handle error nodes
          if (!await _handleError(node, error, workflow, context)) {
            rethrow;
          }
        }
      }
    } finally {
      _isRunning = false;
    }

    return results;
  }

  /// Execute a single node
  Future<dynamic> _executeNode(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    switch (node.type) {
      case NodeType.trigger:
      case NodeType.manual:
        return _executeTrigger(node, context);

      case NodeType.schedule:
        return _executeScheduleTrigger(node, context);

      case NodeType.webhook:
        return _executeWebhookTrigger(node, context);

      case NodeType.composioAction:
        return await _executeComposioAction(node, context);

      case NodeType.mcpAction:
        return await _executeMcpAction(node, context);

      case NodeType.googleWorkspaceAction:
        return await _executeGoogleWorkspaceAction(node, context);

      // System-level actions
      case NodeType.systemToolAction:
      case NodeType.uiAutomationAction:
      case NodeType.notificationAction:
      case NodeType.phoneControlAction:
      case NodeType.accessibilityAction:
        return await _executeSystemToolAction(node, context);

      case NodeType.httpRequest:
        return await _executeHttpRequest(node, context);

      case NodeType.code:
        return await _executeCode(node, context);

      case NodeType.condition:
      case NodeType.ifElse:
        return _executeCondition(node, context);

      case NodeType.switch_:
        return _executeSwitch(node, context);

      case NodeType.loop:
        return await _executeLoop(node, context);

      case NodeType.setVariable:
        return _setVariable(node, context);

      case NodeType.getVariable:
        return _getVariable(node, context);

      case NodeType.function_:
        return _executeFunction(node, context);

      default:
        throw Exception('Unknown node type: ${node.type}');
    }
  }

  /// Execute trigger node (manual start)
  dynamic _executeTrigger(WorkflowNode node, ExecutionContext context) {
    return {
      'triggered': true,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'manual',
    };
  }

  /// Execute schedule trigger
  dynamic _executeScheduleTrigger(WorkflowNode node, ExecutionContext context) {
    // Schedule triggers are handled by native layer
    return {
      'triggered': true,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'schedule',
      'schedule': node.parameters['schedule'],
    };
  }

  /// Execute webhook trigger
  dynamic _executeWebhookTrigger(WorkflowNode node, ExecutionContext context) {
    // Webhook triggers receive data from native layer
    return {
      'triggered': true,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'webhook',
      'data': node.parameters['webhookData'],
    };
  }

  /// Execute Composio action
  Future<dynamic> _executeComposioAction(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    if (_appState == null) {
      throw Exception('AppState not initialized');
    }

    final toolId = node.parameters['tool'] as String?;
    final actionName = node.parameters['action'] as String?;

    if (toolId == null || actionName == null) {
      throw Exception('Composio action requires tool and action parameters');
    }

    // Resolve parameters with variables/expressions
    final parameters = _resolveParameters(node.parameters['parameters'] ?? {}, context);

    return await _appState!.executeComposioAction(
      toolId: toolId,
      actionName: actionName,
      parameters: parameters,
    );
  }

  /// Execute MCP action
  Future<dynamic> _executeMcpAction(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    if (_appState == null) {
      throw Exception('AppState not initialized');
    }

    final serverId = node.parameters['server'] as String?;
    final method = node.parameters['method'] as String?;

    if (serverId == null || method == null) {
      throw Exception('MCP action requires server and method parameters');
    }

    // Resolve parameters with variables/expressions
    final params = _resolveParameters(node.parameters['params'] ?? {}, context);

    return await _appState!.executeMcpRequest(
      serverId: serverId,
      method: method,
      params: params,
    );
  }

  /// Execute Google Workspace action
  Future<dynamic> _executeGoogleWorkspaceAction(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    if (_appState == null) {
      throw Exception('AppState not initialized');
    }

    final service = node.parameters['service'] as String?;
    final actionName = node.parameters['action'] as String?;

    if (service == null || actionName == null) {
      throw Exception('Google Workspace action requires service and action parameters');
    }

    // Check authentication
    if (!_appState!.googleAuthenticated) {
      throw Exception('NOT_AUTHENTICATED: Please sign in to Google to use Google Workspace tools');
    }

    // Resolve parameters with variables/expressions
    final parameters = _resolveParameters(node.parameters['parameters'] ?? {}, context);

    try {
      return await _appState!.executeGoogleWorkspaceAction(
        service: service,
        actionName: actionName,
        parameters: parameters,
      );
    } catch (e) {
      if (e.toString().contains('NOT_AUTHENTICATED')) {
        throw Exception('NOT_AUTHENTICATED: Please sign in to Google to continue');
      }
      rethrow;
    }
  }

  /// Execute system-level tool action (UI automation, notifications, etc.)
  Future<dynamic> _executeSystemToolAction(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    if (_appState == null) {
      throw Exception('AppState not initialized');
    }

    final toolId = node.parameters['toolId'] as String?;
    
    if (toolId == null) {
      throw Exception('System tool action requires toolId parameter');
    }

    // Check required permissions based on tool type
    await _checkSystemToolPermissions(toolId);

    // Resolve parameters with variables/expressions
    final parameters = _resolveParameters(node.parameters['parameters'] ?? {}, context);

    try {
      return await _appState!.executeSystemTool(
        toolId: toolId,
        parameters: parameters,
      );
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED') || 
          e.toString().contains('Accessibility') ||
          e.toString().contains('Notification Listener')) {
        throw Exception('PERMISSION_REQUIRED: ${e.toString()}');
      }
      rethrow;
    }
  }

  /// Check if required permissions are granted for system tools
  Future<void> _checkSystemToolPermissions(String toolId) async {
    if (_appState == null) return;

    // UI automation tools require Accessibility Service
    if (toolId.startsWith('ui_')) {
      final hasPermission = await _appState!.checkAccessibilityStatus();
      if (!hasPermission) {
        throw Exception(
          'PERMISSION_REQUIRED: Accessibility Service is required for UI automation. '
          'Please enable it in Settings.'
        );
      }
    }

    // Notification tools require Notification Listener
    if (toolId.startsWith('notif_')) {
      final hasPermission = await _appState!.checkNotificationListenerStatus();
      if (!hasPermission) {
        throw Exception(
          'PERMISSION_REQUIRED: Notification Listener is required. '
          'Please enable it in Settings.'
        );
      }
    }
  }

  /// Execute HTTP request
  Future<dynamic> _executeHttpRequest(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    // TODO: Implement HTTP request execution
    throw UnimplementedError('HTTP request not yet implemented');
  }

  /// Execute code node
  Future<dynamic> _executeCode(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    // TODO: Implement code execution (JavaScript/Python)
    throw UnimplementedError('Code execution not yet implemented');
  }

  /// Execute condition node
  dynamic _executeCondition(WorkflowNode node, ExecutionContext context) {
    final condition = node.parameters['condition'] as String?;
    if (condition == null) {
      throw Exception('Condition node requires condition parameter');
    }

    final result = _evaluateExpression(condition, context);
    return {'result': result, 'condition': condition};
  }

  /// Execute switch node
  dynamic _executeSwitch(WorkflowNode node, ExecutionContext context) {
    final value = node.parameters['value'];
    final resolvedValue = _resolveValue(value, context);

    return {'value': resolvedValue, 'type': resolvedValue.runtimeType.toString()};
  }

  /// Execute loop node
  Future<dynamic> _executeLoop(
    WorkflowNode node,
    ExecutionContext context,
  ) async {
    final items = node.parameters['items'];
    final resolvedItems = _resolveValue(items, context);

    if (resolvedItems is! List) {
      throw Exception('Loop items must be a list');
    }

    final results = [];
    for (int i = 0; i < resolvedItems.length; i++) {
      if (_shouldStop) break;

      context.setVariable('item', resolvedItems[i]);
      context.setVariable('index', i);
      
      // Execute loop body (nodes connected to loop output)
      // This is simplified - actual implementation would execute connected nodes
      results.add(resolvedItems[i]);
    }

    return {'results': results, 'count': results.length};
  }

  /// Set variable
  dynamic _setVariable(WorkflowNode node, ExecutionContext context) {
    final name = node.parameters['name'] as String?;
    final value = node.parameters['value'];

    if (name == null) {
      throw Exception('Set variable requires name parameter');
    }

    final resolvedValue = _resolveValue(value, context);
    context.setVariable(name, resolvedValue);

    return {'name': name, 'value': resolvedValue};
  }

  /// Get variable
  dynamic _getVariable(WorkflowNode node, ExecutionContext context) {
    final name = node.parameters['name'] as String?;

    if (name == null) {
      throw Exception('Get variable requires name parameter');
    }

    return {'name': name, 'value': context.getVariable(name)};
  }

  /// Execute function node
  dynamic _executeFunction(WorkflowNode node, ExecutionContext context) {
    final code = node.parameters['code'] as String?;
    
    if (code == null) {
      throw Exception('Function requires code parameter');
    }

    // TODO: Implement JavaScript/Python function execution
    throw UnimplementedError('Function execution not yet implemented');
  }

  /// Resolve parameters with variable substitution
  Map<String, dynamic> _resolveParameters(
    Map<String, dynamic> params,
    ExecutionContext context,
  ) {
    final resolved = <String, dynamic>{};

    for (final entry in params.entries) {
      resolved[entry.key] = _resolveValue(entry.value, context);
    }

    return resolved;
  }

  /// Resolve a value (handle expressions, variables)
  dynamic _resolveValue(dynamic value, ExecutionContext context) {
    if (value is String) {
      // Handle expressions: {{ variable }} or {{ node.output }}
      if (value.contains('{{') && value.contains('}}')) {
        return _evaluateExpression(value, context);
      }
    }

    return value;
  }

  /// Evaluate expression (simple Jinja-like syntax)
  dynamic _evaluateExpression(String expression, ExecutionContext context) {
    // Remove {{ }} markers
    final cleaned = expression.replaceAll('{{', '').replaceAll('}}', '').trim();

    // Handle node output references: node.output.field
    if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      if (parts[0] == 'node' && parts.length >= 2) {
        final nodeId = parts[1];
        final result = context.getNodeResult(nodeId);
        
        if (result != null && parts.length > 2) {
          // Navigate nested fields
          dynamic current = result;
          for (int i = 2; i < parts.length; i++) {
            if (current is Map) {
              current = current[parts[i]];
            } else {
              break;
            }
          }
          return current;
        }
        
        return result;
      }
    }

    // Handle simple variable
    return context.getVariable(cleaned);
  }

  /// Check if execution should continue based on conditions
  bool _shouldContinue(
    WorkflowNode node,
    dynamic result,
    Workflow workflow,
  ) {
    // For condition nodes, check result
    if (node.type == NodeType.condition || node.type == NodeType.ifElse) {
      if (result is Map && result.containsKey('result')) {
        return result['result'] == true;
      }
    }

    return true;
  }

  /// Handle error in node execution
  Future<bool> _handleError(
    WorkflowNode node,
    String error,
    Workflow workflow,
    ExecutionContext context,
  ) async {
    // Look for error handler nodes connected to this node
    final errorConnections = workflow.connections.where(
      (conn) => conn.sourceNodeId == node.id && conn.type == ConnectionType.error,
    );

    if (errorConnections.isEmpty) {
      return false; // No error handler, rethrow
    }

    // Execute error handler
    for (final conn in errorConnections) {
      final errorNode = workflow.nodes.firstWhere(
        (n) => n.id == conn.targetNodeId,
      );

      context.setVariable('error', error);
      context.setVariable('errorNode', node.id);

      try {
        await _executeNode(errorNode, context);
        return true; // Error handled
      } catch (e) {
        debugPrint('Error in error handler: $e');
      }
    }

    return false;
  }

  /// Stop execution
  void stop() {
    _shouldStop = true;
  }

  /// Dispose resources
  void dispose() {
    _shouldStop = true;
    _isRunning = false;
  }
}

/// Execution context for storing variables and node results
class ExecutionContext {
  final Map<String, dynamic> _variables = {};
  final Map<String, dynamic> _nodeResults = {};

  void setVariable(String name, dynamic value) {
    _variables[name] = value;
  }

  dynamic getVariable(String name) {
    return _variables[name];
  }

  void setNodeResult(String nodeId, dynamic result) {
    _nodeResults[nodeId] = result;
  }

  dynamic getNodeResult(String nodeId) {
    return _nodeResults[nodeId];
  }

  Map<String, dynamic> getAllVariables() {
    return Map.from(_variables);
  }

  Map<String, dynamic> getAllNodeResults() {
    return Map.from(_nodeResults);
  }
}

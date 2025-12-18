/// Platform bridge for communication with native Kotlin/Swift code
library;

import 'package:flutter/services.dart';
import '../models/composio_tool.dart';
import '../models/mcp_server.dart';

class PlatformBridge {
  static const MethodChannel _channel = MethodChannel('com.blurr.workflow_editor');
  
  // Callback for workflow loaded from native
  void Function(Map<String, dynamic> workflow, bool autoExecute)? _workflowLoadHandler;
  
  PlatformBridge() {
    // Setup method call handler for callbacks from native
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  /// Handle method calls from native code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'loadWorkflowFromNative':
        final workflow = (call.arguments['workflow'] as Map).cast<String, dynamic>();
        final autoExecute = call.arguments['autoExecute'] as bool? ?? false;
        
        // Call the registered handler
        _workflowLoadHandler?.call(workflow, autoExecute);
        return true;
        
      default:
        throw MissingPluginException('Method ${call.method} not implemented');
    }
  }
  
  /// Set handler for workflow loaded from native
  void setWorkflowLoadHandler(void Function(Map<String, dynamic>, bool) handler) {
    _workflowLoadHandler = handler;
  }

  /// Get Pro subscription status
  Future<bool> getProStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('getProStatus');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error getting Pro status: ${e.message}');
      return false;
    }
  }

  /// Get connected Composio tools
  Future<List<ComposioTool>> getComposioTools() async {
    try {
      final result = await _channel.invokeMethod<List>('getComposioTools');
      if (result == null) return [];

      return result.map((json) => ComposioTool.fromJson(json as Map<String, dynamic>)).toList();
    } on PlatformException catch (e) {
      print('Error getting Composio tools: ${e.message}');
      return [];
    }
  }

  /// Get connected MCP servers
  Future<List<McpServer>> getMcpServers() async {
    try {
      final result = await _channel.invokeMethod<List>('getMcpServers');
      if (result == null) return [];

      return result.map((json) => McpServer.fromJson(json as Map<String, dynamic>)).toList();
    } on PlatformException catch (e) {
      print('Error getting MCP servers: ${e.message}');
      return [];
    }
  }

  /// Execute Composio action
  Future<Map<String, dynamic>> executeComposioAction({
    required String toolId,
    required String actionName,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('executeComposioAction', {
        'toolId': toolId,
        'actionName': actionName,
        'parameters': parameters,
      });

      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      throw Exception('Composio action failed: ${e.message}');
    }
  }

  /// Execute MCP request
  Future<Map<String, dynamic>> executeMcpRequest({
    required String serverId,
    required String method,
    required Map<String, dynamic> params,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('executeMcpRequest', {
        'serverId': serverId,
        'method': method,
        'params': params,
      });

      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      throw Exception('MCP request failed: ${e.message}');
    }
  }

  /// Save workflow to native storage
  Future<void> saveWorkflow(Map<String, dynamic> workflow) async {
    try {
      await _channel.invokeMethod('saveWorkflow', {'workflow': workflow});
    } on PlatformException catch (e) {
      throw Exception('Failed to save workflow: ${e.message}');
    }
  }

  /// Load workflow from native storage
  Future<Map<String, dynamic>?> loadWorkflow(String workflowId) async {
    try {
      final result = await _channel.invokeMethod<Map>('loadWorkflow', {
        'workflowId': workflowId,
      });

      return result?.cast<String, dynamic>();
    } on PlatformException catch (e) {
      print('Error loading workflow: ${e.message}');
      return null;
    }
  }

  /// Get list of saved workflows
  Future<List<Map<String, dynamic>>> getWorkflows() async {
    try {
      final result = await _channel.invokeMethod<List>('getWorkflows');
      if (result == null) return [];

      return result.map((item) => (item as Map).cast<String, dynamic>()).toList();
    } on PlatformException catch (e) {
      print('Error getting workflows: ${e.message}');
      return [];
    }
  }

  /// Show native upgrade dialog for Pro features
  Future<void> showProUpgradeDialog(String feature) async {
    try {
      await _channel.invokeMethod('showProUpgradeDialog', {
        'feature': feature,
      });
    } on PlatformException catch (e) {
      print('Error showing upgrade dialog: ${e.message}');
    }
  }

  /// Get Google authentication status
  Future<bool> getGoogleAuthStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('getGoogleAuthStatus');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error getting Google auth status: ${e.message}');
      return false;
    }
  }

  /// Trigger Google OAuth authentication
  Future<bool> authenticateGoogle() async {
    try {
      final result = await _channel.invokeMethod<bool>('authenticateGoogle');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error authenticating Google: ${e.message}');
      return false;
    }
  }

  /// Execute Google Workspace action
  Future<Map<String, dynamic>> executeGoogleWorkspaceAction({
    required String service,
    required String actionName,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('executeGoogleWorkspaceAction', {
        'service': service,
        'actionName': actionName,
        'parameters': parameters,
      });

      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      throw Exception('Google Workspace action failed: ${e.message}');
    }
  }

  /// Get available system tools (UI automation, notifications, etc.)
  Future<List<Map<String, dynamic>>> getSystemTools() async {
    try {
      final result = await _channel.invokeMethod<List>('getSystemTools');
      if (result == null) return [];

      return result.map((item) => (item as Map).cast<String, dynamic>()).toList();
    } on PlatformException catch (e) {
      print('Error getting system tools: ${e.message}');
      return [];
    }
  }

  /// Execute system-level tool (UI automation, notification, etc.)
  Future<Map<String, dynamic>> executeSystemTool({
    required String toolId,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('executeSystemTool', {
        'toolId': toolId,
        'parameters': parameters,
      });

      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      throw Exception('System tool execution failed: ${e.message}');
    }
  }

  /// Check if Accessibility Service is enabled
  Future<bool> checkAccessibilityStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkAccessibilityStatus');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error checking accessibility status: ${e.message}');
      return false;
    }
  }

  /// Check if Notification Listener is enabled
  Future<bool> checkNotificationListenerStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkNotificationListenerStatus');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error checking notification listener status: ${e.message}');
      return false;
    }
  }

  /// Request Accessibility Service permission
  Future<bool> requestAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestAccessibilityPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error requesting accessibility permission: ${e.message}');
      return false;
    }
  }

  /// Request Notification Listener permission
  Future<bool> requestNotificationListenerPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestNotificationListenerPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error requesting notification listener permission: ${e.message}');
      return false;
    }
  }
}

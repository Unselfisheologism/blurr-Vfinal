/// Platform bridge for native communication
/// Connects Flutter workflow editor to native Android functionality
library;

import 'package:flutter/services.dart';
import 'dart:convert';

/// Main platform bridge for communicating with native Android
class PlatformBridge {
  static const MethodChannel _channel = MethodChannel('workflow_editor');
  
  /// Test platform communication
  Future<String> getPlatformVersion() async {
    try {
      final String version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } catch (e) {
      throw PlatformException(code: 'PLATFORM_ERROR', message: e.toString());
    }
  }
  
  /// Execute code via Unified Shell
  Future<Map<String, dynamic>> executeUnifiedShell({
    required String code,
    required String language,
    int timeout = 30,
    Map<String, dynamic>? inputs,
  }) async {
    try {
      final result = await _channel.invokeMethod('executeUnifiedShell', {
        'code': code,
        'language': language,
        'timeout': timeout,
        'inputs': inputs ?? {},
      });
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw PlatformException(
        code: 'SHELL_EXECUTION_ERROR',
        message: 'Failed to execute shell: $e',
      );
    }
  }
  
  /// Get available Composio tools
  Future<List<Map<String, dynamic>>> getComposioTools() async {
    try {
      final result = await _channel.invokeMethod('getComposioTools');
      return List<Map<String, dynamic>>.from(
        (result as List).map((e) => Map<String, dynamic>.from(e as Map))
      );
    } catch (e) {
      throw PlatformException(
        code: 'COMPOSIO_ERROR',
        message: 'Failed to get Composio tools: $e',
      );
    }
  }
  
  /// Execute Composio action
  Future<Map<String, dynamic>> executeComposioAction({
    required String toolId,
    required String actionId,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod('executeComposioAction', {
        'toolId': toolId,
        'actionId': actionId,
        'parameters': parameters,
      });
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw PlatformException(
        code: 'COMPOSIO_ACTION_ERROR',
        message: 'Failed to execute Composio action: $e',
      );
    }
  }
  
  /// Get available MCP servers
  Future<List<Map<String, dynamic>>> getMCPServers() async {
    try {
      final result = await _channel.invokeMethod('getMCPServers');
      return List<Map<String, dynamic>>.from(
        (result as List).map((e) => Map<String, dynamic>.from(e as Map))
      );
    } catch (e) {
      throw PlatformException(
        code: 'MCP_ERROR',
        message: 'Failed to get MCP servers: $e',
      );
    }
  }
  
  /// Execute MCP tool
  Future<Map<String, dynamic>> executeMCPTool({
    required String serverId,
    required String toolId,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod('executeMCPTool', {
        'serverId': serverId,
        'toolId': toolId,
        'parameters': parameters,
      });
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw PlatformException(
        code: 'MCP_TOOL_ERROR',
        message: 'Failed to execute MCP tool: $e',
      );
    }
  }
  
  /// Execute HTTP request
  Future<Map<String, dynamic>> executeHttpRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final result = await _channel.invokeMethod('executeHttpRequest', {
        'url': url,
        'method': method,
        'headers': headers ?? {},
        'body': body,
      });
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw PlatformException(
        code: 'HTTP_ERROR',
        message: 'Failed to execute HTTP request: $e',
      );
    }
  }
  
  /// Control phone functions
  Future<Map<String, dynamic>> executePhoneControl({
    required String action,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final result = await _channel.invokeMethod('executePhoneControl', {
        'action': action,
        'parameters': parameters,
      });
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw PlatformException(
        code: 'PHONE_CONTROL_ERROR',
        message: 'Failed to execute phone control: $e',
      );
    }
  }
  
  /// Send notification
  Future<void> sendNotification({
    required String title,
    required String message,
    String? channelId,
    Map<String, dynamic>? extras,
  }) async {
    try {
      await _channel.invokeMethod('sendNotification', {
        'title': title,
        'message': message,
        'channelId': channelId ?? 'workflow_notifications',
        'extras': extras ?? {},
      });
    } catch (e) {
      throw PlatformException(
        code: 'NOTIFICATION_ERROR',
        message: 'Failed to send notification: $e',
      );
    }
  }
  
  /// Call AI assistant
  Future<Map<String, dynamic>> callAIAssistant({
    required String prompt,
    Map<String, dynamic>? context,
  }) async {
    try {
      final result = await _channel.invokeMethod('callAIAssistant', {
        'prompt': prompt,
        'context': context ?? {},
      });
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw PlatformException(
        code: 'AI_ASSISTANT_ERROR',
        message: 'Failed to call AI assistant: $e',
      );
    }
  }
  
  /// Execute agent task (generic AI task execution for spreadsheet operations)
  Future<Map<String, dynamic>> executeAgentTask(String prompt) async {
    try {
      final result = await _channel.invokeMethod('executeAgentTask', {
        'prompt': prompt,
      });
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      throw PlatformException(
        code: 'AGENT_TASK_ERROR',
        message: 'Failed to execute agent task: $e',
      );
    }
  }
  
  /// Save workflow
  Future<void> saveWorkflow({
    required String workflowId,
    required Map<String, dynamic> workflowData,
  }) async {
    try {
      await _channel.invokeMethod('saveWorkflow', {
        'workflowId': workflowId,
        'workflowData': jsonEncode(workflowData),
      });
    } catch (e) {
      throw PlatformException(
        code: 'SAVE_ERROR',
        message: 'Failed to save workflow: $e',
      );
    }
  }
  
  /// Load workflow
  Future<Map<String, dynamic>?> loadWorkflow(String workflowId) async {
    try {
      final result = await _channel.invokeMethod('loadWorkflow', {
        'workflowId': workflowId,
      });
      
      if (result == null) return null;
      
      return Map<String, dynamic>.from(jsonDecode(result as String) as Map);
    } catch (e) {
      throw PlatformException(
        code: 'LOAD_ERROR',
        message: 'Failed to load workflow: $e',
      );
    }
  }
  
  /// List saved workflows
  Future<List<Map<String, dynamic>>> listWorkflows() async {
    try {
      final result = await _channel.invokeMethod('listWorkflows');
      return List<Map<String, dynamic>>.from(
        (result as List).map((e) => Map<String, dynamic>.from(e as Map))
      );
    } catch (e) {
      throw PlatformException(
        code: 'LIST_ERROR',
        message: 'Failed to list workflows: $e',
      );
    }
  }
  
  /// Schedule workflow (Pro feature)
  Future<void> scheduleWorkflow({
    required String workflowId,
    required String cronExpression,
    bool enabled = true,
  }) async {
    try {
      await _channel.invokeMethod('scheduleWorkflow', {
        'workflowId': workflowId,
        'cronExpression': cronExpression,
        'enabled': enabled,
      });
    } catch (e) {
      throw PlatformException(
        code: 'SCHEDULE_ERROR',
        message: 'Failed to schedule workflow: $e',
      );
    }
  }
  
  /// Check if user has Pro subscription
  Future<bool> hasProSubscription() async {
    try {
      final result = await _channel.invokeMethod('hasProSubscription');
      return result as bool;
    } catch (e) {
      return false;
    }
  }
  
  /// Export workflow to JSON
  Future<String> exportWorkflow(String workflowId) async {
    try {
      final result = await _channel.invokeMethod('exportWorkflow', {
        'workflowId': workflowId,
      });
      
      return result as String;
    } catch (e) {
      throw PlatformException(
        code: 'EXPORT_ERROR',
        message: 'Failed to export workflow: $e',
      );
    }
  }
  
  /// Import workflow from JSON
  Future<String> importWorkflow(String workflowJson) async {
    try {
      final result = await _channel.invokeMethod('importWorkflow', {
        'workflowJson': workflowJson,
      });
      
      return result as String; // Returns new workflow ID
    } catch (e) {
      throw PlatformException(
        code: 'IMPORT_ERROR',
        message: 'Failed to import workflow: $e',
      );
    }
  }
  
  /// Get workflow templates
  Future<List<Map<String, dynamic>>> getWorkflowTemplates() async {
    try {
      final result = await _channel.invokeMethod('getWorkflowTemplates');
      return List<Map<String, dynamic>>.from(
        (result as List).map((e) => Map<String, dynamic>.from(e as Map))
      );
    } catch (e) {
      // Return empty list if templates not available
      return [];
    }
  }
}

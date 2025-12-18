/// App-level state management
/// Manages Composio tools, MCP servers, and Pro features
library;

import 'package:flutter/foundation.dart';
import '../services/platform_bridge.dart';
import '../models/composio_tool.dart';
import '../models/mcp_server.dart';
import '../models/google_workspace_tool.dart';

class AppState extends ChangeNotifier {
  final PlatformBridge _platformBridge = PlatformBridge();

  // Composio state
  List<ComposioTool> _composioTools = [];
  bool _composioConnected = false;

  // MCP state
  List<McpServer> _mcpServers = [];
  bool _mcpConnected = false;

  // Google Workspace state
  List<GoogleWorkspaceTool> _googleWorkspaceTools = [];
  bool _googleAuthenticated = false;

  // Pro features
  bool _isPro = false;
  Set<String> _enabledFeatures = {};

  // Loading state
  bool _isLoading = false;

  // Getters
  List<ComposioTool> get composioTools => _composioTools;
  bool get composioConnected => _composioConnected;
  List<McpServer> get mcpServers => _mcpServers;
  bool get mcpConnected => _mcpConnected;
  List<GoogleWorkspaceTool> get googleWorkspaceTools => _googleWorkspaceTools;
  bool get googleAuthenticated => _googleAuthenticated;
  bool get isPro => _isPro;
  bool get isLoading => _isLoading;

  /// Check if a feature is enabled
  bool hasFeature(String feature) {
    // Free features
    const freeFeatures = {
      'basic_workflows',
      'manual_triggers',
      'composio_integration',
      'mcp_integration',
      'local_storage',
    };

    if (freeFeatures.contains(feature)) {
      return true;
    }

    // Pro features
    const proFeatures = {
      'scheduled_triggers',
      'webhook_triggers',
      'team_collaboration',
      'workflow_sharing',
      'advanced_error_handling',
      'ai_assisted_creation',
      'unlimited_executions',
      'priority_support',
    };

    if (proFeatures.contains(feature)) {
      return _isPro;
    }

    return false;
  }

  /// Initialize app state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load Pro status from platform
      _isPro = await _platformBridge.getProStatus();

      // Load Composio tools
      await loadComposioTools();

      // Load MCP servers
      await loadMcpServers();

      // Load Google Workspace tools
      await loadGoogleWorkspaceTools();
      
      // Setup listener for workflows loaded from native (AI agent)
      _setupNativeWorkflowListener();
    } catch (e) {
      debugPrint('Error initializing app state: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Setup listener for workflows sent from native Kotlin code
  void _setupNativeWorkflowListener() {
    _platformBridge.setWorkflowLoadHandler((workflow, autoExecute) async {
      debugPrint('Received workflow from native: ${workflow['name']}');
      debugPrint('Auto-execute: $autoExecute');
      
      // TODO: Load workflow into WorkflowState and execute if needed
      // This will be handled by WorkflowState when user creates workflows via AI
      
      if (autoExecute) {
        debugPrint('Auto-execute requested for workflow - executing...');
        // Execute workflow immediately
      }
    });
  }

  /// Load Composio connected tools from native app
  Future<void> loadComposioTools() async {
    try {
      final tools = await _platformBridge.getComposioTools();
      _composioTools = tools;
      _composioConnected = tools.isNotEmpty;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading Composio tools: $e');
      _composioConnected = false;
    }
  }

  /// Load MCP servers from native app
  Future<void> loadMcpServers() async {
    try {
      final servers = await _platformBridge.getMcpServers();
      _mcpServers = servers;
      _mcpConnected = servers.isNotEmpty;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading MCP servers: $e');
      _mcpConnected = false;
    }
  }

  /// Execute Composio action
  Future<Map<String, dynamic>> executeComposioAction({
    required String toolId,
    required String actionName,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      return await _platformBridge.executeComposioAction(
        toolId: toolId,
        actionName: actionName,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Error executing Composio action: $e');
      rethrow;
    }
  }

  /// Execute MCP request
  Future<Map<String, dynamic>> executeMcpRequest({
    required String serverId,
    required String method,
    required Map<String, dynamic> params,
  }) async {
    try {
      return await _platformBridge.executeMcpRequest(
        serverId: serverId,
        method: method,
        params: params,
      );
    } catch (e) {
      debugPrint('Error executing MCP request: $e');
      rethrow;
    }
  }

  /// Refresh Composio connection
  Future<void> refreshComposio() async {
    await loadComposioTools();
  }

  /// Refresh MCP connection
  Future<void> refreshMcp() async {
    await loadMcpServers();
  }

  /// Load Google Workspace tools and auth status
  Future<void> loadGoogleWorkspaceTools() async {
    try {
      final authStatus = await _platformBridge.getGoogleAuthStatus();
      _googleAuthenticated = authStatus;

      if (_googleAuthenticated) {
        // Load available Google Workspace tools
        _googleWorkspaceTools = GoogleWorkspaceTools.all().map((tool) {
          return GoogleWorkspaceTool(
            id: tool.id,
            name: tool.name,
            service: tool.service,
            description: tool.description,
            icon: tool.icon,
            actions: tool.actions,
            authenticated: true,
          );
        }).toList();
      } else {
        // Show tools but mark as not authenticated
        _googleWorkspaceTools = GoogleWorkspaceTools.all().map((tool) {
          return GoogleWorkspaceTool(
            id: tool.id,
            name: tool.name,
            service: tool.service,
            description: tool.description,
            icon: tool.icon,
            actions: tool.actions,
            authenticated: false,
          );
        }).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading Google Workspace tools: $e');
      _googleAuthenticated = false;
    }
  }

  /// Execute Google Workspace action
  Future<Map<String, dynamic>> executeGoogleWorkspaceAction({
    required String service,
    required String actionName,
    required Map<String, dynamic> parameters,
  }) async {
    // Check authentication first
    if (!_googleAuthenticated) {
      throw Exception('NOT_AUTHENTICATED: Please sign in to Google');
    }

    try {
      return await _platformBridge.executeGoogleWorkspaceAction(
        service: service,
        actionName: actionName,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Error executing Google Workspace action: $e');
      rethrow;
    }
  }

  /// Trigger Google OAuth authentication
  Future<bool> authenticateGoogleWorkspace() async {
    try {
      final success = await _platformBridge.authenticateGoogle();
      
      if (success) {
        await loadGoogleWorkspaceTools();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error authenticating Google Workspace: $e');
      return false;
    }
  }

  /// Refresh Google Workspace connection
  Future<void> refreshGoogleWorkspace() async {
    await loadGoogleWorkspaceTools();
  }

  /// Execute system-level tool
  Future<Map<String, dynamic>> executeSystemTool({
    required String toolId,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      return await _platformBridge.executeSystemTool(
        toolId: toolId,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Error executing system tool: $e');
      rethrow;
    }
  }

  /// Check if Accessibility Service is enabled
  Future<bool> checkAccessibilityStatus() async {
    try {
      return await _platformBridge.checkAccessibilityStatus();
    } catch (e) {
      debugPrint('Error checking accessibility status: $e');
      return false;
    }
  }

  /// Check if Notification Listener is enabled
  Future<bool> checkNotificationListenerStatus() async {
    try {
      return await _platformBridge.checkNotificationListenerStatus();
    } catch (e) {
      debugPrint('Error checking notification listener status: $e');
      return false;
    }
  }

  /// Request Accessibility Service permission
  Future<bool> requestAccessibilityPermission() async {
    try {
      return await _platformBridge.requestAccessibilityPermission();
    } catch (e) {
      debugPrint('Error requesting accessibility permission: $e');
      return false;
    }
  }

  /// Request Notification Listener permission
  Future<bool> requestNotificationListenerPermission() async {
    try {
      return await _platformBridge.requestNotificationListenerPermission();
    } catch (e) {
      debugPrint('Error requesting notification listener permission: $e');
      return false;
    }
  }

  /// Update Pro status (for testing or when subscription changes)
  void updateProStatus(bool isPro) {
    _isPro = isPro;
    notifyListeners();
  }
}

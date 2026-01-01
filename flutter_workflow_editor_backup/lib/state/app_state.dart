/// Global app state management
library;

import 'package:flutter/foundation.dart';
import '../services/platform_bridge.dart';
import '../nodes/composio_node.dart';
import '../nodes/mcp_node.dart';

class AppState extends ChangeNotifier {
  final PlatformBridge _platformBridge = PlatformBridge();
  
  bool _initialized = false;
  bool _hasProSubscription = false;
  List<ComposioTool> _composioTools = [];
  List<MCPServer> _mcpServers = [];
  List<Map<String, dynamic>> _workflowTemplates = [];
  
  // Getters
  bool get initialized => _initialized;
  bool get hasProSubscription => _hasProSubscription;
  List<ComposioTool> get composioTools => _composioTools;
  List<MCPServer> get mcpServers => _mcpServers;
  List<Map<String, dynamic>> get workflowTemplates => _workflowTemplates;
  PlatformBridge get platformBridge => _platformBridge;
  
  /// Initialize app state
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Check Pro subscription
      _hasProSubscription = await _platformBridge.hasProSubscription();
      
      // Load Composio tools
      await loadComposioTools();
      
      // Load MCP servers
      await loadMCPServers();
      
      // Load workflow templates
      await loadWorkflowTemplates();
      
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize app state: $e');
      _initialized = true; // Still mark as initialized to allow app to function
      notifyListeners();
    }
  }
  
  /// Load available Composio tools
  Future<void> loadComposioTools() async {
    try {
      final toolsData = await _platformBridge.getComposioTools();
      _composioTools = toolsData
          .map((data) => ComposioTool.fromJson(data))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load Composio tools: $e');
      _composioTools = [];
    }
  }
  
  /// Load available MCP servers
  Future<void> loadMCPServers() async {
    try {
      final serversData = await _platformBridge.getMCPServers();
      _mcpServers = serversData
          .map((data) => MCPServer.fromJson(data))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load MCP servers: $e');
      _mcpServers = [];
    }
  }
  
  /// Load workflow templates
  Future<void> loadWorkflowTemplates() async {
    try {
      _workflowTemplates = await _platformBridge.getWorkflowTemplates();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load workflow templates: $e');
      _workflowTemplates = [];
    }
  }
  
  /// Refresh Composio tools
  Future<void> refreshComposioTools() async {
    await loadComposioTools();
  }
  
  /// Refresh MCP servers
  Future<void> refreshMCPServers() async {
    await loadMCPServers();
  }
  
  /// Check and update Pro subscription status
  Future<void> checkProSubscription() async {
    try {
      _hasProSubscription = await _platformBridge.hasProSubscription();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to check Pro subscription: $e');
    }
  }
}

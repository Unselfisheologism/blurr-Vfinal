/// MCP Server Manager
/// Manages MCP server connections in the workflow editor
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_bridge.dart';
import '../models/mcp_server.dart';

/// MCP server connection information
class MCPServerConnection {
  final String name;
  final String url;
  final String transport; // 'http', 'sse', 'stdio'
  final bool connected;
  final List<McpTool> tools;
  final Map<String, dynamic>? serverInfo;

  MCPServerConnection({
    required this.name,
    required this.url,
    required this.transport,
    this.connected = false,
    this.tools = const [],
    this.serverInfo,
  });

  MCPServerConnection copyWith({
    String? name,
    String? url,
    String? transport,
    bool? connected,
    List<McpTool>? tools,
    Map<String, dynamic>? serverInfo,
  }) {
    return MCPServerConnection(
      name: name ?? this.name,
      url: url ?? this.url,
      transport: transport ?? this.transport,
      connected: connected ?? this.connected,
      tools: tools ?? this.tools,
      serverInfo: serverInfo ?? this.serverInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'transport': transport,
      'connected': connected,
      'tools': tools.map((t) => t.toJson()).toList(),
      'serverInfo': serverInfo,
    };
  }

  factory MCPServerConnection.fromJson(Map<String, dynamic> json) {
    return MCPServerConnection(
      name: json['name'] as String,
      url: json['url'] as String,
      transport: json['transport'] as String,
      connected: json['connected'] as bool? ?? false,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((t) => McpTool.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      serverInfo: json['serverInfo'] as Map<String, dynamic>?,
    );
  }
}

/// MCP Server Manager
/// Singleton service for managing MCP server connections
class MCPServerManager extends ChangeNotifier {
  static final MCPServerManager _instance = MCPServerManager._internal();
  factory MCPServerManager() => _instance;

  final PlatformBridge _platformBridge = PlatformBridge();
  final Map<String, MCPServerConnection> _servers = {};
  final StreamController<Map<String, dynamic>> _statusController =
      StreamController.broadcast();

  bool _isLoading = false;

  MCPServerManager._internal();

  /// Get the singleton instance
  static MCPServerManager get instance => _instance;

  /// Stream of server status changes
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  /// All connected servers
  List<MCPServerConnection> get servers => _servers.values.toList();

  /// Connected servers count
  int get serverCount => _servers.values.where((s) => s.connected).length;

  /// Is loading
  bool get isLoading => _isLoading;

  /// Initialize and load existing servers from platform
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final serverList = await _platformBridge.getMCPServers();

      for (final serverData in serverList) {
        final connection = MCPServerConnection(
          name: serverData['name'] as String,
          url: serverData['url'] as String,
          transport: serverData['transport'] as String? ?? 'http',
          connected: serverData['connected'] as bool? ?? false,
        );
        _servers[connection.name] = connection;
      }

      debugPrint('MCPServerManager: Loaded ${_servers.length} servers');
    } catch (e) {
      debugPrint('MCPServerManager: Error loading servers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connect to an MCP server
  Future<Map<String, dynamic>> connectServer({
    required String name,
    required String url,
    required String transport,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _platformBridge.connectMCPServer(
        serverName: name,
        url: url,
        transport: transport,
      );

      if (result['success'] == true) {
        // Fetch tools for this server
        final toolsData = await _platformBridge.getMCPTools(serverName: name);

        final tools = toolsData.map((t) => McpTool(
          name: t['name'] as String,
          description: t['description'] as String?,
          inputSchema: t['inputSchema'] as Map<String, dynamic>,
          outputSchema: t['outputSchema'] as Map<String, dynamic>?,
        )).toList();

        final connection = MCPServerConnection(
          name: name,
          url: url,
          transport: transport,
          connected: true,
          tools: tools,
          serverInfo: {
            'toolCount': result['toolCount'] as int? ?? tools.length,
          },
        );

        _servers[name] = connection;

        _statusController.add({
          'type': 'connected',
          'server': name,
          'toolCount': tools.length,
        });

        debugPrint('MCPServerManager: Connected to $name with ${tools.length} tools');
      }

      return result;
    } catch (e) {
      debugPrint('MCPServerManager: Error connecting to $name: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Disconnect from an MCP server
  Future<Map<String, dynamic>> disconnectServer(String name) async {
    try {
      final result = await _platformBridge.disconnectMCPServer(name);

      if (result['success'] == true) {
        _servers.remove(name);

        _statusController.add({
          'type': 'disconnected',
          'server': name,
        });

        debugPrint('MCPServerManager: Disconnected from $name');
      }

      return result;
    } catch (e) {
      debugPrint('MCPServerManager: Error disconnecting from $name: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// Get tools from a specific server
  Future<List<McpTool>> getTools(String serverName) async {
    final server = _servers[serverName];
    if (server == null) {
      return [];
    }

    // Refresh tools from platform
    try {
      final toolsData = await _platformBridge.getMCPTools(serverName: serverName);
      final tools = toolsData.map((t) => McpTool(
        name: t['name'] as String,
        description: t['description'] as String?,
        inputSchema: t['inputSchema'] as Map<String, dynamic>,
        outputSchema: t['outputSchema'] as Map<String, dynamic>?,
      )).toList();

      // Update cached connection
      _servers[serverName] = server.copyWith(tools: tools);
      notifyListeners();

      return tools;
    } catch (e) {
      debugPrint('MCPServerManager: Error fetching tools from $serverName: $e');
      return server.tools;
    }
  }

  /// Execute a tool action
  Future<Map<String, dynamic>> executeToolAction({
    required String serverName,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    try {
      final result = await _platformBridge.executeMCPTool(
        serverName: serverName,
        toolName: toolName,
        arguments: arguments,
      );

      _statusController.add({
        'type': 'tool_executed',
        'server': serverName,
        'tool': toolName,
        'success': result['success'] as bool? ?? false,
      });

      return result;
    } catch (e) {
      debugPrint('MCPServerManager: Error executing tool $toolName: $e');
      rethrow;
    }
  }

  /// Validate MCP connection without connecting permanently
  Future<Map<String, dynamic>> validateConnection({
    required String name,
    required String url,
    required String transport,
  }) async {
    try {
      final result = await _platformBridge.validateMCPConnection(
        serverName: name,
        url: url,
        transport: transport,
      );

      return result;
    } catch (e) {
      debugPrint('MCPServerManager: Error validating connection: $e');
      rethrow;
    }
  }

  /// Get server by name
  MCPServerConnection? getServer(String name) {
    return _servers[name];
  }

  /// Get all tools from all connected servers
  List<McpTool> getAllTools() {
    return _servers.values
        .where((s) => s.connected)
        .expand((s) => s.tools)
        .toList();
  }

  /// Clear all servers
  Future<void> clearAll() async {
    for (final server in _servers.values.toList()) {
      if (server.connected) {
        await disconnectServer(server.name);
      }
    }
    _servers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _statusController.close();
    super.dispose();
  }
}

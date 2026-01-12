/// MCP Server Management Service
/// Manages MCP server connections and provides state notifications
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'platform_bridge.dart';

/// Data class representing an MCP server connection
class MCPServerConnection {
  final String name;
  final String url;
  final String transport; // 'http', 'sse', 'stdio'
  final bool connected;
  final int toolCount;
  final List<MCPToolInfo> tools;

  MCPServerConnection({
    required this.name,
    required this.url,
    required this.transport,
    required this.connected,
    required this.toolCount,
    required this.tools,
  });

  factory MCPServerConnection.fromJson(Map<String, dynamic> json) {
    return MCPServerConnection(
      name: json['name'] as String,
      url: json['url'] as String,
      transport: json['transport'] as String,
      connected: json['connected'] as bool,
      toolCount: json['toolCount'] as int,
      tools: (json['tools'] as List?)
              ?.map((t) => MCPToolInfo.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'transport': transport,
        'connected': connected,
        'toolCount': toolCount,
        'tools': tools.map((t) => t.toJson()).toList(),
      };
}

/// Data class representing an MCP tool
class MCPToolInfo {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;
  final Map<String, dynamic>? outputSchema;
  final String serverName;

  MCPToolInfo({
    required this.name,
    this.description,
    required this.inputSchema,
    this.outputSchema,
    required this.serverName,
  });

  factory MCPToolInfo.fromJson(Map<String, dynamic> json) {
    return MCPToolInfo(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['inputSchema'] as Map<String, dynamic>? ?? {},
      outputSchema: json['outputSchema'] as Map<String, dynamic>?,
      serverName: json['serverName'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'inputSchema': inputSchema,
        'outputSchema': outputSchema,
        'serverName': serverName,
      };
}

/// MCP Server Manager - ChangeNotifier for state management
/// Manages MCP server connections, tools, and provides real-time updates
class MCPServerManager extends ChangeNotifier {
  final PlatformBridge platformBridge;

  // Server registry: name -> MCPServerConnection
  Map<String, MCPServerConnection> _servers = {};

  // Tool cache: serverName:toolName -> MCPToolInfo
  Map<String, MCPToolInfo> _toolCache = {};

  // Loading state
  bool _isConnecting = false;
  String? _lastError;

  MCPServerManager({required this.platformBridge}) {
    _initializeSavedServers();
  }

  // Getters
  Map<String, MCPServerConnection> get servers => _servers;
  List<MCPServerConnection> get serversList => _servers.values.toList();
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  int get connectedServerCount => _servers.values.where((s) => s.connected).length;

  /// Initialize by loading saved servers from Android
  Future<void> _initializeSavedServers() async {
    try {
      final servers = await platformBridge.getMCPServersDetailed();
      _servers.clear();
      for (final serverData in servers) {
        final server = MCPServerConnection.fromJson(serverData);
        _servers[server.name] = server;
      }
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to load saved servers: $e';
      print(_lastError);
    }
  }

  /// Connect to MCP server
  Future<bool> connectServer({
    required String name,
    required String url,
    required String transport,
  }) async {
    _isConnecting = true;
    _lastError = null;
    notifyListeners();

    try {
      print('Connecting to MCP server: $name');

      final result = await platformBridge.connectMCPServer(
        serverName: name,
        url: url,
        transport: transport,
      );

      if (result['success'] as bool) {
        // Add to local registry
        _servers[name] = MCPServerConnection(
          name: name,
          url: url,
          transport: transport,
          connected: true,
          toolCount: result['toolCount'] as int? ?? 0,
          tools: [],
        );

        // Fetch tools for this server
        await _loadToolsForServer(name);

        print('Successfully connected to $name');
        _isConnecting = false;
        notifyListeners();
        return true;
      } else {
        _lastError = result['message'] as String?;
        print('Connection failed: $_lastError');
        _isConnecting = false;
        notifyListeners();
        return false;
      }
    } on PlatformException catch (e) {
      _lastError = 'Platform error: ${e.message}';
      print(_lastError);
      _isConnecting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = 'Unexpected error: $e';
      print(_lastError);
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  /// Disconnect from MCP server
  Future<bool> disconnectServer(String serverName) async {
    try {
      print('Disconnecting from MCP server: $serverName');

      final result = await platformBridge.disconnectMCPServer(serverName);

      if (result['success'] as bool) {
        _servers.remove(serverName);
        // Remove cached tools for this server
        _toolCache.removeWhere((key, _) => key.startsWith('$serverName:'));
        print('Successfully disconnected from $serverName');
        notifyListeners();
        return true;
      } else {
        _lastError = result['message'] as String?;
        print('Disconnection failed: $_lastError');
        return false;
      }
    } catch (e) {
      _lastError = 'Error disconnecting: $e';
      print(_lastError);
      return false;
    }
  }

  /// Load tools for a specific server
  Future<void> _loadToolsForServer(String serverName) async {
    try {
      final toolsData = await platformBridge.getMCPTools(serverName: serverName);
      final tools = toolsData
          .map((t) => MCPToolInfo.fromJson(t))
          .toList();

      if (_servers.containsKey(serverName)) {
        _servers[serverName] = MCPServerConnection(
          name: _servers[serverName]!.name,
          url: _servers[serverName]!.url,
          transport: _servers[serverName]!.transport,
          connected: _servers[serverName]!.connected,
          toolCount: tools.length,
          tools: tools,
        );

        // Cache tools
        for (final tool in tools) {
          _toolCache['$serverName:${tool.name}'] = tool;
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error loading tools for $serverName: $e');
    }
  }

  /// Get all tools
  List<MCPToolInfo> getAllTools() {
    return _toolCache.values.toList();
  }

  /// Get tools for a specific server
  List<MCPToolInfo> getToolsForServer(String serverName) {
    final server = _servers[serverName];
    return server?.tools ?? [];
  }

  /// Get a specific tool
  MCPToolInfo? getTool(String serverName, String toolName) {
    return _toolCache['$serverName:$toolName'];
  }

  /// Execute MCP tool
  Future<Map<String, dynamic>> executeTool({
    required String serverName,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    try {
      print('Executing tool: $serverName:$toolName');

      final result = await platformBridge.executeMCPTool(
        serverName: serverName,
        toolName: toolName,
        arguments: arguments,
      );

      if (result['success'] as bool) {
        print('Tool execution successful');
        return {
          'success': true,
          'result': result['result'],
        };
      } else {
        final error = result['error'] as String? ?? 'Unknown error';
        print('Tool execution failed: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('Error executing tool: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Validate connection before saving
  Future<Map<String, dynamic>> validateConnection({
    required String serverName,
    required String url,
    required String transport,
  }) async {
    try {
      print('Validating MCP connection: $serverName');

      final result = await platformBridge.validateMCPConnection(
        serverName: serverName,
        url: url,
        transport: transport,
      );

      if (result['success'] as bool) {
        print('Connection validation successful');
        return {
          'success': true,
          'message': result['message'],
          'serverInfo': result['serverInfo'],
        };
      } else {
        final message = result['message'] as String? ?? 'Validation failed';
        print('Connection validation failed: $message');
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('Error validating connection: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get a specific server
  MCPServerConnection? getServer(String serverName) {
    return _servers[serverName];
  }

  /// Check if server is connected
  bool isServerConnected(String serverName) {
    return _servers[serverName]?.connected ?? false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

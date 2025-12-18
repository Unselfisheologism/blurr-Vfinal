/// MCP server model
library;

import 'package:json_annotation/json_annotation.dart';

part 'mcp_server.g.dart';

@JsonSerializable()
class McpServer {
  final String id;
  final String name;
  final String url;
  final String? description;
  final List<McpTool> tools;
  final bool connected;

  McpServer({
    required this.id,
    required this.name,
    required this.url,
    this.description,
    this.tools = const [],
    this.connected = false,
  });

  factory McpServer.fromJson(Map<String, dynamic> json) =>
      _$McpServerFromJson(json);

  Map<String, dynamic> toJson() => _$McpServerToJson(this);
}

@JsonSerializable()
class McpTool {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;
  final Map<String, dynamic>? outputSchema;

  McpTool({
    required this.name,
    this.description,
    required this.inputSchema,
    this.outputSchema,
  });

  factory McpTool.fromJson(Map<String, dynamic> json) =>
      _$McpToolFromJson(json);

  Map<String, dynamic> toJson() => _$McpToolToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server.dart';

McpServer _$McpServerFromJson(Map<String, dynamic> json) => McpServer(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
      tools: (json['tools'] as List<dynamic>?)
              ?.map((e) => McpTool.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      connected: json['connected'] as bool? ?? false,
    );

Map<String, dynamic> _$McpServerToJson(McpServer instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'description': instance.description,
      'tools': instance.tools,
      'connected': instance.connected,
    };

McpTool _$McpToolFromJson(Map<String, dynamic> json) => McpTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['inputSchema'] as Map<String, dynamic>,
      outputSchema: json['outputSchema'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$McpToolToJson(McpTool instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'inputSchema': instance.inputSchema,
      'outputSchema': instance.outputSchema,
    };

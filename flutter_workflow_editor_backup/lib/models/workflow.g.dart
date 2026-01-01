// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow.dart';

Workflow _$WorkflowFromJson(Map<String, dynamic> json) => Workflow(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      nodes: (json['nodes'] as List<dynamic>?)
              ?.map((e) => WorkflowNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      connections: (json['connections'] as List<dynamic>?)
              ?.map((e) => WorkflowConnection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variables: json['variables'] as Map<String, dynamic>? ?? const {},
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool? ?? false,
      tags: json['tags'] as String?,
    );

Map<String, dynamic> _$WorkflowToJson(Workflow instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'nodes': instance.nodes,
      'connections': instance.connections,
      'variables': instance.variables,
      'settings': instance.settings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'active': instance.active,
      'tags': instance.tags,
    };

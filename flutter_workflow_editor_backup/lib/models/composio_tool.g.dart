// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composio_tool.dart';

ComposioTool _$ComposioToolFromJson(Map<String, dynamic> json) => ComposioTool(
      id: json['id'] as String,
      name: json['name'] as String,
      appKey: json['appKey'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => ComposioAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      connected: json['connected'] as bool? ?? false,
    );

Map<String, dynamic> _$ComposioToolToJson(ComposioTool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'appKey': instance.appKey,
      'description': instance.description,
      'icon': instance.icon,
      'actions': instance.actions,
      'connected': instance.connected,
    };

ComposioAction _$ComposioActionFromJson(Map<String, dynamic> json) =>
    ComposioAction(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((e) => ComposioParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      responseSchema: json['responseSchema'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ComposioActionToJson(ComposioAction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'description': instance.description,
      'parameters': instance.parameters,
      'responseSchema': instance.responseSchema,
    };

ComposioParameter _$ComposioParameterFromJson(Map<String, dynamic> json) =>
    ComposioParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
      defaultValue: json['defaultValue'],
      enumValues: (json['enumValues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ComposioParameterToJson(ComposioParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'required': instance.required,
      'defaultValue': instance.defaultValue,
      'enumValues': instance.enumValues,
    };

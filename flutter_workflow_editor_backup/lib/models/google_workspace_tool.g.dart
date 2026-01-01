// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_workspace_tool.dart';

GoogleWorkspaceTool _$GoogleWorkspaceToolFromJson(Map<String, dynamic> json) =>
    GoogleWorkspaceTool(
      id: json['id'] as String,
      name: json['name'] as String,
      service: $enumDecode(_$GoogleWorkspaceServiceEnumMap, json['service']),
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => GoogleWorkspaceAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      authenticated: json['authenticated'] as bool? ?? false,
    );

Map<String, dynamic> _$GoogleWorkspaceToolToJson(GoogleWorkspaceTool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'service': _$GoogleWorkspaceServiceEnumMap[instance.service]!,
      'description': instance.description,
      'icon': instance.icon,
      'actions': instance.actions,
      'authenticated': instance.authenticated,
    };

const _$GoogleWorkspaceServiceEnumMap = {
  GoogleWorkspaceService.gmail: 'gmail',
  GoogleWorkspaceService.calendar: 'calendar',
  GoogleWorkspaceService.drive: 'drive',
};

GoogleWorkspaceAction _$GoogleWorkspaceActionFromJson(Map<String, dynamic> json) =>
    GoogleWorkspaceAction(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((e) => GoogleWorkspaceParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      responseSchema: json['responseSchema'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GoogleWorkspaceActionToJson(GoogleWorkspaceAction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'description': instance.description,
      'parameters': instance.parameters,
      'responseSchema': instance.responseSchema,
    };

GoogleWorkspaceParameter _$GoogleWorkspaceParameterFromJson(Map<String, dynamic> json) =>
    GoogleWorkspaceParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
      defaultValue: json['defaultValue'],
      enumValues: (json['enumValues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GoogleWorkspaceParameterToJson(GoogleWorkspaceParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'required': instance.required,
      'defaultValue': instance.defaultValue,
      'enumValues': instance.enumValues,
    };

T $enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  return enumValues.entries.singleWhere((e) => e.value == source).key;
}

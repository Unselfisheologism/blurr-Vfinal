// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_tool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemTool _$SystemToolFromJson(Map<String, dynamic> json) => SystemTool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$SystemToolCategoryEnumMap, json['category']),
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((e) =>
                  SystemToolParameter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      requiresPermission: json['requiresPermission'] as bool? ?? false,
      permissionName: json['permissionName'] as String?,
    );

Map<String, dynamic> _$SystemToolToJson(SystemTool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$SystemToolCategoryEnumMap[instance.category]!,
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
      'requiresPermission': instance.requiresPermission,
      'permissionName': instance.permissionName,
    };

const _$SystemToolCategoryEnumMap = {
  SystemToolCategory.uiAutomation: 'uiAutomation',
  SystemToolCategory.notification: 'notification',
  SystemToolCategory.accessibility: 'accessibility',
  SystemToolCategory.systemControl: 'systemControl',
  SystemToolCategory.phoneControl: 'phoneControl',
};

SystemToolParameter _$SystemToolParameterFromJson(Map<String, dynamic> json) =>
    SystemToolParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      required: json['required'] as bool? ?? true,
      defaultValue: json['defaultValue'],
      allowedValues: (json['allowedValues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SystemToolParameterToJson(
        SystemToolParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'required': instance.required,
      'defaultValue': instance.defaultValue,
      'allowedValues': instance.allowedValues,
    };

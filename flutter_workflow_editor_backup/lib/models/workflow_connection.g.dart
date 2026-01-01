// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_connection.dart';

WorkflowConnection _$WorkflowConnectionFromJson(Map<String, dynamic> json) =>
    WorkflowConnection(
      id: json['id'] as String,
      sourceNodeId: json['sourceNodeId'] as String,
      sourcePortId: json['sourcePortId'] as String,
      targetNodeId: json['targetNodeId'] as String,
      targetPortId: json['targetPortId'] as String,
      label: json['label'] as String?,
      color: json['color'] as String?,
      type: $enumDecodeNullable(_$ConnectionTypeEnumMap, json['type']) ??
          ConnectionType.normal,
    );

Map<String, dynamic> _$WorkflowConnectionToJson(WorkflowConnection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceNodeId': instance.sourceNodeId,
      'sourcePortId': instance.sourcePortId,
      'targetNodeId': instance.targetNodeId,
      'targetPortId': instance.targetPortId,
      'label': instance.label,
      'color': instance.color,
      'type': _$ConnectionTypeEnumMap[instance.type]!,
    };

const _$ConnectionTypeEnumMap = {
  ConnectionType.normal: 'normal',
  ConnectionType.error: 'error',
  ConnectionType.conditional: 'conditional',
};

T? $enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) return null;
  return enumValues.entries
      .singleWhere((e) => e.value == source)
      .key;
}

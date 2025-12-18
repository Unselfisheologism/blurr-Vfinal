/// Workflow connection model
library;

import 'package:json_annotation/json_annotation.dart';

part 'workflow_connection.g.dart';

@JsonSerializable()
class WorkflowConnection {
  final String id;
  final String sourceNodeId;
  final String sourcePortId;
  final String targetNodeId;
  final String targetPortId;
  
  // Visual properties for curved connections
  final String? label;
  final String? color;
  final ConnectionType type;

  WorkflowConnection({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePortId,
    required this.targetNodeId,
    required this.targetPortId,
    this.label,
    this.color,
    this.type = ConnectionType.normal,
  });

  factory WorkflowConnection.fromJson(Map<String, dynamic> json) =>
      _$WorkflowConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowConnectionToJson(this);

  WorkflowConnection copyWith({
    String? id,
    String? sourceNodeId,
    String? sourcePortId,
    String? targetNodeId,
    String? targetPortId,
    String? label,
    String? color,
    ConnectionType? type,
  }) {
    return WorkflowConnection(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      sourcePortId: sourcePortId ?? this.sourcePortId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      targetPortId: targetPortId ?? this.targetPortId,
      label: label ?? this.label,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}

enum ConnectionType {
  normal,
  error,
  conditional,
}

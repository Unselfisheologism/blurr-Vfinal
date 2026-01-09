/// Workflow node data for vyuh_node_flow integration
/// Encapsulates workflow-specific data that gets stored in vyuh_node_flow nodes
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Data class for workflow nodes compatible with vyuh_node_flow
/// This is the generic type T that gets passed to NodeFlowController<WorkflowNodeData>
class WorkflowNodeData extends Equatable {
  final String workflowNodeId;
  final String nodeType;
  final Map<String, dynamic> data;
  final String displayName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const WorkflowNodeData({
    required this.workflowNodeId,
    required this.nodeType,
    required this.data,
    required this.displayName,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Create a new WorkflowNodeData instance
  factory WorkflowNodeData.create({
    required String nodeType,
    required Map<String, dynamic> data,
    required String displayName,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return WorkflowNodeData(
      workflowNodeId: '',
      nodeType: nodeType,
      data: data,
      displayName: displayName,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }
  
  /// Create a copy with updated data
  WorkflowNodeData copyWith({
    String? workflowNodeId,
    String? nodeType,
    Map<String, dynamic>? data,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkflowNodeData(
      workflowNodeId: workflowNodeId ?? this.workflowNodeId,
      nodeType: nodeType ?? this.nodeType,
      data: data ?? Map.from(this.data),
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'workflowNodeId': workflowNodeId,
      'nodeType': nodeType,
      'data': data,
      'displayName': displayName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory WorkflowNodeData.fromJson(Map<String, dynamic> json) {
    return WorkflowNodeData(
      workflowNodeId: json['workflowNodeId'] as String,
      nodeType: json['nodeType'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      displayName: json['displayName'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
  
  @override
  List<Object?> get props => [
    workflowNodeId,
    nodeType,
    data,
    displayName,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'WorkflowNodeData(workflowNodeId: $workflowNodeId, nodeType: $nodeType, displayName: $displayName)';
  }
}

/// Data class for workflow connections
class WorkflowConnectionData extends Equatable {
  final String connectionId;
  final String sourceNodeId;
  final String sourcePortId;
  final String targetNodeId;
  final String targetPortId;
  final Map<String, dynamic> metadata;
  
  const WorkflowConnectionData({
    required this.connectionId,
    required this.sourceNodeId,
    required this.sourcePortId,
    required this.targetNodeId,
    required this.targetPortId,
    this.metadata = const {},
  });
  
  /// Create a new WorkflowConnectionData instance
  factory WorkflowConnectionData.create({
    required String sourceNodeId,
    required String sourcePortId,
    required String targetNodeId,
    required String targetPortId,
    Map<String, dynamic>? metadata,
  }) {
    return WorkflowConnectionData(
      connectionId: '',
      sourceNodeId: sourceNodeId,
      sourcePortId: sourcePortId,
      targetNodeId: targetNodeId,
      targetPortId: targetPortId,
      metadata: metadata ?? {},
    );
  }
  
  /// Create a copy with updated data
  WorkflowConnectionData copyWith({
    String? connectionId,
    String? sourceNodeId,
    String? sourcePortId,
    String? targetNodeId,
    String? targetPortId,
    Map<String, dynamic>? metadata,
  }) {
    return WorkflowConnectionData(
      connectionId: connectionId ?? this.connectionId,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      sourcePortId: sourcePortId ?? this.sourcePortId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      targetPortId: targetPortId ?? this.targetPortId,
      metadata: metadata ?? Map.from(this.metadata),
    );
  }
  
  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'connectionId': connectionId,
      'sourceNodeId': sourceNodeId,
      'sourcePortId': sourcePortId,
      'targetNodeId': targetNodeId,
      'targetPortId': targetPortId,
      'metadata': metadata,
    };
  }
  
  /// Create from JSON
  factory WorkflowConnectionData.fromJson(Map<String, dynamic> json) {
    return WorkflowConnectionData(
      connectionId: json['connectionId'] as String,
      sourceNodeId: json['sourceNodeId'] as String,
      sourcePortId: json['sourcePortId'] as String,
      targetNodeId: json['targetNodeId'] as String,
      targetPortId: json['targetPortId'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }
  
  @override
  List<Object?> get props => [
    connectionId,
    sourceNodeId,
    sourcePortId,
    targetNodeId,
    targetPortId,
    metadata,
  ];
  
  @override
  String toString() {
    return 'WorkflowConnectionData(connectionId: $connectionId, source: $sourceNodeId.$sourcePortId -> target: $targetNodeId.$targetPortId)';
  }
}

/// Utility extension for WorkflowNodeData
extension WorkflowNodeDataX on WorkflowNodeData {
  /// Check if node has specific data key
  bool hasData(String key) {
    return data.containsKey(key);
  }
  
  /// Get data value with type safety
  T? getData<T>(String key) {
    final value = data[key];
    if (value is T) return value;
    return null;
  }
  
  /// Set data value
  WorkflowNodeData setData(String key, dynamic value) {
    return copyWith(data: {...data, key: value});
  }
  
  /// Remove data key
  WorkflowNodeData removeData(String key) {
    final newData = Map<String, dynamic>.from(data);
    newData.remove(key);
    return copyWith(data: newData);
  }
  
  /// Update multiple data values
  WorkflowNodeData updateData(Map<String, dynamic> updates) {
    return copyWith(data: {...data, ...updates});
  }
}
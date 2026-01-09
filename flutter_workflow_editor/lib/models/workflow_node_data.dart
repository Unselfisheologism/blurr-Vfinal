/// Node data model for vyuh_node_flow integration
/// Stores workflow-specific data for each node
library;

import 'package:equatable/equatable.dart';

/// Workflow node data that encapsulates all node-specific information
class WorkflowNodeData extends Equatable {
  final String name;
  final String description;
  final String nodeType;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> executionResult;
  final DateTime? lastExecutedAt;
  final bool isExecuting;

  const WorkflowNodeData({
    required this.name,
    required this.description,
    required this.nodeType,
    this.parameters = const {},
    this.executionResult = const {},
    this.lastExecutedAt,
    this.isExecuting = false,
  });

  /// Create from JSON
  factory WorkflowNodeData.fromJson(Map<String, dynamic> json) {
    return WorkflowNodeData(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      nodeType: json['nodeType'] as String? ?? '',
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
      executionResult: (json['executionResult'] as Map<String, dynamic>?) ?? {},
      lastExecutedAt: json['lastExecutedAt'] != null
          ? DateTime.parse(json['lastExecutedAt'] as String)
          : null,
      isExecuting: json['isExecuting'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'nodeType': nodeType,
      'parameters': parameters,
      'executionResult': executionResult,
      'lastExecutedAt': lastExecutedAt?.toIso8601String(),
      'isExecuting': isExecuting,
    };
  }

  /// Create a copy with modified fields
  WorkflowNodeData copyWith({
    String? name,
    String? description,
    String? nodeType,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? executionResult,
    DateTime? lastExecutedAt,
    bool? isExecuting,
  }) {
    return WorkflowNodeData(
      name: name ?? this.name,
      description: description ?? this.description,
      nodeType: nodeType ?? this.nodeType,
      parameters: parameters ?? this.parameters,
      executionResult: executionResult ?? this.executionResult,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      isExecuting: isExecuting ?? this.isExecuting,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        nodeType,
        parameters,
        executionResult,
        lastExecutedAt,
        isExecuting,
      ];
}

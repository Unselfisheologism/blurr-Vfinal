/// Base workflow node model
library;

import 'package:json_annotation/json_annotation.dart';

part 'workflow_node.g.dart';

/// Node types matching n8n functionality
enum NodeType {
  // Triggers
  trigger,
  schedule,
  webhook,
  manual,
  
  // Actions
  action,
  composioAction,
  mcpAction,
  googleWorkspaceAction,
  httpRequest,
  code,
  
  // System-level Actions (Twent's unique capabilities)
  systemToolAction,
  uiAutomationAction,
  notificationAction,
  phoneControlAction,
  accessibilityAction,
  
  // Logic
  condition,
  ifElse,
  switch_,
  merge,
  split,
  loop,
  
  // Data
  setVariable,
  getVariable,
  function_,
  
  // Error handling
  errorTrigger,
  errorHandler,
  
  // AI
  aiAssist,
  llmCall,
}

/// Port types for connections
enum PortType {
  input,
  output,
  error,
}

@JsonSerializable()
class WorkflowNode {
  final String id;
  final String name;
  final NodeType type;
  final Map<String, dynamic> parameters;
  final List<NodePort> inputs;
  final List<NodePort> outputs;
  
  // Position for vertical layout (top-to-bottom)
  double x;
  double y;
  
  // Visual properties
  final String? icon;
  final String? color;
  final bool disabled;
  final String? notes;
  
  // Execution state
  @JsonKey(includeFromJson: false, includeToJson: false)
  NodeExecutionState executionState;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  dynamic executionResult;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? executionError;

  WorkflowNode({
    required this.id,
    required this.name,
    required this.type,
    this.parameters = const {},
    this.inputs = const [],
    this.outputs = const [],
    this.x = 0,
    this.y = 0,
    this.icon,
    this.color,
    this.disabled = false,
    this.notes,
    this.executionState = NodeExecutionState.idle,
    this.executionResult,
    this.executionError,
  });

  factory WorkflowNode.fromJson(Map<String, dynamic> json) =>
      _$WorkflowNodeFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowNodeToJson(this);

  WorkflowNode copyWith({
    String? id,
    String? name,
    NodeType? type,
    Map<String, dynamic>? parameters,
    List<NodePort>? inputs,
    List<NodePort>? outputs,
    double? x,
    double? y,
    String? icon,
    String? color,
    bool? disabled,
    String? notes,
    NodeExecutionState? executionState,
    dynamic executionResult,
    String? executionError,
  }) {
    return WorkflowNode(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      x: x ?? this.x,
      y: y ?? this.y,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      disabled: disabled ?? this.disabled,
      notes: notes ?? this.notes,
      executionState: executionState ?? this.executionState,
      executionResult: executionResult ?? this.executionResult,
      executionError: executionError ?? this.executionError,
    );
  }
}

@JsonSerializable()
class NodePort {
  final String id;
  final String name;
  final PortType type;
  final String? dataType;
  final bool required;

  NodePort({
    required this.id,
    required this.name,
    required this.type,
    this.dataType,
    this.required = false,
  });

  factory NodePort.fromJson(Map<String, dynamic> json) =>
      _$NodePortFromJson(json);

  Map<String, dynamic> toJson() => _$NodePortToJson(this);
}

enum NodeExecutionState {
  idle,
  running,
  success,
  error,
  waiting,
}

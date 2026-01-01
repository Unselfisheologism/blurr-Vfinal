/// Composio tool model
library;

import 'package:json_annotation/json_annotation.dart';

part 'composio_tool.g.dart';

@JsonSerializable()
class ComposioTool {
  final String id;
  final String name;
  final String appKey;
  final String? description;
  final String? icon;
  final List<ComposioAction> actions;
  final bool connected;

  ComposioTool({
    required this.id,
    required this.name,
    required this.appKey,
    this.description,
    this.icon,
    this.actions = const [],
    this.connected = false,
  });

  factory ComposioTool.fromJson(Map<String, dynamic> json) =>
      _$ComposioToolFromJson(json);

  Map<String, dynamic> toJson() => _$ComposioToolToJson(this);
}

@JsonSerializable()
class ComposioAction {
  final String name;
  final String displayName;
  final String? description;
  final List<ComposioParameter> parameters;
  final Map<String, dynamic>? responseSchema;

  ComposioAction({
    required this.name,
    required this.displayName,
    this.description,
    this.parameters = const [],
    this.responseSchema,
  });

  factory ComposioAction.fromJson(Map<String, dynamic> json) =>
      _$ComposioActionFromJson(json);

  Map<String, dynamic> toJson() => _$ComposioActionToJson(this);
}

@JsonSerializable()
class ComposioParameter {
  final String name;
  final String type;
  final String? description;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumValues;

  ComposioParameter({
    required this.name,
    required this.type,
    this.description,
    this.required = false,
    this.defaultValue,
    this.enumValues,
  });

  factory ComposioParameter.fromJson(Map<String, dynamic> json) =>
      _$ComposioParameterFromJson(json);

  Map<String, dynamic> toJson() => _$ComposioParameterToJson(this);
}

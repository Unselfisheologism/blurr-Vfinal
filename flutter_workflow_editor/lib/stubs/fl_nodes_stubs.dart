// Legacy stubs - kept for backward compatibility
//
// The project has migrated to vyuh_node_flow. These stubs exist only so that
// legacy prototype definitions can continue to compile while they are being
// phased out.

import 'package:flutter/material.dart';

typedef FlNodeExecute = Future<void> Function(
  dynamic ports,
  dynamic fields,
  dynamic state,
  dynamic flowTo,
  dynamic passData,
);

class NodePrototype {
  final String idName;
  final String displayName;
  final String description;

  final List<dynamic> ports;
  final FlNodeExecute? onExecute;
  final dynamic Function(dynamic state)? styleBuilder;

  const NodePrototype({
    required this.idName,
    required this.displayName,
    required this.description,
    this.ports = const [],
    this.onExecute,
    this.styleBuilder,
  });
}

class ControlInputPortPrototype {
  final String idName;
  final String displayName;
  final FlPortStyle? style;

  const ControlInputPortPrototype({
    required this.idName,
    required this.displayName,
    this.style,
  });
}

class ControlOutputPortPrototype {
  final String idName;
  final String displayName;
  final FlPortStyle? style;

  const ControlOutputPortPrototype({
    required this.idName,
    required this.displayName,
    this.style,
  });
}

class DataInputPortPrototype {
  final String idName;
  final String displayName;
  final dynamic dataType;
  final FlPortStyle? style;

  const DataInputPortPrototype({
    required this.idName,
    required this.displayName,
    this.dataType,
    this.style,
  });
}

class DataOutputPortPrototype {
  final String idName;
  final String displayName;
  final dynamic dataType;
  final FlPortStyle? style;

  const DataOutputPortPrototype({
    required this.idName,
    required this.displayName,
    this.dataType,
    this.style,
  });
}

class FlNodeStyle {
  final dynamic decoration;
  final Function? headerStyleBuilder;

  const FlNodeStyle({
    this.decoration,
    this.headerStyleBuilder,
  });
}

class FlNodeHeaderStyle {
  final dynamic decoration;
  final dynamic textStyle;
  final dynamic icon;
  final dynamic padding;

  const FlNodeHeaderStyle({
    this.decoration,
    this.textStyle,
    this.icon,
    this.padding,
  });
}

class FlPortStyle {
  final dynamic shape;
  final Color color;

  const FlPortStyle({
    required this.shape,
    required this.color,
  });
}

class FlPortShape {
  static const circle = 'circle';
  static const triangle = 'triangle';
  static const square = 'square';
}

// Additional stubs required by the legacy FlWorkflowCanvas implementation.

class FlNodeEditorController extends ChangeNotifier {
  final Future<bool> Function(Map<String, dynamic> jsonData)? projectSaver;
  final Future<Map<String, dynamic>?> Function(bool isSaved)? projectLoader;
  final Future<bool> Function(bool isSaved)? projectCreator;

  final FlNodeProject project = FlNodeProject();
  final FlNodeRunner runner = FlNodeRunner();

  FlNodeEditorController({
    this.projectSaver,
    this.projectLoader,
    this.projectCreator,
  });

  void registerNodePrototype(NodePrototype prototype) {}
}

class FlNodeRunner {
  Future<void> executeGraph() async {}
}

class FlNodeProject {
  final Map<String, dynamic> nodes = {};
  final Map<String, dynamic> links = {};
}

class FlNodeStub {
  final String id;
  final NodePrototype prototype;
  Offset position;
  final Map<String, dynamic> fields;

  FlNodeStub({
    required this.id,
    required this.prototype,
    required this.position,
    this.fields = const {},
  });
}

class FlLinkStub {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final String sourcePortId;
  final String targetPortId;

  FlLinkStub({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.sourcePortId,
    required this.targetPortId,
  });
}

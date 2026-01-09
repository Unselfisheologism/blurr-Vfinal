// Legacy stubs - kept for backward compatibility
// This file will be removed once all fl_nodes references are removed

// Note: The project has migrated to vyuh_node_flow
// This file is kept temporarily to prevent compilation errors
// during the transition period

import 'package:flutter/material.dart';

// Empty stubs to allow compilation
class NodePrototype {
  final String idName;
  final String displayName;
  final String description;

  const NodePrototype({
    required this.idName,
    required this.displayName,
    required this.description,
  });
}

class ControlInputPortPrototype {
  final String idName;
  final String displayName;

  const ControlInputPortPrototype({
    required this.idName,
    required this.displayName,
  });
}

class ControlOutputPortPrototype {
  final String idName;
  final String displayName;

  const ControlOutputPortPrototype({
    required this.idName,
    required this.displayName,
  });
}

class DataInputPortPrototype {
  final String idName;
  final String displayName;
  final dynamic dataType;

  const DataInputPortPrototype({
    required this.idName,
    required this.displayName,
    this.dataType,
  });
}

class DataOutputPortPrototype {
  final String idName;
  final String displayName;
  final dynamic dataType;

  const DataOutputPortPrototype({
    required this.idName,
    required this.displayName,
    this.dataType,
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

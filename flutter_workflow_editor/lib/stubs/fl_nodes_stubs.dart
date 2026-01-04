// Simple stubs to replace broken fl_nodes_workspace dependency
// This allows the Flutter module to compile while preserving the structure

import 'package:flutter/material.dart';

/// Stub classes for fl_nodes_workspace API
class NodePrototype {
  final String idName;
  final String displayName;
  final String description;
  final List<dynamic> ports;
  final Function? onExecute;
  final Function? styleBuilder;

  const NodePrototype({
    required this.idName,
    required this.displayName,
    required this.description,
    required this.ports,
    this.onExecute,
    this.styleBuilder,
  });
}

class ControlInputPortPrototype {
  final String idName;
  final String displayName;
  final dynamic style;

  const ControlInputPortPrototype({
    required this.idName,
    required this.displayName,
    this.style,
  });
}

class ControlOutputPortPrototype {
  final String idName;
  final String displayName;
  final dynamic style;

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
  final dynamic style;

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
  final dynamic style;

  const DataOutputPortPrototype({
    required this.idName,
    required this.displayName,
    this.dataType,
    this.style,
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

  const FlNodeHeaderStyle({
    this.decoration,
    this.textStyle,
    this.icon,
  });
}

// Stub extension for firstOrNull
extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
/// Vertical layout adapter for fl_nodes
/// Enforces top-to-bottom flow while preserving all fl_nodes features
library;

import 'package:flutter/material.dart';
import '../stubs/fl_nodes_stubs.dart';

/// Vertical layout configuration
class VerticalLayoutConfig {
  final double nodeSpacingY;
  final double nodeSpacingX;
  final double startY;
  final bool autoArrange;
  
  const VerticalLayoutConfig({
    this.nodeSpacingY = 120.0,
    this.nodeSpacingX = 200.0,
    this.startY = 100.0,
    this.autoArrange = true,
  });
}

/// Manages vertical layout for workflow nodes
class VerticalLayoutAdapter {
  final VerticalLayoutConfig config;
  
  VerticalLayoutAdapter({
    this.config = const VerticalLayoutConfig(),
  });
  
  /// Calculate optimal position for a new node
  Offset calculateNewNodePosition(
    List<dynamic> existingNodes,
    dynamic parentNode,
  ) {
    if (parentNode != null) {
      // Position below parent
      return Offset(
        parentNode.position.dx,
        parentNode.position.dy + config.nodeSpacingY,
      );
    }
    
    // Position at top if no parent (trigger node)
    if (existingNodes.isEmpty) {
      return Offset(0, config.startY);
    }
    
    // Find rightmost position at top
    final topNodes = existingNodes.where((n) => n.position.dy < config.startY + 50);
    if (topNodes.isEmpty) {
      return Offset(0, config.startY);
    }
    
    final maxX = topNodes.map((n) => n.position.dx).reduce((a, b) => a > b ? a : b);
    return Offset(maxX + config.nodeSpacingX, config.startY);
  }
  
  /// Auto-arrange all nodes vertically
  void autoArrangeNodes(List<dynamic> nodes, List<dynamic> connections) {
    if (!config.autoArrange || nodes.isEmpty) return;
    
    // Build dependency graph
    final graph = <String, List<String>>{};
    for (final conn in connections) {
      graph.putIfAbsent(conn.sourceNodeId, () => []).add(conn.targetNodeId);
    }
    
    // Find root nodes (triggers with no incoming connections)
    final hasIncoming = connections.map((c) => c.targetNodeId).toSet();
    final roots = nodes.where((n) => !hasIncoming.contains(n.id)).toList();
    
    // Perform level-based layout
    final levels = <int, List<dynamic>>{};
    final visited = <String>{};
    
    void assignLevel(dynamic node, int level) {
      if (visited.contains(node.id)) return;
      visited.add(node.id);
      
      levels.putIfAbsent(level, () => []).add(node);
      
      // Process children
      final children = graph[node.id] ?? [];
      for (final childId in children) {
        final child = nodes.firstWhere((n) => n.id == childId);
        assignLevel(child, level + 1);
      }
    }
    
    // Assign levels starting from roots
    for (final root in roots) {
      assignLevel(root, 0);
    }
    
    // Position nodes based on levels
    for (final entry in levels.entries) {
      final level = entry.key;
      final nodesAtLevel = entry.value;
      
      final y = config.startY + (level * config.nodeSpacingY);
      
      for (var i = 0; i < nodesAtLevel.length; i++) {
        final node = nodesAtLevel[i];
        final x = i * config.nodeSpacingX;
        node.position = Offset(x, y);
      }
    }
  }
  
  /// Validate vertical flow (no upward connections)
  List<String> validateVerticalFlow(List<dynamic> nodes, List<dynamic> connections) {
    final errors = <String>[];
    
    for (final conn in connections) {
      final source = nodes.firstWhere((n) => n.id == conn.sourceNodeId);
      final target = nodes.firstWhere((n) => n.id == conn.targetNodeId);
      
      if (source.position.dy > target.position.dy) {
        errors.add('Connection flows upward: ${source.id} -> ${target.id}');
      }
    }
    
    return errors;
  }
}

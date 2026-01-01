/// Vertical layout engine for top-to-bottom node flow
/// Customizes fl_nodes to enforce vertical layout
library;

import 'dart:math' as math;
import '../models/workflow_node.dart';
import '../models/workflow_connection.dart';

class VerticalLayoutEngine {
  static const double nodeWidth = 240.0;
  static const double nodeHeight = 100.0;
  static const double horizontalSpacing = 320.0;
  static const double verticalSpacing = 180.0;
  static const double startX = 500.0;
  static const double startY = 100.0;

  /// Calculate layout for all nodes (top to bottom)
  static void layoutNodes(
    List<WorkflowNode> nodes,
    List<WorkflowConnection> connections,
  ) {
    if (nodes.isEmpty) return;

    // Build adjacency map for graph traversal
    final adjacency = _buildAdjacencyMap(nodes, connections);

    // Calculate depth (level) for each node
    final depths = _calculateDepths(nodes, connections, adjacency);

    // Group nodes by depth
    final levels = <int, List<WorkflowNode>>{};
    for (final node in nodes) {
      final depth = depths[node.id] ?? 0;
      levels.putIfAbsent(depth, () => []);
      levels[depth]!.add(node);
    }

    // Position nodes vertically
    _positionNodesVertically(levels);

    // Minimize crossings (optional optimization)
    _minimizeCrossings(levels, connections);
  }

  /// Build adjacency map from connections
  static Map<String, List<String>> _buildAdjacencyMap(
    List<WorkflowNode> nodes,
    List<WorkflowConnection> connections,
  ) {
    final adjacency = <String, List<String>>{};

    for (final node in nodes) {
      adjacency[node.id] = [];
    }

    for (final conn in connections) {
      adjacency[conn.sourceNodeId]?.add(conn.targetNodeId);
    }

    return adjacency;
  }

  /// Calculate depth (level) for each node using BFS
  static Map<String, int> _calculateDepths(
    List<WorkflowNode> nodes,
    List<WorkflowConnection> connections,
    Map<String, List<String>> adjacency,
  ) {
    final depths = <String, int>{};
    final inDegree = <String, int>{};

    // Initialize in-degree
    for (final node in nodes) {
      inDegree[node.id] = 0;
    }

    for (final conn in connections) {
      inDegree[conn.targetNodeId] = (inDegree[conn.targetNodeId] ?? 0) + 1;
    }

    // Find root nodes (in-degree = 0)
    final roots = nodes.where((node) => inDegree[node.id] == 0).toList();

    // BFS to assign depths
    final queue = <(String, int)>[];
    for (final root in roots) {
      queue.add((root.id, 0));
      depths[root.id] = 0;
    }

    while (queue.isNotEmpty) {
      final (nodeId, depth) = queue.removeAt(0);

      for (final childId in adjacency[nodeId] ?? []) {
        final newDepth = depth + 1;
        
        if (!depths.containsKey(childId) || depths[childId]! < newDepth) {
          depths[childId] = newDepth;
          queue.add((childId, newDepth));
        }
      }
    }

    // Assign depth 0 to any orphaned nodes
    for (final node in nodes) {
      depths.putIfAbsent(node.id, () => 0);
    }

    return depths;
  }

  /// Position nodes vertically based on levels
  static void _positionNodesVertically(Map<int, List<WorkflowNode>> levels) {
    double currentY = startY;

    final sortedDepths = levels.keys.toList()..sort();

    for (final depth in sortedDepths) {
      final nodesAtLevel = levels[depth]!;

      // Calculate horizontal positions for nodes at this level
      final totalWidth = nodesAtLevel.length * nodeWidth +
          (nodesAtLevel.length - 1) * (horizontalSpacing - nodeWidth);
      double startXForLevel = startX - (totalWidth / 2);

      // Sort nodes at level by their connections (left to right)
      _sortNodesByConnections(nodesAtLevel);

      for (int i = 0; i < nodesAtLevel.length; i++) {
        final node = nodesAtLevel[i];
        node.x = startXForLevel + (i * horizontalSpacing);
        node.y = currentY;
      }

      currentY += verticalSpacing;
    }
  }

  /// Sort nodes at the same level to minimize crossings
  static void _sortNodesByConnections(List<WorkflowNode> nodes) {
    // Simple heuristic: sort by average X position of parent nodes
    nodes.sort((a, b) {
      final aX = a.x;
      final bX = b.x;
      return aX.compareTo(bX);
    });
  }

  /// Minimize edge crossings (Sugiyama framework)
  static void _minimizeCrossings(
    Map<int, List<WorkflowNode>> levels,
    List<WorkflowConnection> connections,
  ) {
    // Simplified crossing minimization
    // Full implementation would use median heuristic and layer-by-layer sweeps

    final sortedDepths = levels.keys.toList()..sort();

    for (int i = 1; i < sortedDepths.length; i++) {
      final currentLevel = levels[sortedDepths[i]]!;
      final previousLevel = levels[sortedDepths[i - 1]]!;

      // Calculate median positions based on parent nodes
      for (final node in currentLevel) {
        final parentConnections = connections.where(
          (conn) => conn.targetNodeId == node.id,
        );

        if (parentConnections.isEmpty) continue;

        final parentXPositions = parentConnections
            .map((conn) {
              return previousLevel
                  .firstWhere((n) => n.id == conn.sourceNodeId, orElse: () => node)
                  .x;
            })
            .toList()
          ..sort();

        // Set X to median of parent positions
        if (parentXPositions.isNotEmpty) {
          final median = parentXPositions[parentXPositions.length ~/ 2];
          node.x = median;
        }
      }

      // Resolve collisions at current level
      _resolveCollisions(currentLevel);
    }
  }

  /// Resolve node collisions at the same level
  static void _resolveCollisions(List<WorkflowNode> nodes) {
    if (nodes.length <= 1) return;

    // Sort by X position
    nodes.sort((a, b) => a.x.compareTo(b.x));

    // Ensure minimum spacing
    for (int i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1];
      final curr = nodes[i];

      final minX = prev.x + horizontalSpacing;
      if (curr.x < minX) {
        curr.x = minX;
      }
    }
  }

  /// Calculate edge path for vertical flow (downward curve)
  static List<Offset> calculateEdgePath(
    WorkflowNode source,
    WorkflowNode target,
  ) {
    final sourceX = source.x + nodeWidth / 2;
    final sourceY = source.y + nodeHeight;
    final targetX = target.x + nodeWidth / 2;
    final targetY = target.y;

    final midY = (sourceY + targetY) / 2;

    // Cubic bezier curve for smooth downward flow
    return [
      Offset(sourceX, sourceY),
      Offset(sourceX, midY),
      Offset(targetX, midY),
      Offset(targetX, targetY),
    ];
  }

  /// Calculate bounds for all nodes
  static Rect calculateBounds(List<WorkflowNode> nodes) {
    if (nodes.isEmpty) {
      return const Rect.fromLTWH(0, 0, 1000, 1000);
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      minX = math.min(minX, node.x);
      minY = math.min(minY, node.y);
      maxX = math.max(maxX, node.x + nodeWidth);
      maxY = math.max(maxY, node.y + nodeHeight);
    }

    // Add padding
    const padding = 100.0;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }
}

class Offset {
  final double dx;
  final double dy;

  const Offset(this.dx, this.dy);
}

class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const Rect.fromLTRB(this.left, this.top, this.right, this.bottom);
  const Rect.fromLTWH(this.left, this.top, double width, double height)
      : right = left + width,
        bottom = top + height;

  double get width => right - left;
  double get height => bottom - top;
}

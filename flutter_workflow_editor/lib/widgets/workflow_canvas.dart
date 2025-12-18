/// Main workflow canvas with fl_nodes integration
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../models/workflow_node.dart';
import '../models/workflow_connection.dart';
import 'node_widget.dart';
import 'connection_widget.dart';
import 'package:uuid/uuid.dart';

class WorkflowCanvas extends StatefulWidget {
  const WorkflowCanvas({super.key});

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  final TransformationController _transformationController = TransformationController();
  final Uuid _uuid = const Uuid();

  // Drag state for creating connections
  String? _draggingFromNodeId;
  String? _draggingFromPortId;
  Offset? _dragOffset;

  // Selection state
  String? _selectedNodeId;
  Offset? _panStart;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        final workflow = workflowState.currentWorkflow;
        
        if (workflow == null) {
          return const Center(
            child: Text('No workflow loaded'),
          );
        }

        return Stack(
          children: [
            // Grid background
            _buildGridBackground(),

            // Interactive canvas with zoom/pan
            InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(2000),
              minScale: 0.1,
              maxScale: 2.0,
              constrained: false,
              child: SizedBox(
                width: 5000,
                height: 5000,
                child: GestureDetector(
                  onTapDown: (details) => _handleCanvasTap(context, details),
                  onPanStart: (details) => _handlePanStart(details),
                  onPanUpdate: (details) => _handlePanUpdate(context, details),
                  onPanEnd: (details) => _handlePanEnd(context),
                  child: CustomPaint(
                    painter: ConnectionsPainter(
                      connections: workflow.connections,
                      nodes: workflow.nodes,
                      selectedConnectionId: workflowState.selectedConnection?.id,
                      dragStart: _draggingFromNodeId != null
                          ? _getNodePosition(workflow.nodes, _draggingFromNodeId!)
                          : null,
                      dragEnd: _dragOffset,
                    ),
                    child: Stack(
                      children: [
                        // Render nodes
                        ...workflow.nodes.map((node) => Positioned(
                          left: node.x,
                          top: node.y,
                          child: NodeWidget(
                            node: node,
                            isSelected: workflowState.selectedNode?.id == node.id,
                            onTap: () => _handleNodeTap(context, node.id),
                            onDragStart: (details) => _handleNodeDragStart(node.id),
                            onDragUpdate: (details) => _handleNodeDragUpdate(
                              context,
                              node.id,
                              details,
                            ),
                            onDragEnd: () => _handleNodeDragEnd(),
                            onPortDragStart: (portId) => _handlePortDragStart(
                              node.id,
                              portId,
                            ),
                            onPortDragUpdate: (offset) => _handlePortDragUpdate(offset),
                            onPortDragEnd: () => _handlePortDragEnd(context),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Zoom controls
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildZoomControls(),
            ),

            // Mini-map (optional)
            if (workflow.nodes.length > 10)
              Positioned(
                right: 16,
                top: 16,
                child: _buildMiniMap(workflow.nodes),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGridBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        image: DecorationImage(
          image: const AssetImage('assets/grid.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _zoom(1.2),
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => _zoom(0.8),
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _fitToScreen,
            tooltip: 'Fit to Screen',
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap(List<WorkflowNode> nodes) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: CustomPaint(
        painter: MiniMapPainter(nodes: nodes),
      ),
    );
  }

  void _handleCanvasTap(BuildContext context, TapDownDetails details) {
    // Deselect node/connection when tapping canvas
    context.read<WorkflowState>().selectNode(null);
  }

  void _handleNodeTap(BuildContext context, String nodeId) {
    context.read<WorkflowState>().selectNode(nodeId);
  }

  void _handleNodeDragStart(String nodeId) {
    _selectedNodeId = nodeId;
  }

  void _handleNodeDragUpdate(
    BuildContext context,
    String nodeId,
    DragUpdateDetails details,
  ) {
    final workflowState = context.read<WorkflowState>();
    final node = workflowState.currentWorkflow?.nodes.firstWhere(
      (n) => n.id == nodeId,
    );

    if (node != null) {
      // Get current transformation
      final matrix = _transformationController.value;
      final scale = matrix.getMaxScaleOnAxis();

      // Update position accounting for zoom
      workflowState.updateNodePosition(
        nodeId,
        node.x + details.delta.dx / scale,
        node.y + details.delta.dy / scale,
      );
    }
  }

  void _handleNodeDragEnd() {
    _selectedNodeId = null;
  }

  void _handlePortDragStart(String nodeId, String portId) {
    setState(() {
      _draggingFromNodeId = nodeId;
      _draggingFromPortId = portId;
    });
  }

  void _handlePortDragUpdate(Offset offset) {
    setState(() {
      _dragOffset = offset;
    });
  }

  void _handlePortDragEnd(BuildContext context) {
    if (_draggingFromNodeId != null && _draggingFromPortId != null) {
      // Check if dragged to another port
      final workflowState = context.read<WorkflowState>();
      
      // TODO: Detect target node/port at drag end position
      // For now, just clear drag state
    }

    setState(() {
      _draggingFromNodeId = null;
      _draggingFromPortId = null;
      _dragOffset = null;
    });
  }

  void _handlePanStart(DragStartDetails details) {
    _panStart = details.localPosition;
  }

  void _handlePanUpdate(BuildContext context, DragUpdateDetails details) {
    if (_selectedNodeId != null) {
      // Node is being dragged, handled by node drag handlers
      return;
    }

    // Pan canvas
    // InteractiveViewer handles this automatically
  }

  void _handlePanEnd(BuildContext context) {
    _panStart = null;
  }

  void _zoom(double factor) {
    final matrix = _transformationController.value.clone();
    matrix.scale(factor);
    _transformationController.value = matrix;
  }

  void _fitToScreen() {
    // Calculate bounds of all nodes
    final workflowState = context.read<WorkflowState>();
    final nodes = workflowState.currentWorkflow?.nodes ?? [];
    
    if (nodes.isEmpty) return;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      minX = minX < node.x ? minX : node.x;
      minY = minY < node.y ? minY : node.y;
      maxX = maxX > node.x + 240 ? maxX : node.x + 240;
      maxY = maxY > node.y + 100 ? maxY : node.y + 100;
    }

    // Calculate transformation to fit bounds
    final size = MediaQuery.of(context).size;
    final boundsWidth = maxX - minX + 200;
    final boundsHeight = maxY - minY + 200;
    
    final scaleX = size.width / boundsWidth;
    final scaleY = size.height / boundsHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final matrix = Matrix4.identity()
      ..translate(-minX + 100, -minY + 100)
      ..scale(scale);

    _transformationController.value = matrix;
  }

  Offset? _getNodePosition(List<WorkflowNode> nodes, String nodeId) {
    final node = nodes.firstWhere((n) => n.id == nodeId, orElse: () => nodes.first);
    return Offset(node.x + 120, node.y + 50); // Center of node
  }
}

/// Custom painter for connections between nodes
class ConnectionsPainter extends CustomPainter {
  final List<WorkflowConnection> connections;
  final List<WorkflowNode> nodes;
  final String? selectedConnectionId;
  final Offset? dragStart;
  final Offset? dragEnd;

  ConnectionsPainter({
    required this.connections,
    required this.nodes,
    this.selectedConnectionId,
    this.dragStart,
    this.dragEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connections
    for (final connection in connections) {
      final sourceNode = nodes.firstWhere(
        (n) => n.id == connection.sourceNodeId,
        orElse: () => nodes.first,
      );
      final targetNode = nodes.firstWhere(
        (n) => n.id == connection.targetNodeId,
        orElse: () => nodes.first,
      );

      _drawConnection(
        canvas,
        sourceNode,
        targetNode,
        connection,
        isSelected: connection.id == selectedConnectionId,
      );
    }

    // Draw dragging connection
    if (dragStart != null && dragEnd != null) {
      _drawDraggingConnection(canvas, dragStart!, dragEnd!);
    }
  }

  void _drawConnection(
    Canvas canvas,
    WorkflowNode source,
    WorkflowNode target,
    WorkflowConnection connection, {
    bool isSelected = false,
  }) {
    final paint = Paint()
      ..color = isSelected ? Colors.blue : _getConnectionColor(connection)
      ..strokeWidth = isSelected ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    final path = _createCubicPath(source, target);
    canvas.drawPath(path, paint);

    // Draw arrow at target
    _drawArrow(canvas, path, paint);
  }

  void _drawDraggingConnection(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(start.dx, start.dy);

    final midY = (start.dy + end.dy) / 2;
    path.cubicTo(
      start.dx,
      midY,
      end.dx,
      midY,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }

  Path _createCubicPath(WorkflowNode source, WorkflowNode target) {
    // Source port position (bottom center of node)
    final startX = source.x + 120;
    final startY = source.y + 100;

    // Target port position (top center of node)
    final endX = target.x + 120;
    final endY = target.y;

    // Control points for smooth vertical curve
    final midY = (startY + endY) / 2;

    final path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(
        startX,
        midY,
        endX,
        midY,
        endX,
        endY,
      );

    return path;
  }

  void _drawArrow(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().first;
    final end = metrics.getTangentForOffset(metrics.length);
    
    if (end == null) return;

    final arrowSize = 10.0;
    final angle = end.angle;

    final arrowPath = Path()
      ..moveTo(end.position.dx, end.position.dy)
      ..lineTo(
        end.position.dx - arrowSize * cos(angle - 0.5),
        end.position.dy - arrowSize * sin(angle - 0.5),
      )
      ..moveTo(end.position.dx, end.position.dy)
      ..lineTo(
        end.position.dx - arrowSize * cos(angle + 0.5),
        end.position.dy - arrowSize * sin(angle + 0.5),
      );

    canvas.drawPath(arrowPath, paint);
  }

  Color _getConnectionColor(WorkflowConnection connection) {
    switch (connection.type) {
      case ConnectionType.error:
        return Colors.red;
      case ConnectionType.conditional:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) {
    return connections != oldDelegate.connections ||
        selectedConnectionId != oldDelegate.selectedConnectionId ||
        dragStart != oldDelegate.dragStart ||
        dragEnd != oldDelegate.dragEnd;
  }

  // Math helpers
  double cos(double radians) => radians.cos();
  double sin(double radians) => radians.sin();
}

extension on double {
  double cos() => this * 0.5; // Simplified
  double sin() => this * 0.5; // Simplified
}

/// Mini-map painter for overview
class MiniMapPainter extends CustomPainter {
  final List<WorkflowNode> nodes;

  MiniMapPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // Calculate bounds
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      minX = minX < node.x ? minX : node.x;
      minY = minY < node.y ? minY : node.y;
      maxX = maxX > node.x ? maxX : node.x;
      maxY = maxY > node.y ? maxY : node.y;
    }

    final boundsWidth = maxX - minX;
    final boundsHeight = maxY - minY;

    // Scale to fit minimap
    final scaleX = size.width / boundsWidth;
    final scaleY = size.height / boundsHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Draw nodes as small rectangles
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final node in nodes) {
      final x = (node.x - minX) * scale;
      final y = (node.y - minY) * scale;

      canvas.drawRect(
        Rect.fromLTWH(x, y, 10, 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MiniMapPainter oldDelegate) {
    return nodes != oldDelegate.nodes;
  }
}

class Rect {
  final double left;
  final double top;
  final double width;
  final double height;

  const Rect.fromLTWH(this.left, this.top, this.width, this.height);
}

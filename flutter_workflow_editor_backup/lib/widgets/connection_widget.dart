/// Connection widget (edges between nodes)
library;

import 'package:flutter/material.dart';
import '../models/workflow_connection.dart';

class ConnectionWidget extends StatelessWidget {
  final WorkflowConnection connection;
  final bool isSelected;
  final VoidCallback onTap;

  const ConnectionWidget({
    super.key,
    required this.connection,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: ConnectionPainter(
          connection: connection,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final WorkflowConnection connection;
  final bool isSelected;

  ConnectionPainter({
    required this.connection,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getColor()
      ..strokeWidth = isSelected ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    // Draw connection path
    // Actual path drawing is handled by ConnectionsPainter in workflow_canvas.dart
  }

  Color _getColor() {
    if (connection.color != null) {
      return Color(int.parse(connection.color!.replaceFirst('#', '0xFF')));
    }

    switch (connection.type) {
      case ConnectionType.error:
        return Colors.red;
      case ConnectionType.conditional:
        return Colors.orange;
      default:
        return isSelected ? Colors.blue : Colors.grey;
    }
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return connection != oldDelegate.connection ||
        isSelected != oldDelegate.isSelected;
  }
}

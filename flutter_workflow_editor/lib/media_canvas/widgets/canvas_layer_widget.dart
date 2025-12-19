/// Widget for rendering individual layers on canvas
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_layer_node.dart';

class CanvasLayerWidget extends StatelessWidget {
  final MediaLayerNode layer;
  final bool isSelected;
  final VoidCallback? onTap;

  const CanvasLayerWidget({
    super.key,
    required this.layer,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!layer.visible) return const SizedBox.shrink();

    return Positioned(
      left: layer.transform.x,
      top: layer.transform.y,
      child: GestureDetector(
        onTap: onTap,
        child: Transform.rotate(
          angle: layer.transform.rotation,
          child: Transform.scale(
            scaleX: layer.transform.scaleX,
            scaleY: layer.transform.scaleY,
            child: Opacity(
              opacity: layer.transform.opacity,
              child: Container(
                width: layer.transform.width,
                height: layer.transform.height,
                decoration: isSelected
                    ? BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                      )
                    : null,
                child: _buildLayerContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerContent() {
    switch (layer.type) {
      case MediaLayerType.image:
        return _buildImageLayer();
      case MediaLayerType.video:
        return _buildVideoLayer();
      case MediaLayerType.audio:
        return _buildAudioLayer();
      case MediaLayerType.text:
        return _buildTextLayer();
      case MediaLayerType.shape:
        return _buildShapeLayer();
      case MediaLayerType.group:
        return _buildGroupLayer();
      case MediaLayerType.model3d:
        return _build3DModelLayer();
    }
  }

  Widget _buildImageLayer() {
    final imageUrl = layer.imageUrl;
    if (imageUrl == null) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.image, size: 48)),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );
  }

  Widget _buildVideoLayer() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video thumbnail or player would go here
          Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          // Video URL indicator
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioLayer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border.all(color: Colors.purple.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.audiotrack, color: Colors.purple.shade700),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layer.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Waveform placeholder
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.play_arrow, color: Colors.purple.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLayer() {
    final content = layer.textContent ?? '';
    final data = layer.data ?? {};
    final fontSize = (data['fontSize'] as num?)?.toDouble() ?? 24.0;
    final textColor = _parseColor(data['textColor'] as String?) ?? Colors.black;
    final backgroundColor = _parseColor(data['backgroundColor'] as String?);
    final bold = data['bold'] as bool? ?? false;
    final italic = data['italic'] as bool? ?? false;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(8),
      child: Text(
        content,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildShapeLayer() {
    final shapeType = layer.shapeType ?? 'rectangle';
    final data = layer.data ?? {};
    final fillColor = _parseColor(data['fillColor'] as String?) ?? Colors.blue;
    final strokeColor = _parseColor(data['strokeColor'] as String?) ?? Colors.black;
    final strokeWidth = (data['strokeWidth'] as num?)?.toDouble() ?? 2.0;

    return CustomPaint(
      painter: ShapePainter(
        shapeType: shapeType,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
      ),
      size: Size(layer.transform.width, layer.transform.height),
    );
  }

  Widget _buildGroupLayer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder, size: 48, color: Colors.green.shade600),
            const SizedBox(height: 8),
            Text(
              layer.name,
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DModelLayer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border.all(color: Colors.indigo.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // 3D model preview placeholder
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.view_in_ar, size: 64, color: Colors.indigo.shade700),
                const SizedBox(height: 8),
                Text(
                  layer.name,
                  style: TextStyle(
                    color: Colors.indigo.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  layer.modelFormat?.toUpperCase() ?? '3D MODEL',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.indigo.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Format indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                layer.modelFormat?.toUpperCase() ?? 'GLB',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String? hexColor) {
    if (hexColor == null) return null;
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

/// Custom painter for shapes
class ShapePainter extends CustomPainter {
  final String shapeType;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  ShapePainter({
    required this.shapeType,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    switch (shapeType) {
      case 'rectangle':
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, strokePaint);
        break;

      case 'circle':
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width.clamp(0, size.height) / 2;
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, strokePaint);
        break;

      case 'line':
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          strokePaint,
        );
        break;

      case 'arrow':
        final path = Path();
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width - 20, size.height / 2);
        path.lineTo(size.width - 30, size.height / 2 - 10);
        path.moveTo(size.width - 20, size.height / 2);
        path.lineTo(size.width - 30, size.height / 2 + 10);
        canvas.drawPath(path, strokePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

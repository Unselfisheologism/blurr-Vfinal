/// Canvas export and rendering service
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_layer_node.dart';

class CanvasExportService {
  /// Export canvas to image
  Future<String?> exportToImage({
    required GlobalKey canvasKey,
    required String fileName,
  }) async {
    try {
      // Find the render object
      final boundary = canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Canvas not found');
      }

      // Capture image
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to capture canvas');
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return filePath;
    } catch (e) {
      print('Error exporting canvas: $e');
      return null;
    }
  }

  /// Export canvas as PDF (Pro feature)
  Future<String?> exportToPdf({
    required CanvasDocument document,
    required String fileName,
  }) async {
    try {
      // TODO: Implement PDF generation
      // Could use pdf package to generate multi-page PDF from layers
      throw UnimplementedError('PDF export coming soon');
    } catch (e) {
      print('Error exporting to PDF: $e');
      return null;
    }
  }

  /// Export as video (Pro feature - for animated canvases)
  Future<String?> exportToVideo({
    required CanvasDocument document,
    required String fileName,
    required double duration,
  }) async {
    try {
      // TODO: Implement video export
      // Would need to render frames and encode to video
      throw UnimplementedError('Video export coming soon');
    } catch (e) {
      print('Error exporting to video: $e');
      return null;
    }
  }

  /// Get export formats available
  List<String> getAvailableFormats({bool isPro = false}) {
    final formats = ['PNG', 'JPEG'];
    if (isPro) {
      formats.addAll(['PDF', 'SVG', 'Video']);
    }
    return formats;
  }
}

import 'dart:convert';

import '../models/video_project.dart';
import 'video_editor_bridge.dart';

/// Export orchestrator.
///
/// Rendering is performed on the Kotlin host via FFmpegKit.
class VideoExportService {
  final VideoEditorBridge _bridge;

  VideoExportService({VideoEditorBridge? bridge}) : _bridge = bridge ?? VideoEditorBridge();

  Future<VideoExportResult> exportProject(VideoProject project) async {
    try {
      final response = await _bridge.exportTimeline(
        timelineJson: jsonEncode(project.toJson()),
      );

      final success = response['success'] == true;
      if (success) {
        return VideoExportResult.success(response['filePath'] as String?);
      }
      return VideoExportResult.failure(response['error']?.toString());
    } catch (e) {
      return VideoExportResult.failure(e.toString());
    }
  }
}

class VideoExportResult {
  final bool success;
  final String? filePath;
  final String? error;

  const VideoExportResult._({
    required this.success,
    this.filePath,
    this.error,
  });

  factory VideoExportResult.success(String? filePath) {
    return VideoExportResult._(success: true, filePath: filePath);
  }

  factory VideoExportResult.failure(String? error) {
    return VideoExportResult._(success: false, error: error);
  }
}

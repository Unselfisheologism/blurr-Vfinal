import 'dart:convert';

import '../models/media_asset.dart';
import '../models/video_clip.dart';
import '../models/video_project.dart';
import '../models/video_transition.dart';
import 'video_editor_bridge.dart';

class VideoAIService {
  final VideoEditorBridge _bridge;

  VideoAIService({VideoEditorBridge? bridge}) : _bridge = bridge ?? VideoEditorBridge();

  Future<String?> generateCaptionsSrt({
    required VideoClip clip,
    String language = 'en',
  }) async {
    final result = await _bridge.generateCaptions(
      clipUri: clip.uri,
      language: language,
    );

    if (result['success'] == true) {
      return result['srt'] as String? ?? result['result'] as String?;
    }
    return null;
  }

  Future<List<VideoTransition>> suggestTransitions({
    required VideoProject project,
  }) async {
    final result = await _bridge.suggestTransitions(projectJson: jsonEncode(project.toJson()));

    if (result['success'] != true) return [];

    final raw = result['transitions'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((t) => VideoTransition.fromJson(Map<String, dynamic>.from(t)))
          .toList();
    }

    // Some agent integrations return JSON-as-string.
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((t) => VideoTransition.fromJson(Map<String, dynamic>.from(t)))
            .toList();
      }
    }

    return [];
  }

  Future<MediaAsset?> generateClipFromPrompt({
    required String prompt,
  }) async {
    final result = await _bridge.generateClipFromPrompt(prompt: prompt);

    if (result['success'] != true) return null;

    final uri = result['uri'] as String? ?? result['videoUrl'] as String? ?? result['result'] as String?;
    if (uri == null || uri.isEmpty) return null;

    return MediaAsset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'AI Clip',
      type: MediaAssetType.video,
      uri: uri,
      durationMs: result['durationMs'] as int?,
    );
  }

  Future<MediaAsset?> enhanceVideo({
    required VideoClip clip,
    String? intent,
  }) async {
    final result = await _bridge.enhanceVideo(clipUri: clip.uri, intent: intent);

    if (result['success'] != true) return null;

    final uri = result['uri'] as String? ?? result['result'] as String?;
    if (uri == null || uri.isEmpty) return null;

    return MediaAsset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Enhanced ${clip.name}',
      type: clip.type,
      uri: uri,
      durationMs: result['durationMs'] as int?,
    );
  }
}

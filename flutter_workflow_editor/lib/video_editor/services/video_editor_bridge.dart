import 'package:flutter/services.dart';

/// MethodChannel bridge for the AI-native video editor.
///
/// The Kotlin host implements the heavy lifting (agent calls + FFmpeg export).
class VideoEditorBridge {
  static const MethodChannel _channel = MethodChannel('com.blurr.video_editor/bridge');

  Future<bool> checkProStatus() async {
    try {
      final result = await _channel.invokeMethod('checkProStatus');
      if (result is bool) return result;
      if (result is Map) {
        return (result['isPro'] as bool?) ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> executeAgentTask(String prompt) async {
    final result = await _channel.invokeMethod('executeAgentTask', {'prompt': prompt});
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> generateCaptions({
    required String clipUri,
    String? language,
  }) async {
    final result = await _channel.invokeMethod('generateCaptions', {
      'clipUri': clipUri,
      'language': language,
    });
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> suggestTransitions({
    required String projectJson,
  }) async {
    final result = await _channel.invokeMethod('suggestTransitions', {
      'projectJson': projectJson,
    });
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> generateClipFromPrompt({
    required String prompt,
  }) async {
    final result = await _channel.invokeMethod('generateClipFromPrompt', {
      'prompt': prompt,
    });
    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> enhanceVideo({
    required String clipUri,
    String? intent,
  }) async {
    final result = await _channel.invokeMethod('enhanceVideo', {
      'clipUri': clipUri,
      'intent': intent,
    });
    return Map<String, dynamic>.from(result as Map);
  }

  Future<int?> getMediaDurationMs({required String uri}) async {
    try {
      final result = await _channel.invokeMethod('getMediaDurationMs', {
        'uri': uri,
      });
      final map = Map<String, dynamic>.from(result as Map);
      final d = map['durationMs'];
      if (d is int) return d;
      if (d is num) return d.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> exportTimeline({
    required String timelineJson,
    String? outputFileName,
  }) async {
    final result = await _channel.invokeMethod('exportTimeline', {
      'timelineJson': timelineJson,
      'outputFileName': outputFileName,
    });
    return Map<String, dynamic>.from(result as Map);
  }
}

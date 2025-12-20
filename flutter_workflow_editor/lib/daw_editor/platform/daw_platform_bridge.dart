import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Platform bridge for DAW editor to communicate with native Android/iOS
class DawPlatformBridge {
  static const MethodChannel _channel = MethodChannel('com.twent.voice/daw_editor');

  /// Load a project from native
  static Future<Map<String, dynamic>?> loadProject(String? projectName, String? projectPath) async {
    try {
      final result = await _channel.invokeMethod('loadProject', {
        'project_name': projectName,
        'project_path': projectPath,
      });
      
      debugPrint('Loaded project: $projectName');
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      debugPrint('Error loading project: $e');
      return null;
    }
  }

 /// Save project to native storage
  static Future<String?> saveProject({required Map<String, dynamic> projectJson, String? projectPath}) async {
    try {
      final result = await _channel.invokeMethod('saveProject', {
        'project_json': jsonEncode(projectJson),
        'project_path': projectPath,
      });
      
      debugPrint('Project saved to: $result');
      return result as String?;
    } catch (e) {
      debugPrint('Error saving project: $e');
      return null;
    }
  }

  /// Export audio to native file system
  static Future<String?> exportAudio({
    required String format,
    required String quality,
    Map<String, dynamic>? projectJson,
    Map<String, dynamic>? trackJson,
    String? outputPath,
  }) async {
    try {
      final params = {
        'format': format,
        'quality': quality,
        'output_path': outputPath,
      };
      
      if (projectJson != null) {
        params['project_json'] = jsonEncode(projectJson);
      }
      
      if (trackJson != null) {
        params['track_json'] = jsonEncode(trackJson);
      }
      
      final result = await _channel.invokeMethod('exportAudio', params);
      
      debugPrint('Audio exported to: $result');
      return result as String?;
    } catch (e) {
      debugPrint('Error exporting audio: $e');
      return null;
    }
  }

 /// Request audio recording and storage permissions
 static Future<bool> requestAudioPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestAudioPermissions');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

 /// Import audio file using native file picker
 static Future<String?> importAudioFile() async {
    try {
      final result = await _channel.invokeMethod('importAudioFile');
      return result as String?;
    } catch (e) {
      debugPrint('Error importing audio: $e');
      return null;
    }
  }

  /// Call AI agent for audio generation
  static Future<Map<String, dynamic>?> callAiAgent({
    required String prompt,
    required String type,
  }) async {
    try {
      final result = await _channel.invokeMethod('callAiAgent', {
        'prompt': prompt,
        'type': type,
      });
      
      if (result != null) {
        final jsonResponse = jsonDecode(result as String);
        return Map<String, dynamic>.from(jsonResponse);
      }
      return null;
    } catch (e) {
      debugPrint('Error calling AI agent: $e');
      return null;
    }
  }

 /// Get native storage path
  static Future<String?> getStoragePath() async {
    try {
      final result = await _channel.invokeMethod('getStoragePath');
      return result as String?;
    } catch (e) {
      debugPrint('Error getting storage path: $e');
      return null;
    }
  }

 /// Share audio file using native share
  static Future<bool> shareAudioFile(String filePath) async {
    try {
      final result = await _channel.invokeMethod('shareAudioFile', {
        'file_path': filePath,
      });
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Error sharing file: $e');
      return false;
    }
  }

  /// Check if user has Pro subscription
 static Future<bool?> checkProAccess() async {
    try {
      final result = await _channel.invokeMethod('checkProAccess');
      return result as bool?;
    } catch (e) {
      debugPrint('Error checking Pro access: $e');
      return null;
    }
  }

  /// Setup method call handler for receiving calls from native
 static void setupMethodCallHandler(Future<dynamic> Function(MethodCall) handler) {
    _channel.setMethodCallHandler(handler);
  }
}

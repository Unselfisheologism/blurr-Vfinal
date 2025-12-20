import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/media_asset.dart';
import '../models/video_project.dart';

class VideoProjectStorageService {
  static const _currentProjectKey = 'video_editor.currentProject';
  static const _currentMediaBinKey = 'video_editor.currentMediaBin';

  Future<void> saveCurrent({
    required VideoProject project,
    required List<MediaAsset> mediaBin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentProjectKey, jsonEncode(project.toJson()));
    await prefs.setString(
      _currentMediaBinKey,
      jsonEncode(mediaBin.map((a) => a.toJson()).toList()),
    );
  }

  Future<({VideoProject project, List<MediaAsset> mediaBin})?> loadCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final projectJson = prefs.getString(_currentProjectKey);

    if (projectJson == null || projectJson.isEmpty) {
      return null;
    }

    final decodedProject = jsonDecode(projectJson);
    if (decodedProject is! Map) return null;

    final project = VideoProject.fromJson(Map<String, dynamic>.from(decodedProject));

    final mediaBinJson = prefs.getString(_currentMediaBinKey);
    List<MediaAsset> mediaBin = [];

    if (mediaBinJson != null && mediaBinJson.isNotEmpty) {
      final decodedMedia = jsonDecode(mediaBinJson);
      if (decodedMedia is List) {
        mediaBin = decodedMedia
            .whereType<Map>()
            .map((m) => MediaAsset.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
    }

    return (project: project, mediaBin: mediaBin);
  }

  Future<void> clearCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentProjectKey);
    await prefs.remove(_currentMediaBinKey);
  }
}

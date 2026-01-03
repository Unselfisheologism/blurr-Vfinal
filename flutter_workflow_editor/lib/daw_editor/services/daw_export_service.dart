import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/daw_project.dart';
import '../models/daw_track.dart';
import '../models/audio_clip.dart';
import '../platform/daw_platform_bridge.dart';

/// Export formats supported by the DAW
enum ExportFormat {
  wav,
  mp3,
  m4a,
}

/// Export quality settings
enum ExportQuality {
  low,
  medium,
  high,
  lossless,
}

/// Service for exporting and sharing DAW projects
class DawExportService {
  /// Export the project to an audio file
  Future<File?> exportProject(
    DawProject project, {
    ExportFormat format = ExportFormat.wav,
    ExportQuality quality = ExportQuality.high,
    String? customPath,
  }) async {
    try {
      debugPrint('Starting project export: ${project.name}');

      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        debugPrint('Storage permission denied');
        return null;
      }

      // Validate project has audio content
      if (!_hasAudioContent(project)) {
        debugPrint('Project has no audio content to export');
        return null;
      }

      // Determine output path
      final outputPath = customPath ?? await _getDefaultExportPath(project.name, format);

      // Call native export service via platform bridge
      final result = await DawPlatformBridge.exportAudio(
        format: format.name,
        quality: quality.name,
        projectJson: project.toJson(),
        outputPath: outputPath,
      );

      if (result != null) {
        final outputFile = File(result);
        if (await outputFile.exists()) {
          debugPrint('Export completed successfully: $result');
          return outputFile;
        }
      }

      debugPrint('Export failed: file not created');
      return null;
    } catch (e) {
      debugPrint('Error exporting project: $e');
      return null;
    }
  }

  /// Export a single track
  Future<File?> exportTrack(
    DawTrack track,
    String projectName, {
    ExportFormat format = ExportFormat.wav,
    ExportQuality quality = ExportQuality.high,
  }) async {
    try {
      debugPrint('Starting track export: ${track.name}');

      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        debugPrint('Storage permission denied');
        return null;
      }

      final fileName = '${projectName}_${track.name}';
      final outputPath = await _getDefaultExportPath(fileName, format);

      // Call native export service via platform bridge
      final result = await DawPlatformBridge.exportAudio(
        format: format.name,
        quality: quality.name,
        trackJson: track.toJson(),
        outputPath: outputPath,
      );

      if (result != null) {
        final outputFile = File(result);
        if (await outputFile.exists()) {
          debugPrint('Track export completed: $result');
          return outputFile;
        }
      }

      debugPrint('Track export failed');
      return null;
    } catch (e) {
      debugPrint('Error exporting track: $e');
      return null;
    }
  }

  /// Share an exported audio file
  Future<void> shareExportedFile(File file) async {
    try {
      debugPrint('Sharing file: ${file.path}');
      
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Exported from Blurr AI DAW',
        text: 'Check out this audio I created!',
      );

      if (result.status == ShareResultStatus.success) {
        debugPrint('File shared successfully');
      } else {
        debugPrint('Share cancelled or failed');
      }
    } catch (e) {
      debugPrint('Error sharing file: $e');
      rethrow;
    }
  }

  /// Save project as a DAW project file (.baw - Blurr Audio Workstation)
  Future<File?> saveProjectFile(DawProject project, {String? customPath}) async {
    try {
      debugPrint('Saving project file: ${project.name}');

      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        debugPrint('Storage permission denied');
        return null;
      }

      // Determine output path
      final outputPath = customPath ?? await _getDefaultProjectPath(project.name);

      // Call native save service via platform bridge
      final result = await DawPlatformBridge.saveProject(
        projectJson: project.toJson(),
        projectPath: outputPath,
      );

      if (result != null) {
        final outputFile = File(result);
        if (await outputFile.exists()) {
          debugPrint('Project saved to: $result');
          return outputFile;
        }
      }

      debugPrint('Project save failed');
      return null;
    } catch (e) {
      debugPrint('Error saving project file: $e');
      return null;
    }
  }

  /// Load project from a file
  Future<DawProject?> loadProjectFile(String filePath) async {
    try {
      debugPrint('Loading project file: $filePath');

      // Call native load service via platform bridge
      final result = await DawPlatformBridge.loadProject(null, null,
        projectName: null,
        projectPath: filePath,
      );

      if (result != null) {
        // Deserialize to project
        final project = DawProject.fromJson(result);
        debugPrint('Project loaded: ${project.name}');
        return project;
      }

      debugPrint('Project load failed');
      return null;
    } catch (e) {
      debugPrint('Error loading project file: $e');
      return null;
    }
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        // Android 13+ uses different permissions
        if (await _isAndroid13OrHigher()) {
          final status = await Permission.audio.request();
          return status.isGranted;
        } else {
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } else if (Platform.isiOS) {
        // iOS doesn't require storage permission for app documents
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check if Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    // This would need proper implementation using platform channels
    // For now, assume modern Android
    return true;
  }

  /// Get default export path
  Future<String> _getDefaultExportPath(String fileName, ExportFormat format) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/BlurrDAW/Exports');
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final extension = _getFileExtension(format);
    final sanitizedName = _sanitizeFileName(fileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return '${exportDir.path}/${sanitizedName}_$timestamp.$extension';
  }

  /// Get default project save path
  Future<String> _getDefaultProjectPath(String projectName) async {
    final directory = await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${directory.path}/BlurrDAW/Projects');
    
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }

    final sanitizedName = _sanitizeFileName(projectName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return '${projectsDir.path}/${sanitizedName}_$timestamp.baw';
  }

  /// Get file extension for format
  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.wav:
        return 'wav';
      case ExportFormat.mp3:
        return 'mp3';
      case ExportFormat.m4a:
        return 'm4a';
    }
  }

  /// Sanitize file name
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Check if project has audio content
  bool _hasAudioContent(DawProject project) {
    for (final track in project.tracks) {
      if (track.clips.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Get sample rate string for quality
  int _getSampleRateForQuality(ExportQuality quality) {
    switch (quality) {
      case ExportQuality.low:
        return 2050;
      case ExportQuality.medium:
        return 44100;
      case ExportQuality.high:
        return 48000;
      case ExportQuality.lossless:
        return 96000;
    }
  }

  /// Get bit rate for quality (for lossy formats)
  int _getBitRateForQuality(ExportQuality quality) {
    switch (quality) {
      case ExportQuality.low:
        return 128000; // 128 kbps
      case ExportQuality.medium:
        return 192000; // 192 kbps
      case ExportQuality.high:
        return 320000; // 320 kbps
      case ExportQuality.lossless:
        return 320000; // Max for MP3
    }
  }
}

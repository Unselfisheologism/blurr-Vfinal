import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../models/media_asset.dart';
import '../models/video_clip.dart';
import '../models/video_project.dart';
import '../models/video_track.dart';
import '../models/video_transition.dart';
import '../services/video_ai_service.dart';
import '../services/video_editor_bridge.dart';
import '../services/video_export_service.dart';
import '../services/video_project_storage_service.dart';

class VideoEditorState extends ChangeNotifier {
  VideoProject? _project;
  final List<MediaAsset> _mediaBin = [];

  bool _isLoading = false;
  bool _isExporting = false;
  String? _error;
  String? _lastExportPath;

  bool _isPro = false;

  double _pixelsPerSecond = 48.0;

  // History for undo/redo
  final List<VideoProject> _history = [];
  int _historyIndex = -1;
  static const int _maxHistorySize = 50;

  final VideoEditorBridge _bridge = VideoEditorBridge();
  final VideoAIService _aiService = VideoAIService();
  final VideoExportService _exportService = VideoExportService();
  final VideoProjectStorageService _storageService = VideoProjectStorageService();

  VideoProject? get project => _project;
  List<MediaAsset> get mediaBin => List.unmodifiable(_mediaBin);

  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get error => _error;
  String? get lastExportPath => _lastExportPath;

  bool get isPro => _isPro;
  double get pixelsPerSecond => _pixelsPerSecond;

  bool get hasProject => _project != null;

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex >= 0 && _historyIndex < _history.length - 1;

  int get maxTracks => _isPro ? 999 : 2;

  Future<void> initialize({String? projectName}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _isPro = await _bridge.checkProStatus();

      final saved = await _storageService.loadCurrent();
      if (saved != null) {
        _project = saved.project;
        _mediaBin
          ..clear()
          ..addAll(saved.mediaBin);
      }

      _project ??= VideoProject.empty(name: projectName ?? 'Untitled Video');
      _recordHistory();

      unawaited(_autoSave());
    } catch (e) {
      _error = 'Failed to initialize editor: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPixelsPerSecond(double value) {
    _pixelsPerSecond = value.clamp(16.0, 240.0);
    notifyListeners();
  }

  Future<void> importMediaFromDevice() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const [
          'mp4',
          'mov',
          'mkv',
          'webm',
          'mp3',
          'wav',
          'm4a',
          'aac',
          'ogg',
          'png',
          'jpg',
          'jpeg',
          'webp',
        ],
      );

      if (result == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;

        final type = _guessTypeFromPath(path);
        final durationMs = await _tryGetDurationMs(path, type);

        _mediaBin.add(
          MediaAsset(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: file.name,
            type: type,
            uri: path,
            durationMs: durationMs,
          ),
        );
      }

      unawaited(_autoSave());
    } catch (e) {
      _error = 'Failed to import media: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  MediaAssetType _guessTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp')) {
      return MediaAssetType.image;
    }
    if (lower.endsWith('.mp3') || lower.endsWith('.wav') || lower.endsWith('.m4a') || lower.endsWith('.aac') || lower.endsWith('.ogg')) {
      return MediaAssetType.audio;
    }
    return MediaAssetType.video;
  }

  Future<int?> _tryGetDurationMs(String path, MediaAssetType type) async {
    // Prefer native metadata (works for both audio and video).
    try {
      final nativeDuration = await _bridge.getMediaDurationMs(uri: path);
      if (nativeDuration != null && nativeDuration > 0) {
        return nativeDuration;
      }
    } catch (_) {
      // Best-effort; fall back below.
    }

    // Fallback for videos if native metadata isn't available.
    try {
      if (type == MediaAssetType.video) {
        final controller = VideoPlayerController.file(File(path));
        await controller.initialize();
        final d = controller.value.duration;
        await controller.dispose();
        if (d != Duration.zero) return d.inMilliseconds;
      }
    } catch (_) {
      // Non-fatal: duration probing is best-effort.
    }
    return null;
  }

  void addTrack(VideoTrackType type) {
    if (_project == null) return;

    if (_project!.tracks.length >= maxTracks) {
      _error = 'Track limit reached. ${_isPro ? '' : 'Upgrade to Pro for unlimited tracks.'}';
      notifyListeners();
      return;
    }

    final nextIndex = _project!.tracks.where((t) => t.type == type).length + 1;
    final newTrack = VideoTrack(
      id: '${type.name}_$nextIndex_${DateTime.now().millisecondsSinceEpoch}',
      name: '${type.name[0].toUpperCase()}${type.name.substring(1)} $nextIndex',
      type: type,
    );

    _updateProject(
      _project!.copyWith(
        tracks: [..._project!.tracks, newTrack],
        updatedAt: DateTime.now(),
      ),
    );
  }

  void addAssetToTimeline(MediaAsset asset, {String? trackId}) {
    if (_project == null) return;

    final targetTrackId = trackId ?? _defaultTrackIdForAsset(asset);
    final track = _project!.getTrack(targetTrackId);
    if (track == null) {
      _error = 'No compatible track found.';
      notifyListeners();
      return;
    }

    final clipId = DateTime.now().microsecondsSinceEpoch.toString();
    final durationMs = defaultTimelineDurationMsForAsset(asset);

    final clip = VideoClip(
      id: clipId,
      trackId: targetTrackId,
      assetId: asset.id,
      type: asset.type,
      name: asset.name,
      uri: asset.uri,
      startMs: _project!.playheadMs,
      durationMs: durationMs,
    );

    final updatedTrack = track.copyWith(clips: [...track.clips, clip]);

    _replaceTrack(updatedTrack);
    _updateProject(_project!.copyWith(selectedClipId: clipId, updatedAt: DateTime.now()));
  }

  String _defaultTrackIdForAsset(MediaAsset asset) {
    final tracks = _project!.tracks;

    VideoTrackType trackType;
    switch (asset.type) {
      case MediaAssetType.audio:
        trackType = VideoTrackType.audio;
        break;
      case MediaAssetType.image:
      case MediaAssetType.video:
        trackType = VideoTrackType.video;
        break;
    }

    final first = tracks.where((t) => t.type == trackType).firstOrNull;
    return first?.id ?? tracks.first.id;
  }

  void selectClip(String? clipId) {
    if (_project == null) return;
    _updateProject(_project!.copyWith(selectedClipId: clipId));
  }

  void setPlayheadMs(int value) {
    if (_project == null) return;
    _project = _project!.copyWith(playheadMs: value.clamp(0, 1000 * 60 * 60));
    notifyListeners();
  }

  void moveClip(String clipId, int deltaMs) {
    final project = _project;
    if (project == null) return;

    final clipEntry = _findClip(clipId);
    if (clipEntry == null) return;

    final (trackIndex, clipIndex, clip) = clipEntry;

    final nextStart = (clip.startMs + deltaMs).clamp(0, 1000 * 60 * 60);

    final updatedClip = clip.copyWith(startMs: nextStart);
    final updatedClips = [...project.tracks[trackIndex].clips];
    updatedClips[clipIndex] = updatedClip;

    final updatedTrack = project.tracks[trackIndex].copyWith(clips: updatedClips);
    _replaceTrack(updatedTrack);
    _updateProject(_project!.copyWith(updatedAt: DateTime.now()));
  }

  void trimClipStart(String clipId, int deltaMs) {
    final project = _project;
    if (project == null) return;

    final clipEntry = _findClip(clipId);
    if (clipEntry == null) return;

    final (trackIndex, clipIndex, clip) = clipEntry;

    final nextDuration = (clip.durationMs - deltaMs).clamp(250, 1000 * 60 * 60);
    final nextTrimStart = (clip.trimStartMs + deltaMs).clamp(0, 1000 * 60 * 60);

    final updatedClip = clip.copyWith(durationMs: nextDuration, trimStartMs: nextTrimStart);

    final updatedClips = [...project.tracks[trackIndex].clips];
    updatedClips[clipIndex] = updatedClip;

    final updatedTrack = project.tracks[trackIndex].copyWith(clips: updatedClips);
    _replaceTrack(updatedTrack);
    _updateProject(_project!.copyWith(updatedAt: DateTime.now()));
  }

  void trimClipEnd(String clipId, int deltaMs) {
    final project = _project;
    if (project == null) return;

    final clipEntry = _findClip(clipId);
    if (clipEntry == null) return;

    final (trackIndex, clipIndex, clip) = clipEntry;

    final nextDuration = (clip.durationMs + deltaMs).clamp(250, 1000 * 60 * 60);

    final updatedClip = clip.copyWith(durationMs: nextDuration);

    final updatedClips = [...project.tracks[trackIndex].clips];
    updatedClips[clipIndex] = updatedClip;

    final updatedTrack = project.tracks[trackIndex].copyWith(clips: updatedClips);
    _replaceTrack(updatedTrack);
    _updateProject(_project!.copyWith(updatedAt: DateTime.now()));
  }

  void deleteSelectedClip() {
    final project = _project;
    final selectedId = project?.selectedClipId;
    if (project == null || selectedId == null) return;

    final clipEntry = _findClip(selectedId);
    if (clipEntry == null) return;
    final (trackIndex, _, _) = clipEntry;

    final updatedClips = project.tracks[trackIndex].clips.where((c) => c.id != selectedId).toList();
    final updatedTrack = project.tracks[trackIndex].copyWith(clips: updatedClips);

    _replaceTrack(updatedTrack);
    _updateProject(_project!.copyWith(selectedClipId: null, updatedAt: DateTime.now()));
  }

  /// AI: Generate a new clip and add it to the media bin.
  Future<MediaAsset?> generateClipFromPrompt(String prompt) async {
    if (!_isPro) {
      _error = 'AI clip generation requires Pro subscription.';
      notifyListeners();
      return null;
    }

    try {
      final asset = await _aiService.generateClipFromPrompt(prompt: prompt);
      if (asset != null) {
        _mediaBin.insert(0, asset);
        notifyListeners();
        unawaited(_autoSave());
      }
      return asset;
    } catch (e) {
      _error = 'AI generation failed: $e';
      notifyListeners();
      return null;
    }
  }

  Future<String?> generateCaptionsForSelectedClip({String language = 'en'}) async {
    if (!_isPro) {
      _error = 'Auto-captions require Pro subscription.';
      notifyListeners();
      return null;
    }

    final clip = selectedClip;
    if (clip == null) return null;

    try {
      final srt = await _aiService.generateCaptionsSrt(clip: clip, language: language);
      if (srt == null) {
        _error = 'Failed to generate captions.';
        notifyListeners();
        return null;
      }

      final project = _project;
      if (project != null) {
        _updateProject(
          project.copyWith(
            captionsSrt: srt,
            updatedAt: DateTime.now(),
          ),
        );
      }

      return srt;
    } catch (e) {
      _error = 'Caption generation failed: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> suggestAndApplyTransitions() async {
    if (!_isPro) {
      _error = 'Smart transitions require Pro subscription.';
      notifyListeners();
      return;
    }

    final project = _project;
    if (project == null) return;

    try {
      final transitions = await _aiService.suggestTransitions(project: project);
      final filtered = transitions.where((t) => t.type != VideoTransitionType.none && t.durationMs > 0).toList();
      if (filtered.isEmpty) {
        _error = 'No transitions suggested.';
        notifyListeners();
        return;
      }

      _updateProject(project.copyWith(transitions: filtered, updatedAt: DateTime.now()));
    } catch (e) {
      _error = 'Transition suggestions failed: $e';
      notifyListeners();
    }
  }

  Future<MediaAsset?> enhanceSelectedClip({String? intent}) async {
    if (!_isPro) {
      _error = 'Enhance video requires Pro subscription.';
      notifyListeners();
      return null;
    }

    final clip = selectedClip;
    if (clip == null) return null;

    try {
      final enhanced = await _aiService.enhanceVideo(clip: clip, intent: intent);
      if (enhanced != null) {
        _mediaBin.insert(0, enhanced);
        notifyListeners();
      } else {
        _error = 'Failed to enhance clip.';
        notifyListeners();
      }
      return enhanced;
    } catch (e) {
      _error = 'Enhance failed: $e';
      notifyListeners();
      return null;
    }
  }

  void setBurnInCaptions(bool value) {
    final project = _project;
    if (project == null) return;
    _updateProject(project.copyWith(burnInCaptions: value, updatedAt: DateTime.now()));
  }

  Future<void> exportProject() async {
    final project = _project;
    if (project == null) return;

    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _exportService.exportProject(project);
      if (!result.success) {
        _error = result.error ?? 'Export failed.';
      } else {
        _lastExportPath = result.filePath;
      }
      _isExporting = false;
      notifyListeners();
    } catch (e) {
      _error = 'Export failed: $e';
      _isExporting = false;
      notifyListeners();
    }
  }

  VideoClip? get selectedClip {
    final project = _project;
    final selectedId = project?.selectedClipId;
    if (project == null || selectedId == null) return null;

    for (final t in project.tracks) {
      for (final c in t.clips) {
        if (c.id == selectedId) return c;
      }
    }
    return null;
  }

  /// Undo
  void undo() {
    if (!canUndo) return;
    _historyIndex--;
    _project = _history[_historyIndex];
    notifyListeners();
    unawaited(_autoSave());
  }

  /// Redo
  void redo() {
    if (!canRedo) return;
    _historyIndex++;
    _project = _history[_historyIndex];
    notifyListeners();
    unawaited(_autoSave());
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // -------- Internals

  void _replaceTrack(VideoTrack updatedTrack) {
    final project = _project;
    if (project == null) return;

    final updatedTracks = project.tracks.map((t) => t.id == updatedTrack.id ? updatedTrack : t).toList();
    _project = project.copyWith(tracks: updatedTracks);
  }

  (int trackIndex, int clipIndex, VideoClip clip)? _findClip(String clipId) {
    final project = _project;
    if (project == null) return null;

    for (var ti = 0; ti < project.tracks.length; ti++) {
      final track = project.tracks[ti];
      for (var ci = 0; ci < track.clips.length; ci++) {
        final clip = track.clips[ci];
        if (clip.id == clipId) return (ti, ci, clip);
      }
    }
    return null;
  }

  void _updateProject(VideoProject next) {
    _project = next;
    _recordHistory();
    notifyListeners();
    unawaited(_autoSave());
  }

  Future<void> _autoSave() async {
    final project = _project;
    if (project == null) return;
    try {
      await _storageService.saveCurrent(project: project, mediaBin: _mediaBin);
    } catch (_) {
      // Best-effort persistence.
    }
  }

  void _recordHistory() {
    final project = _project;
    if (project == null) return;

    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(project);
    _historyIndex = _history.length - 1;

    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}

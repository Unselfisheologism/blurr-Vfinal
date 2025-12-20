import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/video_track.dart';
import '../models/video_clip.dart';
import '../services/video_editor_service.dart';
import '../services/pro_gating_service.dart';

part 'timeline_provider.g.dart';

class TimelineNotifier extends StateNotifier<TimelineState> {
  final VideoEditorService _videoEditorService;
  final ProGatingService _proGatingService;

  TimelineNotifier(
    this._videoEditorService,
    this._proGatingService,
  ) : super(const TimelineState(tracks: []));

  Future<void> loadProject(String? projectName, String? projectPath) async {
    try {
      final projectData = await _videoEditorService.loadProject(projectName, projectPath);
      if (projectData != null) {
        state = state.copyWith(
          tracks: projectData.tracks,
          projectName: projectName,
          projectPath: projectPath,
        );
      }
    } catch (e) {
      // Initialize with default tracks if loading fails
      _initializeDefaultTracks();
    }
  }

  void _initializeDefaultTracks() {
    const maxFreeTracks = 2;
    final tracks = [
      VideoTrack(
        id: 'track_0',
        name: 'Video',
        type: TrackType.video,
        color: const Color(0xFFF57C00),
        maxClips: _proGatingService.isPro ? null : 10,
        clips: [],
      ),
      VideoTrack(
        id: 'track_1',
        name: 'Audio',
        type: TrackType.audio,
        color: const Color(0xFF4CAF50),
        maxClips: _proGatingService.isPro ? null : 10,
        clips: [],
      ),
    ];

    state = state.copyWith(tracks: tracks);
  }

  Future<void> addTrack(TrackType type, String name) async {
    if (!_proGatingService.canAddTrack(state.totalTracks)) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final track = VideoTrack(
      id: 'track_${state.totalTracks}',
      name: name,
      type: type,
      color: _getTrackColor(type),
      clips: [],
    );

    state = state.copyWith(tracks: [...state.tracks, track]);
  }

  Color _getTrackColor(TrackType type) {
    switch (type) {
      case TrackType.video:
        return const Color(0xFFF57C00);
      case TrackType.audio:
        return const Color(0xFF4CAF50);
      case TrackType.text:
        return const Color(0xFF2196F3);
      case TrackType.effect:
        return const Color(0xFF9C27B0);
      case TrackType.transition:
        return const Color(0xFFE91E63);
    }
  }

  Future<void> addClip(String trackId, VideoClip clip) async {
    final trackIndex = state.tracks.indexWhere((t) => t.id == trackId);
    if (trackIndex == -1) return;

    final track = state.tracks[trackIndex];
    
    if (!track.canAddClip) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final updatedClips = [...track.clips, clip];
    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = [...state.tracks];
    updatedTracks[trackIndex] = updatedTrack;

    state = state.copyWith(tracks: updatedTracks, selectedClip: clip);
  }

  Future<void> moveClip(String clipId, String fromTrackId, String toTrackId, double newStartTime) async {
    final fromIndex = state.tracks.indexWhere((t) => t.id == fromTrackId);
    final toIndex = state.tracks.indexWhere((t) => t.id == toTrackId);
    
    if (fromIndex == -1 || toIndex == -1) return;

    final fromTrack = state.tracks[fromIndex];
    final toTrack = state.tracks[toIndex];
    final clipIndex = fromTrack.clips.indexWhere((c) => c.id == clipId);
    
    if (clipIndex == -1) return;

    // Check target track capacity
    if (!toTrack.canAddClip) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final clip = fromTrack.clips[clipIndex];
    final movedClip = clip.copyWith(startTime: newStartTime);

    final updatedFromClips = [...fromTrack.clips];
    updatedFromClips.removeAt(clipIndex);

    final updatedToClips = [...toTrack.clips, movedClip];

    final updatedFromTrack = fromTrack.copyWith(clips: updatedFromClips);
    final updatedToTrack = toTrack.copyWith(clips: updatedToClips);

    final updatedTracks = [...state.tracks];
    updatedTracks[fromIndex] = updatedFromTrack;
    updatedTracks[toIndex] = updatedToTrack;

    state = state.copyWith(tracks: updatedTracks, selectedClip: movedClip);
  }

  Future<void> trimClip(String clipId, String trackId, double trimStart, double trimEnd) async {
    final trackIndex = state.tracks.indexWhere((t) => t.id == trackId);
    if (trackIndex == -1) return;

    final track = state.tracks[trackIndex];
    final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
    if (clipIndex == -1) return;

    final clip = track.clips[clipIndex];
    final trimmedClip = clip.copyWith(trimStart: trimStart, trimEnd: trimEnd);

    final updatedClips = [...track.clips];
    updatedClips[clipIndex] = trimmedClip;

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = [...state.tracks];
    updatedTracks[trackIndex] = updatedTrack;

    state = state.copyWith(tracks: updatedTracks, selectedClip: trimmedClip);
  }

  Future<void> deleteClip(String clipId, String trackId) async {
    final trackIndex = state.tracks.indexWhere((t) => t.id == trackId);
    if (trackIndex == -1) return;

    final track = state.tracks[trackIndex];
    final clipIndex = track.clips.indexWhere((c) => c.id == clipId);
    if (clipIndex == -1) return;

    final updatedClips = [...track.clips];
    updatedClips.removeAt(clipIndex);

    final updatedTrack = track.copyWith(clips: updatedClips);
    final updatedTracks = [...state.tracks];
    updatedTracks[trackIndex] = updatedTrack;

    state = state.copyWith(
      tracks: updatedTracks,
      selectedClip: null,
    );
  }

  Future<void> selectClip(String? clipId, String? trackId) async {
    VideoClip? selectedClip;
    VideoTrack? selectedTrack;

    if (clipId != null && trackId != null) {
      final track = state.tracks.firstWhere((t) => t.id == trackId);
      selectedClip = track.clips.firstWhere((c) => c.id == clipId);
      selectedTrack = track;
    }

    state = state.copyWith(
      selectedClip: selectedClip,
      selectedTrack: selectedTrack,
    );
  }

  void setCurrentTime(double time) {
    state = state.copyWith(currentTime: time);
  }

  void setZoomLevel(double zoomLevel) {
    state = state.copyWith(zoomLevel: zoomLevel);
  }

  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void stopPlayback() {
    state = state.copyWith(isPlaying: false, currentTime: 0.0);
  }

  Future<void> generateAiCaptions() async {
    if (!_proGatingService.canUseAiFeature('captions')) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final selectedClip = state.selectedClip;
    if (selectedClip == null || selectedClip.type != ClipType.video) return;

    state = state.copyWith(selectedClip: selectedClip.copyWith(
      status: VideoClipStatus.generating,
    ));

    try {
      final result = await _videoEditorService.generateCaptions(selectedClip.id);
      // Update clip with captions data
      if (result['captions'] != null) {
        final updatedClip = selectedClip.copyWith(
          metadata: {
            ...?selectedClip.metadata,
            'captions': result['captions'],
          },
          status: VideoClipStatus.normal,
        );
        
        // Update clip in timeline
        await _updateClipInTimeline(updatedClip);
      }
    } catch (e) {
      state = state.copyWith(selectedClip: selectedClip.copyWith(
        status: VideoClipStatus.error,
      ));
    }
  }

  Future<void> applyAiTransition() async {
    if (!_proGatingService.canUseAiFeature('transitions')) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final selectedClip = state.selectedClip;
    if (selectedClip == null) return;

    final result = await _videoEditorService.suggestTransitions(selectedClip.id);
    // Apply transition based on AI suggestion
    if (result['transition'] != null) {
      await addTransitionClip(
        clipId: selectedClip.id,
        transitionType: result['transition'],
      );
    }
  }

  Future<void> addTransitionClip({
    required String clipId,
    required String transitionType,
  }) async {
    // Implementation for adding transition clips
  }

  Future<void> generateAiVideo(String prompt) async {
    if (!_proGatingService.canUseAiFeature('video_generation')) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final clip = VideoClip(
      id: 'ai_clip_${DateTime.now().millisecondsSinceEpoch}',
      name: 'AI Generated',
      filePath: '',
      type: ClipType.video,
      startTime: state.currentTime,
      duration: 5.0,
      color: Colors.blue,
      status: VideoClipStatus.generating,
      aiPrompt: prompt,
    );

    await addClip(state.selectedTrack?.id ?? state.tracks.first.id, clip);

    try {
      final result = await _videoEditorService.generateVideo(prompt);
      final generatedClip = clip.copyWith(
        filePath: result['video_path'],
        duration: result['duration'],
        status: VideoClipStatus.normal,
      );

      await _updateClipInTimeline(generatedClip);
    } catch (e) {
      await deleteClip(clip.id, state.selectedTrack?.id ?? state.tracks.first.id);
    }
  }

  Future<void> enhanceVideo() async {
    if (!_proGatingService.canUseAiFeature('enhancement')) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final selectedClip = state.selectedClip;
    if (selectedClip == null || selectedClip.type != ClipType.video) return;

    state = state.copyWith(selectedClip: selectedClip.copyWith(
      status: VideoClipStatus.processing,
    ));

    try {
      final result = await _videoEditorService.enhanceVideo(selectedClip.id);
      final enhancedClip = selectedClip.copyWith(
        metadata: {
          ...?selectedClip.metadata,
          'enhanced': true,
          'enhancement_settings': result['settings'],
        },
        status: VideoClipStatus.normal,
      );

      await _updateClipInTimeline(enhancedClip);
    } catch (e) {
      state = state.copyWith(selectedClip: selectedClip.copyWith(
        status: VideoClipStatus.error,
      ));
    }
  }

  Future<void> _updateClipInTimeline(VideoClip updatedClip) async {
    for (int i = 0; i < state.tracks.length; i++) {
      final track = state.tracks[i];
      final clipIndex = track.clips.indexWhere((c) => c.id == updatedClip.id);
      
      if (clipIndex != -1) {
        final updatedClips = [...track.clips];
        updatedClips[clipIndex] = updatedClip;

        final updatedTrack = track.copyWith(clips: updatedClips);
        final updatedTracks = [...state.tracks];
        updatedTracks[i] = updatedTrack;

        state = state.copyWith(
          tracks: updatedTracks,
          selectedClip: updatedClip,
        );
        break;
      }
    }
  }

  Future<void> exportVideo({required ExportSettings settings}) async {
    if (!_proGatingService.canExportVideo(settings.quality)) {
      _proGatingService.showProUpgradeDialog();
      return;
    }

    final exportProgress = await _videoEditorService.exportVideo(
      tracks: state.tracks,
      settings: settings,
    );

    // Handle export progress updates
    exportProgress.listen((progress) {
      // Update UI with progress
    });
  }

  Future<void> saveProject() async {
    await _videoEditorService.saveProject(
      projectName: state.projectName ?? 'untitled',
      projectPath: state.projectPath,
      tracks: state.tracks,
    );
  }

  void undo() {
    // Implementation for undo/redo stack
  }

  void redo() {
    // Implementation for undo/redo stack
  }
}

@riverpod
TimelineNotifier timelineNotifier(TimelineNotifierRef ref) {
  return TimelineNotifier(
    ref.watch(videoEditorServiceProvider),
    ref.watch(proGatingServiceProvider),
  );
}

@riverpod
TimelineState timelineState(TimelineStateRef ref) {
  return ref.watch(timelineNotifierProvider);
}

class ExportSettings {
  final String format;
  final String quality;
  final int? resolution;
  final double? frameRate;
  final String outputPath;

  ExportSettings({
    required this.format,
    required this.quality,
    this.resolution,
    this.frameRate,
    required this.outputPath,
  });
}
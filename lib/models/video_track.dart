import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'video_clip.dart';

enum TrackType {
  video,
  audio,
  text,
  effect,
  transition,
}

class VideoTrack {
  final String id;
  final String name;
  final TrackType type;
  final Color color;
  final bool isLocked;
  final bool isMuted;
  final bool isVisible;
  final int? maxClips; // For pro gating
  final List<VideoClip> clips;

  VideoTrack({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.isLocked = false,
    this.isMuted = false,
    this.isVisible = true,
    this.maxClips,
    required this.clips,
  });

  VideoTrack copyWith({
    String? id,
    String? name,
    TrackType? type,
    Color? color,
    bool? isLocked,
    bool? isMuted,
    bool? isVisible,
    int? maxClips,
    List<VideoClip>? clips,
  }) {
    return VideoTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      isLocked: isLocked ?? this.isLocked,
      isMuted: isMuted ?? this.isMuted,
      isVisible: isVisible ?? this.isVisible,
      maxClips: maxClips ?? this.maxClips,
      clips: clips ?? this.clips,
    );
  }

  double get totalDuration {
    if (clips.isEmpty) return 0.0;
    return clips.map((clip) => clip.endTime).reduce(math.max);
  }

  int get clipCount => clips.length;
  bool get canAddClip => maxClips == null || clipCount < maxClips!;
}

class TimelineState {
  final List<VideoTrack> tracks;
  final double currentTime;
  final double zoomLevel;
  final bool isPlaying;
  final Duration? duration;
  final String? projectName;
  final String? projectPath;
  final VideoClip? selectedClip;
  final VideoTrack? selectedTrack;

  const TimelineState({
    required this.tracks,
    this.currentTime = 0.0,
    this.zoomLevel = 1.0,
    this.isPlaying = false,
    this.duration,
    this.projectName,
    this.projectPath,
    this.selectedClip,
    this.selectedTrack,
  });

  TimelineState copyWith({
    List<VideoTrack>? tracks,
    double? currentTime,
    double? zoomLevel,
    bool? isPlaying,
    Duration? duration,
    String? projectName,
    String? projectPath,
    VideoClip? selectedClip,
    VideoTrack? selectedTrack,
  }) {
    return TimelineState(
      tracks: tracks ?? this.tracks,
      currentTime: currentTime ?? this.currentTime,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      projectName: projectName ?? this.projectName,
      projectPath: projectPath ?? this.projectPath,
      selectedClip: selectedClip ?? this.selectedClip,
      selectedTrack: selectedTrack ?? this.selectedTrack,
    );
  }

  double get projectDuration {
    if (duration != null) return duration!.inMilliseconds / 1000.0;
    if (tracks.isEmpty) return 0.0;
    
    double maxDuration = 0.0;
    for (final track in tracks) {
      if (track.clips.isNotEmpty) {
        final trackMax = track.clips.map((clip) => clip.endTime).reduce(math.max);
        if (trackMax > maxDuration) maxDuration = trackMax;
      }
    }
    
    return maxDuration;
  }

  VideoClip? getClipAt(double time, String trackId) {
    final track = tracks.firstWhere(
      (t) => t.id == trackId && !t.isMuted,
    );
    
    return track.clips.firstWhere(
      (clip) => time >= clip.startTime && time < clip.endTime,
    );
  }

  List<VideoClip> get allClips {
    final clips = <VideoClip>[];
    for (final track in tracks) {
      clips.addAll(track.clips);
    }
    return clips;
  }

  int get totalTracks => tracks.length;
  int get totalClips => allClips.length;
}
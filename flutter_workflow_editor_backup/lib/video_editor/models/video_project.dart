import 'media_asset.dart';
import 'video_track.dart';
import 'video_transition.dart';

class VideoProject {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VideoTrack> tracks;
  final List<VideoTransition> transitions;

  /// Optional SRT captions to be exported alongside the video.
  ///
  /// For now this is a single sidecar (project-level) caption track.
  final String? captionsSrt;

  /// Whether to burn captions into the exported MP4.
  /// When false, captions are exported as a separate .srt file.
  final bool burnInCaptions;

  final String? selectedClipId;
  final int playheadMs;

  const VideoProject({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.tracks,
    this.transitions = const [],
    this.captionsSrt,
    this.burnInCaptions = false,
    this.selectedClipId,
    this.playheadMs = 0,
  });

  factory VideoProject.empty({required String name}) {
    final now = DateTime.now();
    return VideoProject(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      updatedAt: now,
      tracks: const [
        VideoTrack(
          id: 'v1',
          name: 'Video 1',
          type: VideoTrackType.video,
        ),
        VideoTrack(
          id: 'a1',
          name: 'Audio 1',
          type: VideoTrackType.audio,
        ),
      ],
    );
  }

  VideoProject copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<VideoTrack>? tracks,
    List<VideoTransition>? transitions,
    String? captionsSrt,
    bool? burnInCaptions,
    String? selectedClipId,
    int? playheadMs,
  }) {
    return VideoProject(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tracks: tracks ?? this.tracks,
      transitions: transitions ?? this.transitions,
      captionsSrt: captionsSrt ?? this.captionsSrt,
      burnInCaptions: burnInCaptions ?? this.burnInCaptions,
      selectedClipId: selectedClipId ?? this.selectedClipId,
      playheadMs: playheadMs ?? this.playheadMs,
    );
  }

  VideoTrack? getTrack(String trackId) {
    for (final t in tracks) {
      if (t.id == trackId) return t;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'transitions': transitions.map((t) => t.toJson()).toList(),
      'captionsSrt': captionsSrt,
      'burnInCaptions': burnInCaptions,
      'selectedClipId': selectedClipId,
      'playheadMs': playheadMs,
    };
  }

  factory VideoProject.fromJson(Map<String, dynamic> json) {
    return VideoProject(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tracks: (json['tracks'] as List<dynamic>? ?? [])
          .map((t) => VideoTrack.fromJson(Map<String, dynamic>.from(t as Map)))
          .toList(),
      transitions: (json['transitions'] as List<dynamic>? ?? [])
          .map((t) => VideoTransition.fromJson(Map<String, dynamic>.from(t as Map)))
          .toList(),
      captionsSrt: json['captionsSrt'] as String?,
      burnInCaptions: json['burnInCaptions'] as bool? ?? false,
      selectedClipId: json['selectedClipId'] as String?,
      playheadMs: json['playheadMs'] as int? ?? 0,
    );
  }
}

/// Defaults for new clips placed on the timeline.
int defaultTimelineDurationMsForAsset(MediaAsset asset) {
  if (asset.durationMs != null) return asset.durationMs!;
  return switch (asset.type) {
    MediaAssetType.image => 5000,
    MediaAssetType.audio => 10 * 1000,
    MediaAssetType.video => 10 * 1000,
  };
}

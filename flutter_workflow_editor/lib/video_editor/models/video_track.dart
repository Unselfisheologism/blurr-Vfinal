import 'video_clip.dart';

enum VideoTrackType {
  video,
  audio,
  captions,
}

VideoTrackType videoTrackTypeFromString(String value) {
  switch (value) {
    case 'video':
      return VideoTrackType.video;
    case 'audio':
      return VideoTrackType.audio;
    case 'captions':
      return VideoTrackType.captions;
  }
  throw ArgumentError('Unknown VideoTrackType: $value');
}

String videoTrackTypeToString(VideoTrackType type) {
  return switch (type) {
    VideoTrackType.video => 'video',
    VideoTrackType.audio => 'audio',
    VideoTrackType.captions => 'captions',
  };
}

class VideoTrack {
  final String id;
  final String name;
  final VideoTrackType type;
  final List<VideoClip> clips;

  const VideoTrack({
    required this.id,
    required this.name,
    required this.type,
    this.clips = const [],
  });

  VideoTrack copyWith({
    String? id,
    String? name,
    VideoTrackType? type,
    List<VideoClip>? clips,
  }) {
    return VideoTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      clips: clips ?? this.clips,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': videoTrackTypeToString(type),
      'clips': clips.map((c) => c.toJson()).toList(),
    };
  }

  factory VideoTrack.fromJson(Map<String, dynamic> json) {
    return VideoTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      type: videoTrackTypeFromString(json['type'] as String),
      clips: (json['clips'] as List<dynamic>? ?? [])
          .map((c) => VideoClip.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
    );
  }
}

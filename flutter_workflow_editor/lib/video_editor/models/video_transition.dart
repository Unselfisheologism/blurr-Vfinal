enum VideoTransitionType {
  none,
  crossfade,
  fadeToBlack,
}

VideoTransitionType videoTransitionTypeFromString(String value) {
  switch (value) {
    case 'none':
      return VideoTransitionType.none;
    case 'crossfade':
      return VideoTransitionType.crossfade;
    case 'fadeToBlack':
      return VideoTransitionType.fadeToBlack;
  }
  throw ArgumentError('Unknown VideoTransitionType: $value');
}

String videoTransitionTypeToString(VideoTransitionType type) {
  return switch (type) {
    VideoTransitionType.none => 'none',
    VideoTransitionType.crossfade => 'crossfade',
    VideoTransitionType.fadeToBlack => 'fadeToBlack',
  };
}

class VideoTransition {
  final String id;
  final String fromClipId;
  final String toClipId;
  final VideoTransitionType type;
  final int durationMs;

  const VideoTransition({
    required this.id,
    required this.fromClipId,
    required this.toClipId,
    required this.type,
    required this.durationMs,
  });

  VideoTransition copyWith({
    String? id,
    String? fromClipId,
    String? toClipId,
    VideoTransitionType? type,
    int? durationMs,
  }) {
    return VideoTransition(
      id: id ?? this.id,
      fromClipId: fromClipId ?? this.fromClipId,
      toClipId: toClipId ?? this.toClipId,
      type: type ?? this.type,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromClipId': fromClipId,
      'toClipId': toClipId,
      'type': videoTransitionTypeToString(type),
      'durationMs': durationMs,
    };
  }

  factory VideoTransition.fromJson(Map<String, dynamic> json) {
    return VideoTransition(
      id: json['id'] as String,
      fromClipId: json['fromClipId'] as String,
      toClipId: json['toClipId'] as String,
      type: videoTransitionTypeFromString(json['type'] as String),
      durationMs: json['durationMs'] as int,
    );
  }
}

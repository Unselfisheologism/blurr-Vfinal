import 'media_asset.dart';

/// A single placed instance on the timeline.
class VideoClip {
  final String id;
  final String trackId;

  /// Reference into the media bin.
  final String assetId;
  final MediaAssetType type;

  /// Convenience display name.
  final String name;

  /// Local file path (Android) or network URL.
  final String uri;

  /// Timeline position in milliseconds.
  final int startMs;

  /// Timeline duration in milliseconds.
  final int durationMs;

  /// Source trim (milliseconds into the source).
  final int trimStartMs;

  const VideoClip({
    required this.id,
    required this.trackId,
    required this.assetId,
    required this.type,
    required this.name,
    required this.uri,
    required this.startMs,
    required this.durationMs,
    this.trimStartMs = 0,
  });

  int get endMs => startMs + durationMs;

  bool get isNetwork => uri.startsWith('http://') || uri.startsWith('https://');

  VideoClip copyWith({
    String? id,
    String? trackId,
    String? assetId,
    MediaAssetType? type,
    String? name,
    String? uri,
    int? startMs,
    int? durationMs,
    int? trimStartMs,
  }) {
    return VideoClip(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      assetId: assetId ?? this.assetId,
      type: type ?? this.type,
      name: name ?? this.name,
      uri: uri ?? this.uri,
      startMs: startMs ?? this.startMs,
      durationMs: durationMs ?? this.durationMs,
      trimStartMs: trimStartMs ?? this.trimStartMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackId': trackId,
      'assetId': assetId,
      'type': mediaAssetTypeToString(type),
      'name': name,
      'uri': uri,
      'startMs': startMs,
      'durationMs': durationMs,
      'trimStartMs': trimStartMs,
    };
  }

  factory VideoClip.fromJson(Map<String, dynamic> json) {
    return VideoClip(
      id: json['id'] as String,
      trackId: json['trackId'] as String,
      assetId: json['assetId'] as String,
      type: mediaAssetTypeFromString(json['type'] as String),
      name: json['name'] as String,
      uri: json['uri'] as String,
      startMs: json['startMs'] as int,
      durationMs: json['durationMs'] as int,
      trimStartMs: json['trimStartMs'] as int? ?? 0,
    );
  }
}

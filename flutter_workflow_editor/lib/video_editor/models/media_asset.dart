/// Media asset imported into the video editor media bin.
///
/// This is distinct from [VideoClip] which represents a placed instance on the timeline.

enum MediaAssetType {
  video,
  image,
  audio,
}

MediaAssetType mediaAssetTypeFromString(String value) {
  switch (value) {
    case 'video':
      return MediaAssetType.video;
    case 'image':
      return MediaAssetType.image;
    case 'audio':
      return MediaAssetType.audio;
  }
  throw ArgumentError('Unknown MediaAssetType: $value');
}

String mediaAssetTypeToString(MediaAssetType type) {
  return switch (type) {
    MediaAssetType.video => 'video',
    MediaAssetType.image => 'image',
    MediaAssetType.audio => 'audio',
  };
}

class MediaAsset {
  final String id;
  final String name;
  final MediaAssetType type;

  /// Local file path (Android) or network URL.
  final String uri;

  /// Duration in milliseconds if known.
  final int? durationMs;

  /// If imported from Google Drive, this is the original file ID.
  final String? googleDriveId;

  /// If imported from Google Drive, this links back to the original file.
  final String? googleDriveUrl;

  const MediaAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.uri,
    this.durationMs,
    this.googleDriveId,
    this.googleDriveUrl,
  });

  bool get isNetwork => uri.startsWith('http://') || uri.startsWith('https://');

  MediaAsset copyWith({
    String? id,
    String? name,
    MediaAssetType? type,
    String? uri,
    int? durationMs,
    String? googleDriveId,
    String? googleDriveUrl,
  }) {
    return MediaAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      uri: uri ?? this.uri,
      durationMs: durationMs ?? this.durationMs,
      googleDriveId: googleDriveId ?? this.googleDriveId,
      googleDriveUrl: googleDriveUrl ?? this.googleDriveUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': mediaAssetTypeToString(type),
      'uri': uri,
      'durationMs': durationMs,
      'googleDriveId': googleDriveId,
      'googleDriveUrl': googleDriveUrl,
    };
  }

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
      id: json['id'] as String,
      name: json['name'] as String,
      type: mediaAssetTypeFromString(json['type'] as String),
      uri: json['uri'] as String,
      durationMs: json['durationMs'] as int?,
      googleDriveId: json['googleDriveId'] as String?,
      googleDriveUrl: json['googleDriveUrl'] as String?,
    );
  }
}

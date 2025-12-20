import 'dart:ui';

enum ClipType {
  video,
  audio,
  image,
  text,
  transition,
}

enum VideoClipStatus {
  normal,
  generating,
  processing,
  error,
}

class VideoClip {
  final String id;
  final String? name;
  final String filePath;
  final ClipType type;
  final double startTime;
  final double duration;
  final double trimStart;
  final double trimEnd;
  final Color color;
  final VideoClipStatus status;
  final String? aiPrompt;
  final Map<String, dynamic>? metadata;
  final String? thumbnailPath;

  VideoClip({
    required this.id,
    this.name,
    required this.filePath,
    required this.type,
    required this.startTime,
    required this.duration,
    this.trimStart = 0.0,
    this.trimEnd = 1.0,
    required this.color,
    this.status = VideoClipStatus.normal,
    this.aiPrompt,
    this.metadata,
    this.thumbnailPath,
  });

  VideoClip copyWith({
    String? id,
    String? name,
    String? filePath,
    ClipType? type,
    double? startTime,
    double? duration,
    double? trimStart,
    double? trimEnd,
    Color? color,
    VideoClipStatus? status,
    String? aiPrompt,
    Map<String, dynamic>? metadata,
    String? thumbnailPath,
  }) {
    return VideoClip(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      color: color ?? this.color,
      status: status ?? this.status,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      metadata: metadata ?? this.metadata,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  double get trimmedDuration => duration * (trimEnd - trimStart);
  double get endTime => startTime + trimmedDuration;
}

class TextClip extends VideoClip {
  final String text;
  final double fontSize;
  final Color textColor;
  final String? fontFamily;
  final double? positionX;
  final double? positionY;
  final TextAlign? textAlign;
  final String? animationPreset;

  TextClip({
    required super.id,
    required this.text,
    required super.filePath,
    super.name,
    super.startTime,
    super.duration,
    this.fontSize = 24.0,
    this.textColor = const Color(0xFFFFFFFF),
    this.fontFamily,
    this.positionX,
    this.positionY,
    this.textAlign,
    this.animationPreset,
    super.color = const Color(0xFF2196F3),
  }) : super(type: ClipType.text);
}

class TransitionClip extends VideoClip {
  final String transitionType;
  final double intensity;

  TransitionClip({
    required super.id,
    required this.transitionType,
    required super.filePath,
    super.name,
    super.startTime,
    super.duration,
    this.intensity = 0.5,
    super.color = const Color(0xFF9C27B0),
  }) : super(type: ClipType.transition);
}
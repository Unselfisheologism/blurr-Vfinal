import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'audio_clip.g.dart';

/// Represents an audio clip placed on a track in the DAW timeline
@JsonSerializable()
class AudioClip {
  /// Unique identifier for this clip
  final String id;

  /// Name/label for the clip
  final String name;

  /// File path or URL to the audio source
  final String? audioPath;

  /// Start position on the timeline (in milliseconds)
  final double startTime;

  /// Duration of the clip (in milliseconds)
  final double duration;

  /// Offset into the original audio file (for trimming, in milliseconds)
  final double offset;

  /// Volume level (0.0 to 1.0)
  final double volume;

  /// Whether the clip is muted
  final bool isMuted;

  /// Color for visual representation
  final int color;

  /// Waveform data (normalized amplitude values)
  final List<double>? waveformData;

  /// Whether this clip was AI-generated
  final bool isAiGenerated;

  /// AI generation prompt (if applicable)
  final String? aiPrompt;

  /// Metadata for the clip
  final Map<String, dynamic>? metadata;

  AudioClip({
    String? id,
    required this.name,
    this.audioPath,
    required this.startTime,
    required this.duration,
    this.offset = 0.0,
    this.volume = 1.0,
    this.isMuted = false,
    this.color = 0xFF4CAF50,
    this.waveformData,
    this.isAiGenerated = false,
    this.aiPrompt,
    this.metadata,
  }) : id = id ?? const Uuid().v4();

  /// Create a copy with modified fields
  AudioClip copyWith({
    String? name,
    String? audioPath,
    double? startTime,
    double? duration,
    double? offset,
    double? volume,
    bool? isMuted,
    int? color,
    List<double>? waveformData,
    bool? isAiGenerated,
    String? aiPrompt,
    Map<String, dynamic>? metadata,
  }) {
    return AudioClip(
      id: id,
      name: name ?? this.name,
      audioPath: audioPath ?? this.audioPath,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      offset: offset ?? this.offset,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      color: color ?? this.color,
      waveformData: waveformData ?? this.waveformData,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get the end time of the clip on the timeline
  double get endTime => startTime + duration;

  factory AudioClip.fromJson(Map<String, dynamic> json) =>
      _$AudioClipFromJson(json);

  Map<String, dynamic> toJson() => _$AudioClipToJson(this);
}

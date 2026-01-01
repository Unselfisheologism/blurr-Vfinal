import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'audio_clip.dart';

part 'daw_track.g.dart';

/// Effect types available for tracks
enum EffectType {
  reverb,
  pitchShift,
  lowPass,
  highPass,
  bandPass,
  echo,
  compressor,
  limiter,
}

/// Represents an audio effect applied to a track
@JsonSerializable()
class TrackEffect {
  final String id;
  final EffectType type;
  final bool enabled;
  final Map<String, double> parameters;

  TrackEffect({
    String? id,
    required this.type,
    this.enabled = true,
    Map<String, double>? parameters,
  })  : id = id ?? const Uuid().v4(),
        parameters = parameters ?? {};

  TrackEffect copyWith({
    EffectType? type,
    bool? enabled,
    Map<String, double>? parameters,
  }) {
    return TrackEffect(
      id: id,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      parameters: parameters ?? this.parameters,
    );
  }

  factory TrackEffect.fromJson(Map<String, dynamic> json) =>
      _$TrackEffectFromJson(json);

  Map<String, dynamic> toJson() => _$TrackEffectToJson(this);
}

/// Represents a track in the DAW with audio clips and effects
@JsonSerializable()
class DawTrack {
  /// Unique identifier for this track
  final String id;

  /// Track name
  final String name;

  /// Track color for visual representation
  final int color;

  /// Volume level (0.0 to 1.0)
  final double volume;

  /// Pan position (-1.0 left to 1.0 right, 0.0 center)
  final double pan;

  /// Whether the track is muted
  final bool isMuted;

  /// Whether the track is soloed
  final bool isSolo;

  /// Whether the track is armed for recording
  final bool isArmed;

  /// Height of the track in the UI (in pixels)
  final double height;

  /// Audio clips on this track
  final List<AudioClip> clips;

  /// Effects chain for this track
  final List<TrackEffect> effects;

  /// Track type (audio, midi, etc.)
  final String trackType;

  /// Whether this is a locked track (pro feature)
  final bool isLocked;

  DawTrack({
    String? id,
    required this.name,
    this.color = 0xFF2196F3,
    this.volume = 0.8,
    this.pan = 0.0,
    this.isMuted = false,
    this.isSolo = false,
    this.isArmed = false,
    this.height = 100.0,
    List<AudioClip>? clips,
    List<TrackEffect>? effects,
    this.trackType = 'audio',
    this.isLocked = false,
  })  : id = id ?? const Uuid().v4(),
        clips = clips ?? [],
        effects = effects ?? [];

  /// Create a copy with modified fields
  DawTrack copyWith({
    String? name,
    int? color,
    double? volume,
    double? pan,
    bool? isMuted,
    bool? isSolo,
    bool? isArmed,
    double? height,
    List<AudioClip>? clips,
    List<TrackEffect>? effects,
    String? trackType,
    bool? isLocked,
  }) {
    return DawTrack(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      volume: volume ?? this.volume,
      pan: pan ?? this.pan,
      isMuted: isMuted ?? this.isMuted,
      isSolo: isSolo ?? this.isSolo,
      isArmed: isArmed ?? this.isArmed,
      height: height ?? this.height,
      clips: clips ?? this.clips,
      effects: effects ?? this.effects,
      trackType: trackType ?? this.trackType,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  /// Add a clip to the track
  DawTrack addClip(AudioClip clip) {
    return copyWith(clips: [...clips, clip]);
  }

  /// Remove a clip from the track
  DawTrack removeClip(String clipId) {
    return copyWith(clips: clips.where((c) => c.id != clipId).toList());
  }

  /// Update a clip on the track
  DawTrack updateClip(AudioClip updatedClip) {
    final updatedClips = clips.map((c) {
      return c.id == updatedClip.id ? updatedClip : c;
    }).toList();
    return copyWith(clips: updatedClips);
  }

  /// Add an effect to the track
  DawTrack addEffect(TrackEffect effect) {
    return copyWith(effects: [...effects, effect]);
  }

  /// Remove an effect from the track
  DawTrack removeEffect(String effectId) {
    return copyWith(effects: effects.where((e) => e.id != effectId).toList());
  }

  /// Update an effect on the track
  DawTrack updateEffect(TrackEffect updatedEffect) {
    final updatedEffects = effects.map((e) {
      return e.id == updatedEffect.id ? updatedEffect : e;
    }).toList();
    return copyWith(effects: updatedEffects);
  }

  factory DawTrack.fromJson(Map<String, dynamic> json) =>
      _$DawTrackFromJson(json);

  Map<String, dynamic> toJson() => _$DawTrackToJson(this);
}

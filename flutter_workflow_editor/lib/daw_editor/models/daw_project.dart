import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'daw_track.dart';

part 'daw_project.g.dart';

/// Represents the state of undo/redo operations
class ProjectHistory {
  final List<DawProject> undoStack;
  final List<DawProject> redoStack;
  final int maxHistorySize;

  ProjectHistory({
    List<DawProject>? undoStack,
    List<DawProject>? redoStack,
    this.maxHistorySize = 50,
  })  : undoStack = undoStack ?? [],
        redoStack = redoStack ?? [];

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
}

/// Represents a complete DAW project with all tracks and settings
@JsonSerializable()
class DawProject {
  /// Unique identifier for this project
  final String id;

  /// Project name
  final String name;

  /// Tempo in BPM
  final double tempo;

  /// Time signature numerator
  final int timeSignatureNumerator;

  /// Time signature denominator
  final int timeSignatureDenominator;

  /// Sample rate (44100, 48000, etc.)
  final int sampleRate;

  /// All tracks in the project
  final List<DawTrack> tracks;

  /// Master volume (0.0 to 1.0)
  final double masterVolume;

  /// Project duration in milliseconds (calculated from tracks)
  final double duration;

  /// Zoom level for timeline (pixels per second)
  final double zoomLevel;

  /// Scroll position in the timeline
  final double scrollPosition;

  /// Whether the project is currently playing
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isPlaying;

  /// Current playback position (in milliseconds)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double playbackPosition;

  /// Whether the project has unsaved changes
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool hasUnsavedChanges;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last modified timestamp
  final DateTime modifiedAt;

  /// Project file path (if saved)
  final String? filePath;

  /// Free tier track limit
  static const int freeTrackLimit = 4;

  DawProject({
    String? id,
    required this.name,
    this.tempo = 120.0,
    this.timeSignatureNumerator = 4,
    this.timeSignatureDenominator = 4,
    this.sampleRate = 44100,
    List<DawTrack>? tracks,
    this.masterVolume = 0.8,
    this.duration = 0.0,
    this.zoomLevel = 100.0,
    this.scrollPosition = 0.0,
    this.isPlaying = false,
    this.playbackPosition = 0.0,
    this.hasUnsavedChanges = false,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.filePath,
  })  : id = id ?? const Uuid().v4(),
        tracks = tracks ?? [],
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  /// Create a copy with modified fields
  DawProject copyWith({
    String? name,
    double? tempo,
    int? timeSignatureNumerator,
    int? timeSignatureDenominator,
    int? sampleRate,
    List<DawTrack>? tracks,
    double? masterVolume,
    double? duration,
    double? zoomLevel,
    double? scrollPosition,
    bool? isPlaying,
    double? playbackPosition,
    bool? hasUnsavedChanges,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? filePath,
  }) {
    return DawProject(
      id: id,
      name: name ?? this.name,
      tempo: tempo ?? this.tempo,
      timeSignatureNumerator:
          timeSignatureNumerator ?? this.timeSignatureNumerator,
      timeSignatureDenominator:
          timeSignatureDenominator ?? this.timeSignatureDenominator,
      sampleRate: sampleRate ?? this.sampleRate,
      tracks: tracks ?? this.tracks,
      masterVolume: masterVolume ?? this.masterVolume,
      duration: duration ?? this.duration,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      filePath: filePath ?? this.filePath,
    );
  }

  /// Add a track to the project
  DawProject addTrack(DawTrack track) {
    return copyWith(
      tracks: [...tracks, track],
      hasUnsavedChanges: true,
    );
  }

  /// Remove a track from the project
  DawProject removeTrack(String trackId) {
    return copyWith(
      tracks: tracks.where((t) => t.id != trackId).toList(),
      hasUnsavedChanges: true,
    );
  }

  /// Update a track in the project
  DawProject updateTrack(DawTrack updatedTrack) {
    final updatedTracks = tracks.map((t) {
      return t.id == updatedTrack.id ? updatedTrack : t;
    }).toList();
    return copyWith(
      tracks: updatedTracks,
      hasUnsavedChanges: true,
    );
  }

  /// Reorder tracks
  DawProject reorderTracks(int oldIndex, int newIndex) {
    final newTracks = List<DawTrack>.from(tracks);
    final track = newTracks.removeAt(oldIndex);
    newTracks.insert(newIndex, track);
    return copyWith(
      tracks: newTracks,
      hasUnsavedChanges: true,
    );
  }

  /// Calculate total project duration from tracks
  DawProject updateDuration() {
    double maxDuration = 0.0;
    for (final track in tracks) {
      for (final clip in track.clips) {
        final clipEnd = clip.startTime + clip.duration;
        if (clipEnd > maxDuration) {
          maxDuration = clipEnd;
        }
      }
    }
    return copyWith(duration: maxDuration);
  }

  /// Check if the project has reached the free tier track limit
  bool get hasReachedFreeLimit => tracks.length >= freeTrackLimit;

  /// Create a default empty project
  factory DawProject.empty(String name) {
    return DawProject(
      name: name,
      tracks: [
        DawTrack(name: 'Track 1', color: 0xFF2196F3),
      ],
    );
  }

  factory DawProject.fromJson(Map<String, dynamic> json) =>
      _$DawProjectFromJson(json);

  Map<String, dynamic> toJson() => _$DawProjectToJson(this);
}

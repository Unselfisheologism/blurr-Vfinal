import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../models/audio_clip.dart';
import '../models/daw_track.dart';
import '../models/daw_project.dart';

/// Manages multi-track audio playback and mixing for the DAW
class DawAudioEngine {
  /// Map of track ID to AudioPlayer instances
  final Map<String, AudioPlayer> _trackPlayers = {};

  /// Map of track ID to RecorderController for live recording
  final Map<String, RecorderController> _trackRecorders = {};

  /// Current project reference
  DawProject? _currentProject;

  /// Master audio player for final output
  final AudioPlayer _masterPlayer = AudioPlayer();

  /// Stream controller for playback position updates
  final _playbackPositionController = StreamController<double>.broadcast();

  /// Stream of playback position (in milliseconds)
  Stream<double> get playbackPositionStream =>
      _playbackPositionController.stream;

  /// Current playback position in milliseconds
  double _currentPosition = 0.0;
  double get currentPosition => _currentPosition;

  /// Whether playback is active
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Timer for syncing playback across tracks
  Timer? _syncTimer;

  /// Initialize the audio engine
  Future<void> initialize() async {
    try {
      // Initialize master player
      await _masterPlayer.setVolume(0.8);
      
      // Listen to master player position for sync
      _masterPlayer.positionStream.listen((position) {
        _currentPosition = position.inMilliseconds.toDouble();
        _playbackPositionController.add(_currentPosition);
      });

      debugPrint('DAW Audio Engine initialized');
    } catch (e) {
      debugPrint('Error initializing audio engine: $e');
      rethrow;
    }
  }

  /// Load a project and prepare all tracks for playback
  Future<void> loadProject(DawProject project) async {
    try {
      // Stop current playback if any
      await stop();

      // Dispose old players
      await _disposeAllPlayers();

      _currentProject = project;

      // Create audio players for each track
      for (final track in project.tracks) {
        if (track.clips.isNotEmpty && !track.isMuted) {
          final player = AudioPlayer();
          await player.setVolume(track.volume);
          _trackPlayers[track.id] = player;
        }
      }

      debugPrint('Project loaded: ${project.name} with ${project.tracks.length} tracks');
    } catch (e) {
      debugPrint('Error loading project: $e');
      rethrow;
    }
  }

  /// Start playback from current position
  Future<void> play() async {
    if (_currentProject == null) {
      debugPrint('No project loaded');
      return;
    }

    try {
      _isPlaying = true;

      // Start all track players
      for (final track in _currentProject!.tracks) {
        if (track.isMuted || track.clips.isEmpty) continue;

        final player = _trackPlayers[track.id];
        if (player != null) {
          await _playTrack(track, player);
        }
      }

      // Start sync timer to keep tracks in sync
      _startSyncTimer();

      debugPrint('Playback started at position: $_currentPosition ms');
    } catch (e) {
      debugPrint('Error starting playback: $e');
      _isPlaying = false;
      rethrow;
    }
  }

  /// Play a specific track
  Future<void> _playTrack(DawTrack track, AudioPlayer player) async {
    try {
      // Find clips that should be playing at current position
      final activeClips = track.clips.where((clip) {
        return clip.startTime <= _currentPosition &&
            clip.endTime > _currentPosition &&
            !clip.isMuted;
      }).toList();

      if (activeClips.isEmpty) return;

      // For simplicity, play the first active clip
      // In a full implementation, you'd handle multiple overlapping clips
      final clip = activeClips.first;

      if (clip.audioPath != null && clip.audioPath!.isNotEmpty) {
        // Calculate seek position within the clip
        final clipOffset = _currentPosition - clip.startTime + clip.offset;

        // Load and play the audio
        if (File(clip.audioPath!).existsSync()) {
          await player.setFilePath(clip.audioPath!);
          await player.setVolume(track.volume * clip.volume);
          await player.seek(Duration(milliseconds: clipOffset.toInt()));
          await player.play();
        } else if (clip.audioPath!.startsWith('http')) {
          await player.setUrl(clip.audioPath!);
          await player.setVolume(track.volume * clip.volume);
          await player.seek(Duration(milliseconds: clipOffset.toInt()));
          await player.play();
        }
      }
    } catch (e) {
      debugPrint('Error playing track ${track.name}: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      _isPlaying = false;
      _syncTimer?.cancel();

      // Pause all track players
      for (final player in _trackPlayers.values) {
        await player.pause();
      }

      debugPrint('Playback paused at position: $_currentPosition ms');
    } catch (e) {
      debugPrint('Error pausing playback: $e');
      rethrow;
    }
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    try {
      _isPlaying = false;
      _syncTimer?.cancel();

      // Stop all track players
      for (final player in _trackPlayers.values) {
        await player.stop();
      }

      // Reset position
      _currentPosition = 0.0;
      _playbackPositionController.add(_currentPosition);

      debugPrint('Playback stopped');
    } catch (e) {
      debugPrint('Error stopping playback: $e');
      rethrow;
    }
  }

  /// Seek to a specific position in milliseconds
  Future<void> seek(double positionMs) async {
    try {
      _currentPosition = positionMs;
      _playbackPositionController.add(_currentPosition);

      // Seek all track players
      for (final player in _trackPlayers.values) {
        await player.seek(Duration(milliseconds: positionMs.toInt()));
      }

      debugPrint('Seeked to position: $positionMs ms');
    } catch (e) {
      debugPrint('Error seeking: $e');
      rethrow;
    }
  }

  /// Start recording on a specific track
  Future<String?> startRecording(DawTrack track, String outputPath) async {
    try {
      final recorder = RecorderController();
      await recorder.checkPermission();

      if (!recorder.hasPermission) {
        debugPrint('Microphone permission not granted');
        return null;
      }

      _trackRecorders[track.id] = recorder;

      await recorder.record(path: outputPath);

      debugPrint('Recording started on track: ${track.name}');
      return outputPath;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return null;
    }
  }

  /// Stop recording on a specific track
  Future<String?> stopRecording(String trackId) async {
    try {
      final recorder = _trackRecorders[trackId];
      if (recorder == null) {
        debugPrint('No active recording on track');
        return null;
      }

      final filePath = await recorder.stop();
      _trackRecorders.remove(trackId);

      debugPrint('Recording stopped. File saved: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Update track volume
  Future<void> setTrackVolume(String trackId, double volume) async {
    final player = _trackPlayers[trackId];
    if (player != null) {
      await player.setVolume(volume.clamp(0.0, 1.0));
    }
  }

  /// Update master volume
  Future<void> setMasterVolume(double volume) async {
    await _masterPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Start a timer to keep track players synchronized
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      // Update position from the first playing track
      for (final player in _trackPlayers.values) {
        if (player.playing) {
          final position = player.position.inMilliseconds.toDouble();
          if ((position - _currentPosition).abs() > 100) {
            // Resync if drift is more than 100ms
            _currentPosition = position;
            _playbackPositionController.add(_currentPosition);
          }
          break;
        }
      }
    });
  }

  /// Dispose all track players
  Future<void> _disposeAllPlayers() async {
    for (final player in _trackPlayers.values) {
      await player.dispose();
    }
    _trackPlayers.clear();

    for (final recorder in _trackRecorders.values) {
      recorder.dispose();
    }
    _trackRecorders.clear();
  }

  /// Dispose the audio engine
  Future<void> dispose() async {
    try {
      await stop();
      await _disposeAllPlayers();
      await _masterPlayer.dispose();
      await _playbackPositionController.close();
      _syncTimer?.cancel();

      debugPrint('DAW Audio Engine disposed');
    } catch (e) {
      debugPrint('Error disposing audio engine: $e');
    }
  }
}

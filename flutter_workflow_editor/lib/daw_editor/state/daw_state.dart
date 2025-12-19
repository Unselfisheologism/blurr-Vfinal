import 'package:flutter/foundation.dart';
import '../models/daw_project.dart';
import '../models/daw_track.dart';
import '../models/audio_clip.dart';
import '../services/daw_audio_engine.dart';
import '../services/daw_effects_processor.dart';
import '../services/daw_export_service.dart';
import '../services/daw_ai_integration.dart';
import '../platform/daw_platform_bridge.dart';

/// Central state management for the DAW editor
class DawState extends ChangeNotifier {
  /// Current project
  DawProject _project;

  /// Audio engine
  final DawAudioEngine _audioEngine = DawAudioEngine();

  /// Effects processor
  final DawEffectsProcessor _effectsProcessor = DawEffectsProcessor();

  /// Export service
  final DawExportService _exportService = DawExportService();

  /// AI integration
 final DawAiIntegration _aiIntegration = DawAiIntegration();

  /// Project history for undo/redo
 final ProjectHistory _history = ProjectHistory();

  /// Selected track ID
  String? _selectedTrackId;

  /// Selected clip ID
  String? _selectedClipId;

  /// Whether services are initialized
  bool _isInitialized = false;

  /// Tool mode (select, trim, split, etc.)
  ToolMode _toolMode = ToolMode.select;

  /// Snap to grid enabled
 bool _snapToGrid = true;

  /// Grid size in milliseconds
  double _gridSize = 250.0; // Quarter note at 120 BPM

  /// Current playback position from audio engine
  double _playbackPosition = 0.0;
  
  /// Whether the user has a Pro subscription
 bool _isProUser = false;

  DawState(DawProject project) : _project = project;

 // Getters
  DawProject get project => _project;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _project.isPlaying;
  double get playbackPosition => _playbackPosition;
  String? get selectedTrackId => _selectedTrackId;
  String? get selectedClipId => _selectedClipId;
  ToolMode get toolMode => _toolMode;
  bool get snapToGrid => _snapToGrid;
  double get gridSize => _gridSize;
  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;
  DawAudioEngine get audioEngine => _audioEngine;
  DawExportService get exportService => _exportService;
  DawAiIntegration get aiIntegration => _aiIntegration;
  bool get isProUser => _isProUser;

  /// Initialize all services
  Future<void> initialize({dynamic agentExecutor}) async {
    if (_isInitialized) return;

    try {
      await _audioEngine.initialize();
      await _effectsProcessor.initialize();
      await _aiIntegration.initialize(agentExecutor);
      
      // Load the project into audio engine
      await _audioEngine.loadProject(_project);
      
      // Listen to playback position updates
      _audioEngine.playbackPositionStream.listen((position) {
        _playbackPosition = position;
        notifyListeners();
      });
      
      // Check Pro subscription status
      await _checkProStatus();

      _isInitialized = true;
      debugPrint('DAW State initialized');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing DAW State: $e');
      rethrow;
    }
  }
  
  /// Check if user has Pro subscription
  Future<void> _checkProStatus() async {
    try {
      final result = await DawPlatformBridge.checkProAccess();
      _isProUser = result ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking Pro status: $e');
      _isProUser = false;
    }
  }

  /// Update the entire project
  void updateProject(DawProject project, {bool addToHistory = true}) {
    if (addToHistory) {
      _addToHistory(_project);
    }
    _project = project;
    notifyListeners();
  }

  /// Add a new track with Pro gating
  Future<void> addTrack({String? name, int? color}) async {
    // Check if track limit is reached for free users
    if (!_isProUser && _project.tracks.length >= 4) {
      throw Exception('Free tier limit reached. Upgrade to Pro for unlimited tracks.');
    }

    final trackName = name ?? 'Track ${_project.tracks.length + 1}';
    final trackColor = color ?? _getNextTrackColor();

    final newTrack = DawTrack(name: trackName, color: trackColor);
    
    _addToHistory(_project);
    _project = _project.addTrack(newTrack);
    
    await _audioEngine.loadProject(_project);
    notifyListeners();
  }

  /// Remove a track
  Future<void> removeTrack(String trackId) async {
    _addToHistory(_project);
    _project = _project.removeTrack(trackId);
    
    await _audioEngine.loadProject(_project);
    notifyListeners();
  }

  /// Update a track
 Future<void> updateTrack(DawTrack track) async {
    _addToHistory(_project);
    _project = _project.updateTrack(track);
    
    await _audioEngine.loadProject(_project);
    notifyListeners();
  }

  /// Add a clip to a track
  Future<void> addClip(String trackId, AudioClip clip) async {
    final track = _project.tracks.firstWhere((t) => t.id == trackId);
    final updatedTrack = track.addClip(clip);
    
    await updateTrack(updatedTrack);
  }

  /// Remove a clip from a track
  Future<void> removeClip(String trackId, String clipId) async {
    final track = _project.tracks.firstWhere((t) => t.id == trackId);
    final updatedTrack = track.removeClip(clipId);
    
    await updateTrack(updatedTrack);
  }

  /// Update a clip
  Future<void> updateClip(String trackId, AudioClip clip) async {
    final track = _project.tracks.firstWhere((t) => t.id == trackId);
    final updatedTrack = track.updateClip(clip);
    
    await updateTrack(updatedTrack);
  }

  /// Start playback
 Future<void> play() async {
    await _audioEngine.play();
    _project = _project.copyWith(isPlaying: true);
    notifyListeners();
 }

  /// Pause playback
  Future<void> pause() async {
    await _audioEngine.pause();
    _project = _project.copyWith(isPlaying: false);
    notifyListeners();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioEngine.stop();
    _project = _project.copyWith(isPlaying: false, playbackPosition: 0.0);
    _playbackPosition = 0.0;
    notifyListeners();
  }

  /// Seek to position
  Future<void> seek(double positionMs) async {
    await _audioEngine.seek(positionMs);
    _project = _project.copyWith(playbackPosition: positionMs);
    notifyListeners();
  }

  /// Update track volume
  Future<void> setTrackVolume(String trackId, double volume) async {
    final track = _project.tracks.firstWhere((t) => t.id == trackId);
    final updatedTrack = track.copyWith(volume: volume);
    
    await _audioEngine.setTrackVolume(trackId, volume);
    await updateTrack(updatedTrack);
  }

  /// Update track pan
  Future<void> setTrackPan(String trackId, double pan) async {
    final track = _project.tracks.firstWhere((t) => t.id == trackId);
    final updatedTrack = track.copyWith(pan: pan);
    
    await updateTrack(updatedTrack);
  }

  /// Toggle track mute
  Future<void> toggleTrackMute(String trackId) async {
    final track = _project.tracks.firstWhere((t) => t.id == trackId);
    final updatedTrack = track.copyWith(isMuted: !track.isMuted);
    
    await updateTrack(updatedTrack);
  }

  /// Toggle track solo
  Future<void> toggleTrackSolo(String trackId) async {
    final track = _project.tracks.firstWhere((t) => t.id == trackId);
    final updatedTrack = track.copyWith(isSolo: !track.isSolo);
    
    await updateTrack(updatedTrack);
  }

  /// Set master volume
  Future<void> setMasterVolume(double volume) async {
    await _audioEngine.setMasterVolume(volume);
    _project = _project.copyWith(masterVolume: volume);
    notifyListeners();
 }

  /// Set zoom level
  void setZoomLevel(double zoom) {
    _project = _project.copyWith(zoomLevel: zoom);
    notifyListeners();
  }

  /// Set scroll position
 void setScrollPosition(double position) {
    _project = _project.copyWith(scrollPosition: position);
    notifyListeners();
  }

  /// Select a track
  void selectTrack(String? trackId) {
    _selectedTrackId = trackId;
    notifyListeners();
 }

  /// Select a clip
  void selectClip(String? clipId) {
    _selectedClipId = clipId;
    notifyListeners();
  }

  /// Set tool mode
 void setToolMode(ToolMode mode) {
    _toolMode = mode;
    notifyListeners();
  }

  /// Toggle snap to grid
 void toggleSnapToGrid() {
    _snapToGrid = !_snapToGrid;
    notifyListeners();
  }

  /// Set grid size
  void setGridSize(double size) {
    _gridSize = size;
    notifyListeners();
  }

  /// Undo last action
 void undo() {
    if (_history.canUndo) {
      _history.redoStack.add(_project);
      _project = _history.undoStack.removeLast();
      notifyListeners();
    }
  }

  /// Redo last undone action
  void redo() {
    if (_history.canRedo) {
      _history.undoStack.add(_project);
      _project = _history.redoStack.removeLast();
      notifyListeners();
    }
  }

  /// Add current project to history
  void _addToHistory(DawProject project) {
    _history.undoStack.add(project);
    _history.redoStack.clear();
    
    // Limit history size
    if (_history.undoStack.length > _history.maxHistorySize) {
      _history.undoStack.removeAt(0);
    }
  }

  /// Get next track color (cycling through palette)
  int _getNextTrackColor() {
    final colors = [
      0xFF2196F3, // Blue
      0xFF4CAF50, // Green
      0xFFF44336, // Red
      0xFFFF9800, // Orange
      0xFF9C27B0, // Purple
      0xFF00BCD4, // Cyan
      0xFFFFEB3B, // Yellow
      0xFFE91E63, // Pink
    ];
    return colors[_project.tracks.length % colors.length];
  }

  /// Snap position to grid
  double snapPositionToGrid(double position) {
    if (!_snapToGrid) return position;
    return (position / _gridSize).round() * _gridSize;
  }
  
  /// Check if track limit is reached for free users
  bool get isTrackLimitReached => !_isProUser && _project.tracks.length >= 4;
  
  /// Get max track count based on subscription
  int get maxTrackCount => _isProUser ? 999 : 4;
  
  /// Check if advanced effects are available (Pro feature)
  bool get areAdvancedEffectsAvailable => _isProUser;

  @override
  void dispose() {
    _audioEngine.dispose();
    _effectsProcessor.dispose();
    _aiIntegration.dispose();
    super.dispose();
  }
}

/// Tool modes for the DAW editor
enum ToolMode {
  select,
  trim,
  split,
  fade,
  draw,
}

/// Project history for undo/redo functionality
class ProjectHistory {
  final List<DawProject> undoStack = [];
  final List<DawProject> redoStack = [];
  static const int maxHistorySize = 50;
}

/// Empty constructor for DawState to create an empty project
extension DawStateEmpty on DawState {
  static DawState empty() {
    return DawState(DawProject.empty('Untitled Project'));
  }
}

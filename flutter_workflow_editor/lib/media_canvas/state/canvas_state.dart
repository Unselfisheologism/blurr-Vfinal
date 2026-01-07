/// Canvas state management inspired by Refly canvas.controller
import 'package:flutter/material.dart';
import '../models/media_layer_node.dart';
import '../services/canvas_storage_service.dart';

class CanvasState extends ChangeNotifier {
  CanvasDocument? _currentDocument;
  bool _isLoading = false;
  String? _error;
  bool _isPro = false;
  bool _initialized = false;

  // View state
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;

  // History for undo/redo
  final List<CanvasDocument> _history = [];
  int _historyIndex = -1;
  static const int _maxHistorySize = 50;

  final CanvasStorageService _storageService = CanvasStorageService();

  // Getters
  CanvasDocument? get currentDocument => _currentDocument;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPro => _isPro;
  bool get isInitialized => _initialized;
  double get zoom => _zoom;
  Offset get panOffset => _panOffset;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  bool get hasDocument => _currentDocument != null;

  // Pro limits
  int get maxLayers => _isPro ? 9999 : 50;
  bool get canUseVideo => _isPro;
  bool get canUseAdvancedAI => _isPro;

  /// Initialize the state
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _storageService.initialize();
      _initialized = true;
    } catch (e) {
      _error = 'Failed to initialize storage: $e';
      notifyListeners();
    }
  }

  /// Set Pro status
  void setProStatus(bool isPro) {
    _isPro = isPro;
    notifyListeners();
  }

  /// Create new canvas
  Future<void> createNewCanvas(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentDocument = CanvasDocument.empty(name);
      await _storageService.saveDocument(_currentDocument!);
      _recordHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create canvas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load canvas
  Future<void> loadCanvas(String documentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentDocument = await _storageService.loadDocument(documentId);
      _history.clear();
      _historyIndex = -1;
      _recordHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load canvas: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save canvas
  Future<void> saveCanvas() async {
    if (_currentDocument == null) return;

    try {
      await _storageService.saveDocument(_currentDocument!);
    } catch (e) {
      _error = 'Failed to save canvas: $e';
      notifyListeners();
    }
  }

  /// Add layer
  void addLayer(MediaLayerNode layer) {
    if (_currentDocument == null) return;

    // Check Pro limits
    if (_currentDocument!.layers.length >= maxLayers) {
      _error = 'Layer limit reached. ${_isPro ? '' : 'Upgrade to Pro for unlimited layers.'}';
      notifyListeners();
      return;
    }

    // Check video layer Pro limit
    if (layer.type == MediaLayerType.video && !canUseVideo) {
      _error = 'Video layers require Pro subscription.';
      notifyListeners();
      return;
    }

    final updatedLayers = List<MediaLayerNode>.from(_currentDocument!.layers)..add(layer);
    _currentDocument = _currentDocument!.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );
    _recordHistory();
    notifyListeners();
  }

  /// Update layer
  void updateLayer(String layerId, MediaLayerNode updatedLayer) {
    if (_currentDocument == null) return;

    final updatedLayers = _currentDocument!.layers.map((layer) {
      return layer.id == layerId ? updatedLayer : layer;
    }).toList();

    _currentDocument = _currentDocument!.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );
    _recordHistory();
    notifyListeners();
  }

  /// Delete layer
  void deleteLayer(String layerId) {
    if (_currentDocument == null) return;

    final updatedLayers = _currentDocument!.layers.where((layer) => layer.id != layerId).toList();
    _currentDocument = _currentDocument!.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );
    _recordHistory();
    notifyListeners();
  }

  /// Duplicate layer
  void duplicateLayer(String layerId) {
    if (_currentDocument == null) return;

    final layer = _currentDocument!.getLayer(layerId);
    if (layer == null) return;

    // Check Pro limits
    if (_currentDocument!.layers.length >= maxLayers) {
      _error = 'Layer limit reached. ${_isPro ? '' : 'Upgrade to Pro for unlimited layers.'}';
      notifyListeners();
      return;
    }

    final newLayer = layer.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${layer.name} (copy)',
      transform: layer.transform.copyWith(
        x: layer.transform.x + 20,
        y: layer.transform.y + 20,
      ),
    );

    addLayer(newLayer);
  }

  /// Reorder layers
  void reorderLayers(int oldIndex, int newIndex) {
    if (_currentDocument == null) return;

    final layers = List<MediaLayerNode>.from(_currentDocument!.layers);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);

    // Update z-indices
    final updatedLayers = layers.asMap().entries.map((entry) {
      return entry.value.copyWith(zIndex: entry.key);
    }).toList();

    _currentDocument = _currentDocument!.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );
    _recordHistory();
    notifyListeners();
  }

  /// Select layer
  void selectLayer(String layerId, {bool multiSelect = false}) {
    if (_currentDocument == null) return;

    if (multiSelect) {
      final selectedIds = Set<String>.from(_currentDocument!.selectedLayerIds);
      if (selectedIds.contains(layerId)) {
        selectedIds.remove(layerId);
      } else {
        selectedIds.add(layerId);
      }
      _currentDocument = _currentDocument!.copyWith(
        selectedLayerId: selectedIds.isNotEmpty ? layerId : null,
        selectedLayerIds: selectedIds,
      );
    } else {
      _currentDocument = _currentDocument!.copyWith(
        selectedLayerId: layerId,
        selectedLayerIds: {layerId},
      );
    }
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    if (_currentDocument == null) return;
    _currentDocument = _currentDocument!.copyWith(
      selectedLayerId: null,
      selectedLayerIds: {},
    );
    notifyListeners();
  }

  /// Update layer transform
  void updateLayerTransform(String layerId, LayerTransform transform) {
    if (_currentDocument == null) return;

    final layer = _currentDocument!.getLayer(layerId);
    if (layer == null || layer.locked) return;

    updateLayer(layerId, layer.copyWith(transform: transform));
  }

  /// Set zoom
  void setZoom(double zoom) {
    _zoom = zoom.clamp(0.1, 5.0);
    notifyListeners();
  }

  /// Set pan offset
  void setPanOffset(Offset offset) {
    _panOffset = offset;
    notifyListeners();
  }

  /// Undo
  void undo() {
    if (!canUndo) return;
    _historyIndex--;
    _currentDocument = _history[_historyIndex];
    notifyListeners();
  }

  /// Redo
  void redo() {
    if (!canRedo) return;
    _historyIndex++;
    _currentDocument = _history[_historyIndex];
    notifyListeners();
  }

  /// Record state in history
  void _recordHistory() {
    if (_currentDocument == null) return;

    // Remove any states after current index
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    // Add current state
    _history.add(_currentDocument!);
    _historyIndex = _history.length - 1;

    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get selected layers
  List<MediaLayerNode> get selectedLayers {
    if (_currentDocument == null) return [];
    return _currentDocument!.layers
        .where((layer) => _currentDocument!.selectedLayerIds.contains(layer.id))
        .toList();
  }
}

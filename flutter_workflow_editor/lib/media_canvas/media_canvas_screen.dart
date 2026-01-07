/// Main media canvas screen with infinite zoomable workspace
/// Combines fl_nodes concepts, InteractiveViewer, and Jaaz/Refly inspiration
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/canvas_state.dart';
import 'models/media_layer_node.dart';
import 'services/ai_generation_service.dart';
import 'widgets/canvas_layer_widget.dart';
import 'widgets/layer_sidebar.dart';
import 'widgets/ai_prompt_panel.dart';

class MediaCanvasScreen extends StatefulWidget {
  final String? documentId;
  final String? initialPrompt;

  const MediaCanvasScreen({
    super.key,
    this.documentId,
    this.initialPrompt,
  });

  @override
  State<MediaCanvasScreen> createState() => _MediaCanvasScreenState();
}

class _MediaCanvasScreenState extends State<MediaCanvasScreen> {
  final TransformationController _transformController = TransformationController();
  final AIGenerationService _aiService = AIGenerationService();
  bool _isGenerating = false;
  late CanvasState _canvasState;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    // Initialize state immediately in initState to avoid race conditions
    _canvasState = context.read<CanvasState>();
    _initializeCanvas();
  }

  Future<void> _initializeCanvas() async {
    if (_isInitializing) return;
    
    setState(() {
      _isInitializing = true;
    });

    try {
      // Ensure state is fully initialized
      if (!_canvasState.isInitialized) {
        await _canvasState.initialize();
      }

      if (widget.documentId != null) {
        await _canvasState.loadCanvas(widget.documentId!);
      } else if (widget.initialPrompt != null) {
        await _createFromPrompt(widget.initialPrompt!);
      } else {
        await _canvasState.createNewCanvas('Untitled Canvas');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _createFromPrompt(String prompt) async {
    await _canvasState.createNewCanvas('AI Canvas');
    await _handleAIGenerate(prompt, 'image');
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CanvasState>(
        builder: (context, state, child) {
          if (_isInitializing || state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return _buildErrorState(state);
          }

          if (!state.hasDocument) {
            return const Center(child: Text('No canvas loaded'));
          }

          return Stack(
            children: [
              // Main canvas area
              Row(
                children: [
                  // Layer sidebar
                  LayerSidebar(
                    layers: state.currentDocument!.sortedLayers,
                    selectedLayerIds: state.currentDocument!.selectedLayerIds,
                    onLayerTap: (layerId) => state.selectLayer(layerId),
                    onReorder: (oldIndex, newIndex) => state.reorderLayers(oldIndex, newIndex),
                    onDelete: (layerId) => state.deleteLayer(layerId),
                    onDuplicate: (layerId) => state.duplicateLayer(layerId),
                    onToggleVisibility: (layerId) => _toggleVisibility(layerId),
                    onToggleLock: (layerId) => _toggleLock(layerId),
                  ),

                  // Canvas
                  Expanded(
                    child: _buildCanvas(state),
                  ),
                ],
              ),

              // Top toolbar
              Positioned(
                top: 0,
                left: 280,
                right: 0,
                child: _buildTopToolbar(state),
              ),

              // AI prompt panel (bottom)
              Positioned(
                bottom: 0,
                left: 280,
                right: 0,
                child: AIPromptPanel(
                  onGenerate: _handleAIGenerate,
                  isGenerating: _isGenerating,
                  isPro: state.isPro,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCanvas(CanvasState state) {
    final document = state.currentDocument!;

    return Container(
      color: _parseColor(document.backgroundColor) ?? Colors.grey.shade100,
      child: InteractiveViewer(
        transformationController: _transformController,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 5.0,
        onInteractionUpdate: (details) {
          state.setZoom(_transformController.value.getMaxScaleOnAxis());
        },
        child: GestureDetector(
          onTap: () => state.clearSelection(),
          child: Container(
            width: document.canvasWidth,
            height: document.canvasHeight,
            color: Colors.white,
            child: Stack(
              children: [
                // Grid background
                CustomPaint(
                  size: Size(document.canvasWidth, document.canvasHeight),
                  painter: GridPainter(),
                ),

                // Layers
                ...document.sortedLayers.map((layer) {
                  final isSelected = document.selectedLayerIds.contains(layer.id);
                  return CanvasLayerWidget(
                    key: ValueKey(layer.id),
                    layer: layer,
                    isSelected: isSelected,
                    onTap: () => state.selectLayer(layer.id),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopToolbar(CanvasState state) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Canvas name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              state.currentDocument!.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const VerticalDivider(),

          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: state.canUndo ? () => state.undo() : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: state.canRedo ? () => state.redo() : null,
            tooltip: 'Redo',
          ),
          const VerticalDivider(),

          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _zoomBy(0.8),
            tooltip: 'Zoom Out',
          ),
          Text(
            '${(state.zoom * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _zoomBy(1.25),
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _resetView,
            tooltip: 'Fit to Screen',
          ),
          const VerticalDivider(),

          // Export
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _handleExport,
            tooltip: 'Export',
          ),

          // AI Suggestions
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _handleAISuggestions,
            tooltip: 'AI Suggestions',
          ),

          const Spacer(),

          // Layer count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              avatar: const Icon(Icons.layers, size: 16),
              label: Text('${state.currentDocument!.layers.length} layers'),
            ),
          ),

          // Close
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CanvasState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(state.error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              state.clearError();
              _initializeCanvas();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Action handlers
  Future<void> _handleAIGenerate(String prompt, String mediaType) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      MediaLayerNode? layer;

      switch (mediaType) {
        case 'image':
          layer = await _aiService.generateImage(prompt: prompt);
          break;
        case 'video':
          if (!_canvasState.canUseVideo) {
            _showSnackBar('Video generation requires Pro subscription');
            setState(() {
              _isGenerating = false;
            });
            return;
          }
          layer = await _aiService.generateVideo(prompt: prompt);
          break;
        case 'audio':
          layer = await _aiService.generateAudio(prompt: prompt);
          break;
        case 'text':
          layer = await _aiService.generateText(prompt: prompt);
          break;
        case '3d':
          if (!_canvasState.isPro) {
            _showSnackBar('3D model generation requires Pro subscription');
            setState(() {
              _isGenerating = false;
            });
            return;
          }
          layer = await _aiService.generate3DModel(prompt: prompt);
          break;
      }

      if (layer != null) {
        _canvasState.addLayer(layer);
        _showSnackBar('Layer created successfully!');
      } else {
        _showSnackBar('Failed to generate $mediaType');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _handleAISuggestions() async {
    if (!_canvasState.hasDocument) return;

    _showLoadingDialog('Analyzing canvas...');

    try {
      final analysis = await _aiService.analyzeScene(
        layers: _canvasState.currentDocument!.layers,
      );

      Navigator.of(context).pop();

      if (analysis != null) {
        _showSuggestionsDialog(analysis['suggestions'] as String);
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar('Error: $e');
    }
  }

  void _handleExport() {
    // TODO: Implement export functionality
    _showSnackBar('Export feature coming soon');
  }

  void _toggleVisibility(String layerId) {
    final layer = _canvasState.currentDocument!.getLayer(layerId);
    if (layer != null) {
      _canvasState.updateLayer(layerId, layer.copyWith(visible: !layer.visible));
    }
  }

  void _toggleLock(String layerId) {
    final layer = _canvasState.currentDocument!.getLayer(layerId);
    if (layer != null) {
      _canvasState.updateLayer(layerId, layer.copyWith(locked: !layer.locked));
    }
  }

  void _zoomBy(double factor) {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.1, 5.0);
    
    final matrix = Matrix4.identity()..scale(newScale);
    _transformController.value = matrix;
    _canvasState.setZoom(newScale);
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
    _canvasState.setZoom(1.0);
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSuggestionsDialog(String suggestions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text('AI Suggestions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(suggestions),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color? _parseColor(String? hexColor) {
    if (hexColor == null) return null;
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

/// Grid painter for canvas background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    const gridSize = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

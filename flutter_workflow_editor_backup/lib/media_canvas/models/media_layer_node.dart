/// Media layer node models extending fl_nodes for multimodal canvas
/// Inspired by Jaaz canvas elements and Refly canvas nodes
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_layer_node.g.dart';

/// Type of media layer
enum MediaLayerType {
  image,
  video,
  audio,
  text,
  shape,
  group,
  model3d, // 3D model layer (GLB/GLTF)
}

/// Transform data for layer positioning and scaling
@JsonSerializable()
class LayerTransform {
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation; // in radians
  final double scaleX;
  final double scaleY;
  final double opacity;

  const LayerTransform({
    this.x = 0,
    this.y = 0,
    this.width = 200,
    this.height = 200,
    this.rotation = 0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.opacity = 1.0,
  });

  factory LayerTransform.fromJson(Map<String, dynamic> json) => _$LayerTransformFromJson(json);
  Map<String, dynamic> toJson() => _$LayerTransformToJson(this);

  LayerTransform copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scaleX,
    double? scaleY,
    double? opacity,
  }) {
    return LayerTransform(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      opacity: opacity ?? this.opacity,
    );
  }

  /// Get bounding rect
  Rect get rect => Rect.fromLTWH(x, y, width * scaleX, height * scaleY);
}

/// Base media layer node
@JsonSerializable()
class MediaLayerNode {
  final String id;
  final String name;
  final MediaLayerType type;
  final LayerTransform transform;
  final bool visible;
  final bool locked;
  final int zIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Type-specific data stored as JSON
  final Map<String, dynamic>? data;

  const MediaLayerNode({
    required this.id,
    required this.name,
    required this.type,
    this.transform = const LayerTransform(),
    this.visible = true,
    this.locked = false,
    this.zIndex = 0,
    required this.createdAt,
    required this.updatedAt,
    this.data,
  });

  factory MediaLayerNode.fromJson(Map<String, dynamic> json) => _$MediaLayerNodeFromJson(json);
  Map<String, dynamic> toJson() => _$MediaLayerNodeToJson(this);

  MediaLayerNode copyWith({
    String? id,
    String? name,
    MediaLayerType? type,
    LayerTransform? transform,
    bool? visible,
    bool? locked,
    int? zIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? data,
  }) {
    return MediaLayerNode(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      transform: transform ?? this.transform,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      zIndex: zIndex ?? this.zIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      data: data ?? this.data,
    );
  }

  /// Factory constructors for specific layer types
  factory MediaLayerNode.image({
    required String id,
    required String name,
    required String imageUrl,
    String? thumbnailUrl,
    LayerTransform? transform,
  }) {
    return MediaLayerNode(
      id: id,
      name: name,
      type: MediaLayerType.image,
      transform: transform ?? const LayerTransform(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
      },
    );
  }

  factory MediaLayerNode.video({
    required String id,
    required String name,
    required String videoUrl,
    String? thumbnailUrl,
    double? duration,
    LayerTransform? transform,
  }) {
    return MediaLayerNode(
      id: id,
      name: name,
      type: MediaLayerType.video,
      transform: transform ?? const LayerTransform(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'duration': duration,
        'isPlaying': false,
        'currentTime': 0.0,
      },
    );
  }

  factory MediaLayerNode.audio({
    required String id,
    required String name,
    required String audioUrl,
    double? duration,
    LayerTransform? transform,
  }) {
    return MediaLayerNode(
      id: id,
      name: name,
      type: MediaLayerType.audio,
      transform: transform ?? const LayerTransform(width: 300, height: 60),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'audioUrl': audioUrl,
        'duration': duration,
        'isPlaying': false,
        'currentTime': 0.0,
        'waveformData': null,
      },
    );
  }

  factory MediaLayerNode.text({
    required String id,
    required String name,
    required String content,
    String? fontFamily,
    double? fontSize,
    String? textColor,
    String? backgroundColor,
    LayerTransform? transform,
  }) {
    return MediaLayerNode(
      id: id,
      name: name,
      type: MediaLayerType.text,
      transform: transform ?? const LayerTransform(width: 400, height: 100),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'content': content,
        'fontFamily': fontFamily ?? 'Roboto',
        'fontSize': fontSize ?? 24.0,
        'textColor': textColor ?? '#000000',
        'backgroundColor': backgroundColor,
        'textAlign': 'left',
        'bold': false,
        'italic': false,
      },
    );
  }

  factory MediaLayerNode.shape({
    required String id,
    required String name,
    required String shapeType, // 'rectangle', 'circle', 'line', 'arrow'
    String? fillColor,
    String? strokeColor,
    double? strokeWidth,
    LayerTransform? transform,
  }) {
    return MediaLayerNode(
      id: id,
      name: name,
      type: MediaLayerType.shape,
      transform: transform ?? const LayerTransform(width: 200, height: 200),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'shapeType': shapeType,
        'fillColor': fillColor ?? '#3498db',
        'strokeColor': strokeColor ?? '#2c3e50',
        'strokeWidth': strokeWidth ?? 2.0,
      },
    );
  }

  factory MediaLayerNode.group({
    required String id,
    required String name,
    required List<String> childIds,
    LayerTransform? transform,
  }) {
    return MediaLayerNode(
      id: id,
      name: name,
      type: MediaLayerType.group,
      transform: transform ?? const LayerTransform(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'childIds': childIds,
      },
    );
  }

  factory MediaLayerNode.model3d({
    required String id,
    required String name,
    required String modelUrl, // GLB/GLTF URL
    String? thumbnailUrl,
    LayerTransform? transform,
  }) {
    return MediaLayerNode(
      id: id,
      name: name,
      type: MediaLayerType.model3d,
      transform: transform ?? const LayerTransform(width: 300, height: 300),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      data: {
        'modelUrl': modelUrl,
        'thumbnailUrl': thumbnailUrl,
        'modelFormat': modelUrl.endsWith('.glb') ? 'glb' : 'gltf',
      },
    );
  }

  /// Get typed data helpers
  String? get imageUrl => data?['imageUrl'] as String?;
  String? get videoUrl => data?['videoUrl'] as String?;
  String? get audioUrl => data?['audioUrl'] as String?;
  String? get thumbnailUrl => data?['thumbnailUrl'] as String?;
  String? get textContent => data?['content'] as String?;
  String? get shapeType => data?['shapeType'] as String?;
  String? get modelUrl => data?['modelUrl'] as String?;
  String? get modelFormat => data?['modelFormat'] as String?;
  List<String>? get childIds => (data?['childIds'] as List?)?.cast<String>();
}

/// Canvas document containing all layers
@JsonSerializable()
class CanvasDocument {
  final String id;
  final String name;
  final List<MediaLayerNode> layers;
  final String? selectedLayerId;
  final Set<String> selectedLayerIds;
  final double canvasWidth;
  final double canvasHeight;
  final String? backgroundColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CanvasDocument({
    required this.id,
    required this.name,
    this.layers = const [],
    this.selectedLayerId,
    this.selectedLayerIds = const {},
    this.canvasWidth = 1920,
    this.canvasHeight = 1080,
    this.backgroundColor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CanvasDocument.fromJson(Map<String, dynamic> json) => _$CanvasDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$CanvasDocumentToJson(this);

  CanvasDocument copyWith({
    String? id,
    String? name,
    List<MediaLayerNode>? layers,
    String? selectedLayerId,
    Set<String>? selectedLayerIds,
    double? canvasWidth,
    double? canvasHeight,
    String? backgroundColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CanvasDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      layers: layers ?? this.layers,
      selectedLayerId: selectedLayerId ?? this.selectedLayerId,
      selectedLayerIds: selectedLayerIds ?? this.selectedLayerIds,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create empty canvas
  factory CanvasDocument.empty(String name) {
    final now = DateTime.now();
    return CanvasDocument(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      layers: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get layer by ID
  MediaLayerNode? getLayer(String id) {
    try {
      return layers.firstWhere((layer) => layer.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get layers sorted by z-index
  List<MediaLayerNode> get sortedLayers {
    final sorted = List<MediaLayerNode>.from(layers);
    sorted.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return sorted;
  }
}

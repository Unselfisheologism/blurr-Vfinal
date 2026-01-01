// GENERATED CODE - DO NOT MODIFY BY HAND
// JSON serialization for media layer nodes

part of 'media_layer_node.dart';

LayerTransform _$LayerTransformFromJson(Map<String, dynamic> json) => LayerTransform(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 200,
      height: (json['height'] as num?)?.toDouble() ?? 200,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      scaleX: (json['scaleX'] as num?)?.toDouble() ?? 1.0,
      scaleY: (json['scaleY'] as num?)?.toDouble() ?? 1.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$LayerTransformToJson(LayerTransform instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'rotation': instance.rotation,
      'scaleX': instance.scaleX,
      'scaleY': instance.scaleY,
      'opacity': instance.opacity,
    };

MediaLayerNode _$MediaLayerNodeFromJson(Map<String, dynamic> json) => MediaLayerNode(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$MediaLayerTypeEnumMap, json['type']),
      transform: json['transform'] == null
          ? const LayerTransform()
          : LayerTransform.fromJson(json['transform'] as Map<String, dynamic>),
      visible: json['visible'] as bool? ?? true,
      locked: json['locked'] as bool? ?? false,
      zIndex: json['zIndex'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MediaLayerNodeToJson(MediaLayerNode instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$MediaLayerTypeEnumMap[instance.type]!,
      'transform': instance.transform.toJson(),
      'visible': instance.visible,
      'locked': instance.locked,
      'zIndex': instance.zIndex,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'data': instance.data,
    };

const _$MediaLayerTypeEnumMap = {
  MediaLayerType.image: 'image',
  MediaLayerType.video: 'video',
  MediaLayerType.audio: 'audio',
  MediaLayerType.text: 'text',
  MediaLayerType.shape: 'shape',
  MediaLayerType.group: 'group',
  MediaLayerType.model3d: 'model3d',
};

T $enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  return enumValues.entries.singleWhere((e) => e.value == source).key;
}

CanvasDocument _$CanvasDocumentFromJson(Map<String, dynamic> json) => CanvasDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      layers: (json['layers'] as List<dynamic>?)
              ?.map((e) => MediaLayerNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedLayerId: json['selectedLayerId'] as String?,
      selectedLayerIds: (json['selectedLayerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      canvasWidth: (json['canvasWidth'] as num?)?.toDouble() ?? 1920,
      canvasHeight: (json['canvasHeight'] as num?)?.toDouble() ?? 1080,
      backgroundColor: json['backgroundColor'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CanvasDocumentToJson(CanvasDocument instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layers': instance.layers.map((e) => e.toJson()).toList(),
      'selectedLayerId': instance.selectedLayerId,
      'selectedLayerIds': instance.selectedLayerIds.toList(),
      'canvasWidth': instance.canvasWidth,
      'canvasHeight': instance.canvasHeight,
      'backgroundColor': instance.backgroundColor,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

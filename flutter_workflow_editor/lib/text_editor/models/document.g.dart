// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditorDocument _$EditorDocumentFromJson(Map<String, dynamic> json) =>
    EditorDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as List<dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      isTemplate: json['isTemplate'] as bool? ?? false,
      templateCategory: json['templateCategory'] as String?,
      requiresPro: json['requiresPro'] as bool? ?? false,
    );

Map<String, dynamic> _$EditorDocumentToJson(EditorDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'isTemplate': instance.isTemplate,
      'templateCategory': instance.templateCategory,
      'requiresPro': instance.requiresPro,
    };

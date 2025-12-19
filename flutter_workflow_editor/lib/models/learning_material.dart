import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'learning_material.freezed.dart';
part 'learning_material.g.dart';

// Type of learning material
enum MaterialType {
  pdf,
  text,
  markdown,
  url,
  quiz,
  flashcardDeck,
  audio,
  video,
}

// Source of the material
enum MaterialSource {
  local, // User uploaded
  cloud, // Cloud storage
  generated, // AI generated
  external, // External link
}

@freezed
class LearningMaterial with _$LearningMaterial {
  const factory LearningMaterial({
    required String id,
    required String title,
    required MaterialType type,
    required MaterialSource source,
    String? description,
    String? content, // For text-based materials
    String? filePath, // For local files
    String? url, // For external links
    String? thumbnailUrl, // For visual preview
    int? size, // File size in bytes
    
    // Metadata
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    
    // AI-generated content
    @Default(false) bool aiProcessed,
    AISummary? aiSummary,
    int? estimatedReadTime,
    int? estimatedListenTime,
    
    // Relationships
    String? courseId, // If part of a structured course
    String? chapterId,
    String? activityId,
    
    // Progress tracking
    @Default(0) double progress, // 0-100
    DateTime? completedAt,
    @Default({}) Map<String, dynamic> userProgress,
  }) = _LearningMaterial;

  factory LearningMaterial.fromJson(Map<String, dynamic> json) =>
      _$LearningMaterialFromJson(json);
}

@freezed
class AISummary with _$AISummary {
  const factory AISummary({
    required String briefSummary,
    String? detailedSummary,
    List<String>? keyPoints,
    List<String>? mainTopics,
    String? difficultyLevel, // beginner, intermediate, advanced
    List<String>? prerequisites,
    Map<String, dynamic>? customFields,
  }) = _AISummary;

  factory AISummary.fromJson(Map<String, dynamic> json) =>
      _$AISummaryFromJson(json);
}

// Used for recommended materials
@freezed
class MaterialRecommendation with _$MaterialRecommendation {
  const factory MaterialRecommendation({
    required String materialId,
    required double relevanceScore,
    required String reason,
    List<String>? prerequisites,
    String? difficultyLevel,
    Map<String, dynamic>? metadata,
  }) = _MaterialRecommendation;

  factory MaterialRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MaterialRecommendationFromJson(json);
}
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'learning_path.freezed.dart';
part 'learning_path.g.dart';

@freezed
class LearningPath with _$LearningPath {
  const factory LearningPath({
    required String id,
    required String title,
    String? description,
    required String creatorId,
    
    // Path structure
    @Default([]) List<String> materialIds,
    @Default([]) List<String> activityIds,
    @Default([]) List<PathMilestone> milestones,
    
    // Path properties
    @Default(false) bool isLinear, // Sequential progression if true
    @Default(true) bool isAdaptive, // AI-powered recommendations
    @Default(false) bool isPublished,
    
    // Metadata
    List<String>? prerequisites,
    String? difficultyLevel,
    @Default(0) int estimatedDuration,
    List<String>? tags,
    String? coverImageUrl,
    
    // Categorization
    @Default(PathCategory.custom) PathCategory category,
    String? language,
    
    // Version control
    @Default(1) int version,
    String? parentPathId, // For versioning
    
    // Progress tracking
    @Default(0) int enrollmentCount,
    @Default(0) double averageCompletionRate,
    @Default(0) double averageRating,
    Map<String, dynamic>? completionStats,
    
    // User customization
    @Default(false) bool allowCustomization,
    @Default({}) Map<String, dynamic> customizationOptions,
    
    // AI-generated content
    AIGeneratedPathContent? aiContent,
    @Default(false) bool aiEnhanced,
    
    // Timestamps
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    Map<String, dynamic>? metadata,
  }) = _LearningPath;

  factory LearningPath.fromJson(Map<String, dynamic> json) =>
      _$LearningPathFromJson(json);
}

@freezed
class PathMilestone with _$PathMilestone {
  const factory PathMilestone({
    required String id,
    required String title,
    required int orderIndex,
    String? description,
    required List<String> requiredMaterials,
    required List<String> requiredActivities,
    @Default([]) List<String> evaluationCriteria,
    
    // Achievement
    String? badgeName,
    String? badgeIcon,
    @Default(0) int pointsReward,
    
    // Validation
    @Default(false) bool isOptional,
    @Default(false) bool autoComplete,
    Map<String, dynamic>? completionRules,
    
    // Rewards
    List<String>? unlocksFeatures,
    List<String>? unlocksMaterials,
    
    Map<String, dynamic>? metadata,
  }) = _PathMilestone;

  factory PathMilestone.fromJson(Map<String, dynamic> json) =>
      _$PathMilestoneFromJson(json);
}

enum PathCategory {
  skillDevelopment,
  certification,
  academic,
  professional,
  personalGrowth,
  custom,
}

@freezed
class PathProgress with _$PathProgress {
  const factory PathProgress({
    required String pathId,
    required String userId,
    @Default('not_started') String status, // not_started, in_progress, completed, paused
    
    // Progress tracking
    @Default([]) List<String> completedMaterials,
    @Default([]) List<String> completedActivities,
    @Default([]) List<String> completedMilestones,
    
    // Current position
    String? currentMaterialId,
    String? currentActivityId,
    String? nextRecommendedMaterialId,
    String? nextRecommendedActivityId,
    
    // Scores and metrics
    @Default(0) double overallScore,
    @Default(0) int timeSpent, // in seconds
    @Default(0) int streakDays,
    DateTime? lastStudySession,
    
    // Personalized adjustments
    @Default(false) bool isPersonalized,
    Map<String, dynamic>? personalizationSettings,
    
    // Study schedule
    StudySchedule? studySchedule,
    @Default([]) List<String> upcomingReminders,
    
    // Achievement tracking
    @Default([]) List<String> earnedBadges,
    @Default(0) int totalPoints,
    Map<String, dynamic>? achievements,
    
    // Timestamps
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastActivityAt,
    Map<String, dynamic>? metadata,
  }) = _PathProgress;

  factory PathProgress.fromJson(Map<String, dynamic> json) =>
      _$PathProgressFromJson(json);
}

@freezed
class StudySchedule with _$StudySchedule {
  const factory StudySchedule({
    required String frequency, // daily, weekly, custom
    required Map<String, dynamic> schedule,
    @Default(false) bool remindersEnabled,
    List<String>? reminderTimes, // HH:MM format
    int? dailyGoal, // minutes per day
    List<String>? studyDays, // e.g., ['Mon', 'Wed', 'Fri']
    Map<String, dynamic>? preferences,
  }) = _StudySchedule;

  factory StudySchedule.fromJson(Map<String, dynamic> json) =>
      _$StudyScheduleFromJson(json);
}

@freezed
class AIGeneratedPathContent with _$AIGeneratedPathContent {
  const factory AIGeneratedPathContent({
    required String learningObjective,
    required List<String> keyTopics,
    required List<String> skills,
    String? careerImpact,
    String? difficultyAssessment,
    List<String>? recommendedPrerequisites,
    Map<String, dynamic>? learningOutcomes, // Bloom's taxonomy breakdown
  }) = _AIGeneratedPathContent;

  factory AIGeneratedPathContent.fromJson(Map<String, dynamic> json) =>
      _$AIGeneratedPathContentFromJson(json);
}
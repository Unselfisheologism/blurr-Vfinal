import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'learning_activity.freezed.dart';
part 'learning_activity.g.dart';

// Base class for all learning activities
@freezed
class LearningActivity with _$LearningActivity {
  const factory LearningActivity({
    required String id,
    required String title,
    required String type, // 'read', 'quiz', 'flashcard', 'discussion', etc.
    required String chapterId,
    String? description,
    String? content,
    @Default({}) Map<String, dynamic> metadata,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _LearningActivity;

  factory LearningActivity.fromJson(Map<String, dynamic> json) =>
      _$LearningActivityFromJson(json);
}

// Extension methods for activity-specific functionality
extension LearningActivityX on LearningActivity {
  T? as<T>() {
    switch (T) {
      case QuizActivity:
        return metadata['quizData'] != null 
            ? QuizActivity.fromJson(metadata['quizData'] as Map<String, dynamic>) as T
            : null;
      case FlashcardActivity:
        return metadata['flashcardData'] != null
            ? FlashcardActivity.fromJson(metadata['flashcardData'] as Map<String, dynamic>) as T
            : null;
      case DiscussionActivity:
        return metadata['discussionData'] != null
            ? DiscussionActivity.fromJson(metadata['discussionData'] as Map<String, dynamic>) as T
            : null;
      default:
        return null;
    }
  }

  bool get supportsInlineEditing => type == 'read' || type == 'discussion';
}

// AI-powered learning activities
@freezed
class QuizActivity with _$QuizActivity {
  const factory QuizActivity({
    required List<QuizQuestion> questions,
    @Default(true) bool showAnswers,
    @Default(true) bool shuffleQuestions,
    @Default(true) bool shuffleOptions,
    @Default(70) int passingScore,
    String? instructions,
    @Default(false) bool isAdaptive,
    Map<String, dynamic>? aiMetadata,
  }) = _QuizActivity;

  factory QuizActivity.fromJson(Map<String, dynamic> json) =>
      _$QuizActivityFromJson(json);
}

@freezed
class FlashcardActivity with _$FlashcardActivity {
  const factory FlashcardActivity({
    required List<Flashcard> cards,
    @Default(true) bool sequential,
    @Default(true) bool revealAll,
    @Default(3) int repetitions,
    @Default(0.3) double easyMultiplier,
    @Default(1.0) double mediumMultiplier,
    @Default(2.5) double hardMultiplier,
    String? instructions,
    @Default(false) bool isAdaptive,
    Map<String, dynamic>? aiMetadata,
  }) = _FlashcardActivity;

  factory FlashcardActivity.fromJson(Map<String, dynamic> json) =>
      _$FlashcardActivityFromJson(json);
}

@freezed
class DiscussionActivity with _$DiscussionActivity {
  const factory DiscussionActivity({
    required String prompt,
    @Default([]) List<String> discussionPoints,
    @Default(true) bool allowModeration,
    @Default(false) bool aiAssisted,
    String? instructions,
    Map<String, dynamic>? aiMetadata,
  }) = _DiscussionActivity;

  factory DiscussionActivity.fromJson(Map<String, dynamic> json) =>
      _$DiscussionActivityFromJson(json);
}

@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    required String question,
    required String type, // 'multiple_choice', 'true_false', 'fill_blank', 'essay'
    List<String>? options,
    List<String>? correctAnswers,
    String? explanation,
    int? points,
    @Default([]) List<String> tags,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}

@freezed
class Flashcard with _$Flashcard {
  const factory Flashcard({
    required String id,
    required String front,
    required String back,
    String? hint,
    @Default([]) List<String> tags,
    int? interval, // spaced repetition
    int? repetitions,
    double? easeFactor,
    DateTime? nextReview,
    bool? isLearned,
  }) = _Flashcard;

  factory Flashcard.fromJson(Map<String, dynamic> json) =>
      _$FlashcardFromJson(json);
}

@freezed
class DiscussionPrompt with _$DiscussionPrompt {
  const factory DiscussionPrompt({
    required String prompt,
    @Default('') String originalQuestion,
    @Default([]) List<String> keyPoints,
    @Default('') String reflectionGuidance,
    Map<String, dynamic>? context,
  }) = _DiscussionPrompt;

  factory DiscussionPrompt.fromJson(Map<String, dynamic> json) =>
      _$DiscussionPromptFromJson(json);
}

@freezed
class LearningProgress with _$LearningProgress {
  const factory LearningProgress({
    required String userId,
    required String courseId,
    String? currentChapterId,
    String? currentActivityId,
    @Default(0) double overallProgress,
    @Default({}) Map<String, double> chapterProgress,
    @Default({}) Map<String, double> activityProgress,
    @Default([]) List<String> completedActivities,
    DateTime? lastAccessed,
    @Default(0) int streakDays,
    Map<String, dynamic>? extraData,
  }) = _LearningProgress;

  factory LearningProgress.fromJson(Map<String, dynamic> json) =>
      _$LearningProgressFromJson(json);
}
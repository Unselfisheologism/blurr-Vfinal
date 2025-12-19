import 'dart:convert';

import 'document_item.dart';

/// LearnHouse-inspired concept: a learning trail is a sequence of study activities
/// (summary → study guide → quiz → flashcards → etc.) that can be run step-by-step.
///
/// Trails are persisted locally and can span multiple documents.
abstract class LearningActivityType {
  static const String summary = LearningContentType.summary;
  static const String studyGuide = LearningContentType.studyGuide;
  static const String quiz = LearningContentType.quiz;
  static const String flashcards = LearningContentType.flashcards;
  static const String audioOverview = LearningContentType.audioOverview;
  static const String infographic = LearningContentType.infographic;

  /// A trail step that sends a pre-filled question into the document-scoped chat.
  static const String chatQuestion = 'chat_question';

  static const List<String> all = [
    summary,
    studyGuide,
    quiz,
    flashcards,
    audioOverview,
    infographic,
    chatQuestion,
  ];
}

class LearningTrailStep {
  final String id;
  final String title;
  final String activityType;

  /// The document this step operates on.
  final String documentId;

  /// Only used for [LearningActivityType.chatQuestion].
  final String? chatPrompt;

  const LearningTrailStep({
    required this.id,
    required this.title,
    required this.activityType,
    required this.documentId,
    this.chatPrompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'activityType': activityType,
      'documentId': documentId,
      'chatPrompt': chatPrompt,
    };
  }

  factory LearningTrailStep.fromJson(Map<String, dynamic> json) {
    return LearningTrailStep(
      id: (json['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: (json['title'] as String?) ?? 'Step',
      activityType: (json['activityType'] as String?) ?? LearningActivityType.summary,
      documentId: (json['documentId'] as String?) ?? '',
      chatPrompt: json['chatPrompt'] as String?,
    );
  }
}

class LearningTrail {
  final String id;
  final String title;
  final List<LearningTrailStep> steps;

  final int currentStepIndex;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastRunAt;

  const LearningTrail({
    required this.id,
    required this.title,
    required this.steps,
    required this.currentStepIndex,
    required this.createdAt,
    required this.updatedAt,
    this.lastRunAt,
  });

  LearningTrail copyWith({
    String? title,
    List<LearningTrailStep>? steps,
    int? currentStepIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastRunAt,
  }) {
    return LearningTrail(
      id: id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastRunAt: lastRunAt ?? this.lastRunAt,
    );
  }

  LearningTrailStep? get nextStep {
    if (steps.isEmpty) return null;
    if (currentStepIndex < 0) return steps.first;
    if (currentStepIndex >= steps.length) return null;
    return steps[currentStepIndex];
  }

  bool get isComplete => steps.isNotEmpty && currentStepIndex >= steps.length;

  double get progress {
    if (steps.isEmpty) return 0;
    return (currentStepIndex.clamp(0, steps.length) / steps.length);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'steps': steps.map((s) => s.toJson()).toList(),
      'currentStepIndex': currentStepIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastRunAt': lastRunAt?.toIso8601String(),
    };
  }

  factory LearningTrail.fromJson(Map<String, dynamic> json) {
    return LearningTrail(
      id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: (json['title'] as String?) ?? 'Trail',
      steps: (json['steps'] as List?)
              ?.whereType<Map>()
              .map((e) => LearningTrailStep.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      currentStepIndex: (json['currentStepIndex'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      lastRunAt: DateTime.tryParse(json['lastRunAt'] as String? ?? ''),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static LearningTrail? tryFromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) return null;
      return LearningTrail.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}

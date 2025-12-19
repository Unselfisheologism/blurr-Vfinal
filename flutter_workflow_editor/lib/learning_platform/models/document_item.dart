import 'package:json_annotation/json_annotation.dart';

part 'document_item.g.dart';

/// Document item model for Learning Platform
/// Represents uploaded documents with processing status and metadata
@JsonSerializable()
class DocumentItem {
  final String id;
  final String name;
  final String filePath;
  final String content;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DocumentStatus status;
  final String? summary;
  final List<String>? keyPoints;
  final List<Flashcard>? flashcards;
  final List<QuizQuestion>? quizQuestions;
  final AudioOverview? audioOverview;
  final List<StudyGuide>? studyGuides;
  final List<Note>? notes;
  final List<String> tags;
  final double progress;
  final bool isFavorite;

  const DocumentItem({
    required this.id,
    required this.name,
    required this.filePath,
    required this.content,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.summary,
    this.keyPoints,
    this.flashcards,
    this.quizQuestions,
    this.audioOverview,
    this.studyGuides,
    this.notes,
    this.tags = const [],
    this.progress = 0.0,
    this.isFavorite = false,
  });

  /// Create empty document item
  factory DocumentItem.empty() {
    return DocumentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      filePath: '',
      content: '',
      fileType: 'unknown',
      fileSize: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: DocumentStatus.uploaded,
    );
  }

  /// Create from JSON
  factory DocumentItem.fromJson(Map<String, dynamic> json) =>
      _$DocumentItemFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$DocumentItemToJson(this);

  /// Copy with updated fields
  DocumentItem copyWith({
    String? id,
    String? name,
    String? filePath,
    String? content,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
    DateTime? updatedAt,
    DocumentStatus? status,
    String? summary,
    List<String>? keyPoints,
    List<Flashcard>? flashcards,
    List<QuizQuestion>? quizQuestions,
    AudioOverview? audioOverview,
    List<StudyGuide>? studyGuides,
    List<Note>? notes,
    List<String>? tags,
    double? progress,
    bool? isFavorite,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      flashcards: flashcards ?? this.flashcards,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      audioOverview: audioOverview ?? this.audioOverview,
      studyGuides: studyGuides ?? this.studyGuides,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Document processing status
enum DocumentStatus {
  uploaded,
  processing,
  processed,
  generatingSummary,
  generatingQuiz,
  generatingAudio,
  error,
}

/// Flashcard model
@JsonSerializable()
class Flashcard {
  final String id;
  final String front;
  final String back;
  final String difficulty;
  final DateTime createdAt;
  final bool isLearned;

  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.difficulty = 'medium',
    required this.createdAt,
    this.isLearned = false,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) =>
      _$FlashcardFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardToJson(this);

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    String? difficulty,
    DateTime? createdAt,
    bool? isLearned,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      isLearned: isLearned ?? this.isLearned,
    );
  }
}

/// Quiz question model
@JsonSerializable()
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String type; // multiple_choice, fill_blank, true_false
  final DateTime createdAt;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.type = 'multiple_choice',
    required this.createdAt,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

/// Audio overview model
@JsonSerializable()
class AudioOverview {
  final String id;
  final String title;
  final String filePath;
  final int duration;
  final double playbackSpeed;
  final DateTime createdAt;

  const AudioOverview({
    required this.id,
    required this.title,
    required this.filePath,
    required this.duration,
    this.playbackSpeed = 1.0,
    required this.createdAt,
  });

  factory AudioOverview.fromJson(Map<String, dynamic> json) =>
      _$AudioOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$AudioOverviewToJson(this);
}

/// Study guide model
@JsonSerializable()
class StudyGuide {
  final String id;
  final String title;
  final String content;
  final String type; // chapter, topic, concept
  final List<String> keyTerms;
  final DateTime createdAt;

  const StudyGuide({
    required this.id,
    required this.title,
    required this.content,
    this.type = 'topic',
    required this.keyTerms,
    required this.createdAt,
  });

  factory StudyGuide.fromJson(Map<String, dynamic> json) =>
      _$StudyGuideFromJson(json);

  Map<String, dynamic> toJson() => _$StudyGuideToJson(this);
}

/// Note model
@JsonSerializable()
class Note {
  final String id;
  final String content;
  final String page;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  const Note({
    required this.id,
    required this.content,
    required this.page,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);
}

/// Learning trail model
@JsonSerializable()
class LearningTrail {
  final String id;
  final String name;
  final List<String> documentIds;
  final List<Activity> activities;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double progress;
  final bool isCompleted;

  const LearningTrail({
    required this.id,
    required this.name,
    required this.documentIds,
    required this.activities,
    required this.createdAt,
    required this.updatedAt,
    this.progress = 0.0,
    this.isCompleted = false,
  });

  factory LearningTrail.fromJson(Map<String, dynamic> json) =>
      _$LearningTrailFromJson(json);

  Map<String, dynamic> toJson() => _$LearningTrailToJson(this);
}

/// Learning activity model
@JsonSerializable()
class Activity {
  final String id;
  final String type; // read, quiz, flashcards, audio
  final String title;
  final Map<String, dynamic> data;
  final bool isCompleted;
  final DateTime? completedAt;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.data,
    this.isCompleted = false,
    this.completedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
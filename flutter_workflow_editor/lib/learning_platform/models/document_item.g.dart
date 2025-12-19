import 'package:json_annotation/json_annotation.dart';
import 'document_item.dart';

DocumentItem _$DocumentItemFromJson(Map<String, dynamic> json) => DocumentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      filePath: json['filePath'] as String,
      content: json['content'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => DocumentStatus.uploaded,
      ),
      summary: json['summary'] as String?,
      keyPoints: (json['keyPoints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      flashcards: (json['flashcards'] as List<dynamic>?)
          ?.map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
          .toList(),
      quizQuestions: (json['quizQuestions'] as List<dynamic>?)
          ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      audioOverview: json['audioOverview'] == null
          ? null
          : AudioOverview.fromJson(json['audioOverview'] as Map<String, dynamic>),
      studyGuides: (json['studyGuides'] as List<dynamic>?)
          ?.map((e) => StudyGuide.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      progress: (json['progress'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool,
    );

Map<String, dynamic> _$DocumentItemToJson(DocumentItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'filePath': instance.filePath,
      'content': instance.content,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'status': instance.status.toString().split('.').last,
      'summary': instance.summary,
      'keyPoints': instance.keyPoints,
      'flashcards': instance.flashcards,
      'quizQuestions': instance.quizQuestions,
      'audioOverview': instance.audioOverview,
      'studyGuides': instance.studyGuides,
      'notes': instance.notes,
      'tags': instance.tags,
      'progress': instance.progress,
      'isFavorite': instance.isFavorite,
    };

Flashcard _$FlashcardFromJson(Map<String, dynamic> json) => Flashcard(
      id: json['id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      difficulty: json['difficulty'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLearned: json['isLearned'] as bool? ?? false,
    );

Map<String, dynamic> _$FlashcardToJson(Flashcard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'front': instance.front,
      'back': instance.back,
      'difficulty': instance.difficulty,
      'createdAt': instance.createdAt.toIso8601String(),
      'isLearned': instance.isLearned,
    };

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) =>
    QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      type: json['type'] as String? ?? 'multiple_choice',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$QuizQuestionToJson(QuizQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AudioOverview _$AudioOverviewFromJson(Map<String, dynamic> json) =>
    AudioOverview(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      duration: json['duration'] as int,
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AudioOverviewToJson(AudioOverview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'filePath': instance.filePath,
      'duration': instance.duration,
      'playbackSpeed': instance.playbackSpeed,
      'createdAt': instance.createdAt.toIso8601String(),
    };

StudyGuide _$StudyGuideFromJson(Map<String, dynamic> json) => StudyGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'topic',
      keyTerms: (json['keyTerms'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StudyGuideToJson(StudyGuide instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'type': instance.type,
      'keyTerms': instance.keyTerms,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String,
      content: json['content'] as String,
      page: json['page'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'page': instance.page,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
    };

LearningTrail _$LearningTrailFromJson(Map<String, dynamic> json) =>
    LearningTrail(
      id: json['id'] as String,
      name: json['name'] as String,
      documentIds:
          (json['documentIds'] as List<dynamic>).map((e) => e as String).toList(),
      activities: (json['activities'] as List<dynamic>)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      progress: (json['progress'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool,
    );

Map<String, dynamic> _$LearningTrailToJson(LearningTrail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'documentIds': instance.documentIds,
      'activities': instance.activities,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
    };

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      data: json['data'] as Map<String, dynamic>,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'data': instance.data,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
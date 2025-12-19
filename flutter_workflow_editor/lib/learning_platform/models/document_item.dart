import 'dart:convert';

/// High-level content type used in the Learning Platform.
///
/// Keeping this as a String enum allows for forward-compatible persisted documents.
abstract class LearningContentType {
  static const String summary = 'summary';
  static const String studyGuide = 'study_guide';
  static const String quiz = 'quiz';
  static const String flashcards = 'flashcards';
  static const String audioOverview = 'audio_overview';
  static const String infographic = 'infographic';
  static const String chat = 'chat';
}

abstract class LearningDocumentSourceType {
  static const String file = 'file';
  static const String note = 'note';
}

class DocumentItem {
  final String id;
  final String title;
  final String sourceType;
  final String? fileName;
  final String? fileExtension;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Extracted plain text content.
  final String content;

  final String? summaryMarkdown;
  final String? studyGuideMarkdown;
  final List<QuizQuestion> quizQuestions;
  final List<Flashcard> flashcards;

  /// Absolute path to synthesized audio (typically MP3) stored in app cache.
  final String? audioFilePath;

  /// Absolute path to generated infographic (PNG/JPG/SVG).
  final String? infographicFilePath;

  final List<ChatMessage> chatHistory;

  const DocumentItem({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.fileName,
    this.fileExtension,
    this.summaryMarkdown,
    this.studyGuideMarkdown,
    this.quizQuestions = const [],
    this.flashcards = const [],
    this.audioFilePath,
    this.infographicFilePath,
    this.chatHistory = const [],
  });

  factory DocumentItem.emptyNote({String? title}) {
    final now = DateTime.now();
    return DocumentItem(
      id: now.millisecondsSinceEpoch.toString(),
      title: title?.trim().isNotEmpty == true ? title!.trim() : 'Untitled Note',
      sourceType: LearningDocumentSourceType.note,
      content: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  DocumentItem copyWith({
    String? title,
    String? sourceType,
    String? fileName,
    String? fileExtension,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? summaryMarkdown,
    String? studyGuideMarkdown,
    List<QuizQuestion>? quizQuestions,
    List<Flashcard>? flashcards,
    String? audioFilePath,
    String? infographicFilePath,
    List<ChatMessage>? chatHistory,
  }) {
    return DocumentItem(
      id: id,
      title: title ?? this.title,
      sourceType: sourceType ?? this.sourceType,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summaryMarkdown: summaryMarkdown ?? this.summaryMarkdown,
      studyGuideMarkdown: studyGuideMarkdown ?? this.studyGuideMarkdown,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      flashcards: flashcards ?? this.flashcards,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      infographicFilePath: infographicFilePath ?? this.infographicFilePath,
      chatHistory: chatHistory ?? this.chatHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sourceType': sourceType,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'content': content,
      'summaryMarkdown': summaryMarkdown,
      'studyGuideMarkdown': studyGuideMarkdown,
      'quizQuestions': quizQuestions.map((q) => q.toJson()).toList(),
      'flashcards': flashcards.map((c) => c.toJson()).toList(),
      'audioFilePath': audioFilePath,
      'infographicFilePath': infographicFilePath,
      'chatHistory': chatHistory.map((m) => m.toJson()).toList(),
    };
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Untitled',
      sourceType: (json['sourceType'] as String?) ?? LearningDocumentSourceType.file,
      fileName: json['fileName'] as String?,
      fileExtension: json['fileExtension'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      content: (json['content'] as String?) ?? '',
      summaryMarkdown: json['summaryMarkdown'] as String?,
      studyGuideMarkdown: json['studyGuideMarkdown'] as String?,
      quizQuestions: (json['quizQuestions'] as List?)
              ?.whereType<Map>()
              .map((e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      flashcards: (json['flashcards'] as List?)
              ?.whereType<Map>()
              .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      audioFilePath: json['audioFilePath'] as String?,
      infographicFilePath: json['infographicFilePath'] as String?,
      chatHistory: (json['chatHistory'] as List?)
              ?.whereType<Map>()
              .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static DocumentItem? tryFromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) return null;
      return DocumentItem.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  int get wordCount {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  int get charCount => content.length;
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> choices;
  final int answerIndex;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.choices,
    required this.answerIndex,
    this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'choices': choices,
      'answerIndex': answerIndex,
      'explanation': explanation,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: (json['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      question: (json['question'] as String?) ?? '',
      choices: (json['choices'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      answerIndex: (json['answerIndex'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String?,
    );
  }
}

class Flashcard {
  final String id;
  final String front;
  final String back;

  /// 1 (easy) .. 3 (hard)
  final int difficulty;

  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.difficulty = 2,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'difficulty': difficulty,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: (json['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      front: (json['front'] as String?) ?? '',
      back: (json['back'] as String?) ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 2,
    );
  }
}

class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      role: (json['role'] as String?) ?? 'assistant',
      content: (json['content'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

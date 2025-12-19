import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../models/document_item.dart';
import '../services/learning_platform_service.dart';
import '../services/learning_storage_service.dart';

class LearningPlatformState extends ChangeNotifier {
  final LearningStorageService _storage;
  final LearningPlatformService _platform;

  LearningPlatformState({
    LearningStorageService? storage,
    LearningPlatformService? platform,
  })  : _storage = storage ?? LearningStorageService(),
        _platform = platform ?? LearningPlatformService();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  bool _isProUser = false;
  bool get isProUser => _isProUser;

  String? _lastError;
  String? get lastError => _lastError;

  List<DocumentItem> _documents = const [];
  List<DocumentItem> get documents => _documents;

  DocumentItem? _selected;
  DocumentItem? get selected => _selected;

  Future<void> initialize() async {
    if (_initialized) return;

    _setBusy(true);
    try {
      await _storage.initialize();
      _isProUser = await _platform.checkProAccess();
      await refreshDocuments();
      _initialized = true;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshDocuments() async {
    final docs = await _storage.listDocuments();
    _documents = docs;

    if (_selected != null) {
      final stillExists = docs.any((d) => d.id == _selected!.id);
      if (!stillExists) {
        _selected = null;
      } else {
        _selected = docs.firstWhere((d) => d.id == _selected!.id);
      }
    }

    notifyListeners();
  }

  void selectDocument(DocumentItem? doc) {
    _selected = doc;
    notifyListeners();
  }

  Future<void> upsert(DocumentItem doc) async {
    await _storage.saveDocument(doc);
    await refreshDocuments();

    if (_selected?.id == doc.id) {
      _selected = doc;
      notifyListeners();
    }
  }

  Future<void> delete(String documentId) async {
    await _storage.deleteDocument(documentId);
    if (_selected?.id == documentId) {
      _selected = null;
    }
    await refreshDocuments();
  }

  Future<DocumentItem> createNote({required String title, required String content}) async {
    _enforceLibraryLimit();

    final now = DateTime.now();
    final doc = DocumentItem(
      id: now.millisecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Untitled Note' : title.trim(),
      sourceType: LearningDocumentSourceType.note,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    await upsert(doc);
    return doc;
  }

  Future<DocumentItem> createFromExtractedText({
    required String title,
    required String content,
    String? fileName,
    String? fileExtension,
  }) async {
    _enforceLibraryLimit();

    final now = DateTime.now();
    final doc = DocumentItem(
      id: now.millisecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      sourceType: LearningDocumentSourceType.file,
      fileName: fileName,
      fileExtension: fileExtension,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    await upsert(doc);
    return doc;
  }

  Future<DocumentItem> importFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    _setBusy(true);
    try {
      _enforceLibraryLimit();

      final extracted = await _platform.extractDocumentText(
        bytes: bytes,
        fileName: fileName,
      );

      final normalized = extracted.trim();
      if (normalized.isEmpty) {
        throw StateError('No text could be extracted from "$fileName".');
      }

      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : null;
      final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');

      final doc = await createFromExtractedText(
        title: title,
        content: normalized,
        fileName: fileName,
        fileExtension: ext,
      );

      selectDocument(doc);
      return doc;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> generateSummary() async {
    final doc = _requireSelectedWithContent();
    _setBusy(true);
    try {
      _enforceLongDocProGate(doc);
      final summary = await _platform.generateSummary(documentText: doc.content);

      final updated = doc.copyWith(
        summaryMarkdown: summary.trim().isEmpty ? doc.summaryMarkdown : summary.trim(),
        updatedAt: DateTime.now(),
      );
      await upsert(updated);
      selectDocument(updated);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> generateStudyGuide() async {
    final doc = _requireSelectedWithContent();
    _setBusy(true);
    try {
      _enforceLongDocProGate(doc);
      final guide = await _platform.generateStudyGuide(documentText: doc.content);

      final updated = doc.copyWith(
        studyGuideMarkdown: guide.trim().isEmpty ? doc.studyGuideMarkdown : guide.trim(),
        updatedAt: DateTime.now(),
      );
      await upsert(updated);
      selectDocument(updated);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> generateQuiz({int questionCount = 8}) async {
    final doc = _requireSelectedWithContent();
    _setBusy(true);
    try {
      _enforceLongDocProGate(doc);
      final raw = await _platform.generateQuiz(
        documentText: doc.content,
        questionCount: questionCount,
      );

      final questions = _tryParseQuizQuestions(raw);
      final updated = doc.copyWith(
        quizQuestions: questions.isEmpty ? doc.quizQuestions : questions,
        updatedAt: DateTime.now(),
      );
      await upsert(updated);
      selectDocument(updated);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> generateFlashcards({int cardCount = 12}) async {
    final doc = _requireSelectedWithContent();
    _setBusy(true);
    try {
      _enforceLongDocProGate(doc);
      final raw = await _platform.generateFlashcards(
        documentText: doc.content,
        cardCount: cardCount,
      );

      final cards = _tryParseFlashcards(raw);
      final updated = doc.copyWith(
        flashcards: cards.isEmpty ? doc.flashcards : cards,
        updatedAt: DateTime.now(),
      );
      await upsert(updated);
      selectDocument(updated);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> generateAudioOverview({String? preferredText}) async {
    final doc = _requireSelectedWithContent();
    if (!_isProUser) {
      throw StateError('Audio overviews are a Pro feature.');
    }

    _setBusy(true);
    try {
      final text = (preferredText?.trim().isNotEmpty == true)
          ? preferredText!.trim()
          : (doc.summaryMarkdown?.trim().isNotEmpty == true)
              ? doc.summaryMarkdown!.trim()
              : doc.content;

      final audioPath = await _platform.synthesizeAudioOverview(text: text);
      if (audioPath.trim().isEmpty) return;

      final updated = doc.copyWith(
        audioFilePath: audioPath,
        updatedAt: DateTime.now(),
      );

      await upsert(updated);
      selectDocument(updated);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> generateInfographic({required String topic, String style = 'professional'}) async {
    final doc = _requireSelected();
    if (!_isProUser) {
      throw StateError('Infographics are a Pro feature.');
    }

    _setBusy(true);
    try {
      final path = await _platform.generateInfographic(topic: topic, style: style);
      if (path.trim().isEmpty) return;

      final updated = doc.copyWith(
        infographicFilePath: path,
        updatedAt: DateTime.now(),
      );

      await upsert(updated);
      selectDocument(updated);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendChatMessage(String message) async {
    final doc = _requireSelectedWithContent();
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    _setBusy(true);
    try {
      _enforceLongDocProGate(doc);

      final userMsg = ChatMessage.user(trimmed);
      final history = [...doc.chatHistory, userMsg];

      final answer = await _platform.askQuestion(
        documentText: doc.content,
        question: trimmed,
        history: history,
      );

      final assistantMsg = ChatMessage.assistant(
        answer.trim().isEmpty ? 'No answer.' : answer.trim(),
      );

      final updated = doc.copyWith(
        chatHistory: [...history, assistantMsg],
        updatedAt: DateTime.now(),
      );

      await upsert(updated);
      selectDocument(updated);
    } finally {
      _setBusy(false);
    }
  }

  DocumentItem _requireSelected() {
    final doc = _selected;
    if (doc == null) {
      throw StateError('Select a document first.');
    }
    return doc;
  }

  DocumentItem _requireSelectedWithContent() {
    final doc = _requireSelected();
    if (doc.content.trim().isEmpty) {
      throw StateError('This document has no text content.');
    }
    return doc;
  }

  void _enforceLibraryLimit() {
    const freeDocumentLimit = 5;
    if (_isProUser) return;
    if (_documents.length >= freeDocumentLimit) {
      throw StateError('Free tier supports up to $freeDocumentLimit documents. Upgrade to Pro for unlimited.');
    }
  }

  void _enforceLongDocProGate(DocumentItem doc) {
    const freeCharLimit = 8000;
    if (_isProUser) return;
    if (doc.charCount > freeCharLimit) {
      throw StateError('Long documents require Pro (>${freeCharLimit} characters).');
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  List<QuizQuestion> _tryParseQuizQuestions(String raw) {
    final jsonString = _extractLikelyJson(raw);
    if (jsonString == null) return const [];

    try {
      final decoded = jsonDecode(jsonString);
      final obj = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
      final list = obj?['questions'];
      if (list is! List) return const [];

      return list
          .whereType<Map>()
          .map((e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e)))
          .where((q) => q.question.trim().isNotEmpty && q.choices.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<Flashcard> _tryParseFlashcards(String raw) {
    final jsonString = _extractLikelyJson(raw);
    if (jsonString == null) return const [];

    try {
      final decoded = jsonDecode(jsonString);
      final obj = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
      final list = obj?['cards'];
      if (list is! List) return const [];

      return list
          .whereType<Map>()
          .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.front.trim().isNotEmpty && c.back.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  String? _extractLikelyJson(String raw) {
    var s = raw.trim();

    if (s.startsWith('```')) {
      final firstNewline = s.indexOf('\n');
      if (firstNewline != -1) {
        s = s.substring(firstNewline + 1);
      }
      if (s.endsWith('```')) {
        s = s.substring(0, s.length - 3);
      }
      s = s.trim();
    }

    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;

    return s.substring(start, end + 1);
  }
}

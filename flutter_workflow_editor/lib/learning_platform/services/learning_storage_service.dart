import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/document_item.dart';

/// Local storage service for Learning Platform
/// 
/// Handles persistent storage of documents, learning trails, and study progress
/// using Hive for fast local database operations.
class LearningStorageService {
  static const String _documentsBox = 'learning_documents';
  static const String _trailsBox = 'learning_trails';
  static const String _settingsBox = 'learning_settings';

  Box<dynamic>? _documentsBoxInstance;
  Box<dynamic>? _trailsBoxInstance;
  Box<dynamic>? _settingsBoxInstance;

  /// Initialize Hive storage
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DocumentItemAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DocumentStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(FlashcardAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(QuizQuestionAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AudioOverviewAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(StudyGuideAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(NoteAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(LearningTrailAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(ActivityAdapter());
      }

      _documentsBoxInstance = await Hive.openBox(_documentsBox);
      _trailsBoxInstance = await Hive.openBox(_trailsBox);
      _settingsBoxInstance = await Hive.openBox(_settingsBox);
    } catch (e) {
      throw Exception('Failed to initialize storage: $e');
    }
  }

  /// Get all documents
  List<DocumentItem> getAllDocuments() {
    final box = _documentsBoxInstance;
    if (box == null) return [];
    
    return box.values
        .whereType<DocumentItem>()
        .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get document by ID
  DocumentItem? getDocument(String id) {
    final box = _documentsBoxInstance;
    return box?.get(id) as DocumentItem?;
  }

  /// Save document
  Future<void> saveDocument(DocumentItem document) async {
    final box = _documentsBoxInstance;
    if (box == null) throw Exception('Storage not initialized');
    
    await box.put(document.id, document);
  }

  /// Delete document
  Future<void> deleteDocument(String id) async {
    final box = _documentsBoxInstance;
    if (box == null) throw Exception('Storage not initialized');
    
    await box.delete(id);
  }

  /// Search documents by name or content
  List<DocumentItem> searchDocuments(String query) {
    final documents = getAllDocuments();
    final lowerQuery = query.toLowerCase();
    
    return documents.where((doc) => 
      doc.name.toLowerCase().contains(lowerQuery) ||
      doc.content.toLowerCase().contains(lowerQuery) ||
      doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  /// Get documents by status
  List<DocumentItem> getDocumentsByStatus(DocumentStatus status) {
    return getAllDocuments().where((doc) => doc.status == status).toList();
  }

  /// Get favorite documents
  List<DocumentItem> getFavoriteDocuments() {
    return getAllDocuments().where((doc) => doc.isFavorite).toList();
  }

  /// Update document progress
  Future<void> updateDocumentProgress(String documentId, double progress) async {
    final document = getDocument(documentId);
    if (document != null) {
      final updatedDocument = document.copyWith(
        progress: progress.clamp(0.0, 1.0),
        updatedAt: DateTime.now(),
      );
      await saveDocument(updatedDocument);
    }
  }

  /// Add note to document
  Future<void> addNoteToDocument(String documentId, Note note) async {
    final document = getDocument(documentId);
    if (document != null) {
      final currentNotes = document.notes ?? [];
      final updatedNotes = [...currentNotes, note];
      
      final updatedDocument = document.copyWith(
        notes: updatedNotes,
        updatedAt: DateTime.now(),
      );
      await saveDocument(updatedDocument);
    }
  }

  /// Update flashcard learning status
  Future<void> updateFlashcardStatus(String documentId, String flashcardId, bool isLearned) async {
    final document = getDocument(documentId);
    if (document != null && document.flashcards != null) {
      final updatedFlashcards = document.flashcards!.map((card) {
        return card.id == flashcardId ? card.copyWith(isLearned: isLearned) : card;
      }).toList();
      
      final updatedDocument = document.copyWith(
        flashcards: updatedFlashcards,
        updatedAt: DateTime.now(),
      );
      await saveDocument(updatedDocument);
    }
  }

  /// Get learning statistics
  LearningStats getLearningStats() {
    final documents = getAllDocuments();
    
    final totalDocuments = documents.length;
    final completedDocuments = documents.where((doc) => doc.progress >= 1.0).length;
    final totalFlashcards = documents.fold<int>(
      0, 
      (sum, doc) => sum + (doc.flashcards?.length ?? 0)
    );
    final learnedFlashcards = documents.fold<int>(
      0,
      (sum, doc) => sum + (doc.flashcards?.where((card) => card.isLearned).length ?? 0)
    );
    final totalQuizzes = documents.fold<int>(
      0,
      (sum, doc) => sum + (doc.quizQuestions?.length ?? 0)
    );

    return LearningStats(
      totalDocuments: totalDocuments,
      completedDocuments: completedDocuments,
      totalFlashcards: totalFlashcards,
      learnedFlashcards: learnedFlashcards,
      totalQuizzes: totalQuizzes,
      overallProgress: totalDocuments > 0 ? 
        documents.fold<double>(0, (sum, doc) => sum + doc.progress) / totalDocuments : 0.0,
    );
  }

  // ==================== Learning Trails ====================

  /// Get all learning trails
  List<LearningTrail> getAllTrails() {
    final box = _trailsBoxInstance;
    if (box == null) return [];
    
    return box.values
        .whereType<LearningTrail>()
        .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get trail by ID
  LearningTrail? getTrail(String id) {
    final box = _trailsBoxInstance;
    return box?.get(id) as LearningTrail?;
  }

  /// Save learning trail
  Future<void> saveTrail(LearningTrail trail) async {
    final box = _trailsBoxInstance;
    if (box == null) throw Exception('Storage not initialized');
    
    await box.put(trail.id, trail);
  }

  /// Delete learning trail
  Future<void> deleteTrail(String id) async {
    final box = _trailsBoxInstance;
    if (box == null) throw Exception('Storage not initialized');
    
    await box.delete(id);
  }

  /// Complete activity in trail
  Future<void> completeActivity(String trailId, String activityId) async {
    final trail = getTrail(trailId);
    if (trail != null) {
      final updatedActivities = trail.activities.map((activity) {
        if (activity.id == activityId) {
          return activity.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return activity;
      }).toList();

      final completedCount = updatedActivities.where((a) => a.isCompleted).length;
      final progress = updatedActivities.isNotEmpty ? 
        completedCount / updatedActivities.length : 0.0;

      final updatedTrail = trail.copyWith(
        activities: updatedActivities,
        progress: progress,
        isCompleted: progress >= 1.0,
        updatedAt: DateTime.now(),
      );
      
      await saveTrail(updatedTrail);
    }
  }

  // ==================== Settings ====================

  /// Get app settings
  Map<String, dynamic> getSettings() {
    final box = _settingsBoxInstance;
    if (box == null) return {};
    
    return Map<String, dynamic>.from(box.toMap());
  }

  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    final box = _settingsBoxInstance;
    if (box == null) throw Exception('Storage not initialized');
    
    await box.put(key, value);
  }

  /// Get setting value
  T? getSetting<T>(String key, [T? defaultValue]) {
    final box = _settingsBoxInstance;
    if (box == null) return defaultValue;
    
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await Future.wait([
      _documentsBoxInstance?.clear() ?? Future.value(),
      _trailsBoxInstance?.clear() ?? Future.value(),
      _settingsBoxInstance?.clear() ?? Future.value(),
    ]);
  }

  /// Export data as JSON
  Map<String, dynamic> exportData() {
    return {
      'documents': getAllDocuments().map((doc) => doc.toJson()).toList(),
      'trails': getAllTrails().map((trail) => trail.toJson()).toList(),
      'settings': getSettings(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    // Import documents
    final documentsData = data['documents'] as List?;
    if (documentsData != null) {
      for (final docJson in documentsData) {
        try {
          final document = DocumentItem.fromJson(Map<String, dynamic>.from(docJson));
          await saveDocument(document);
        } catch (e) {
          // Skip invalid documents
          continue;
        }
      }
    }

    // Import trails
    final trailsData = data['trails'] as List?;
    if (trailsData != null) {
      for (final trailJson in trailsData) {
        try {
          final trail = LearningTrail.fromJson(Map<String, dynamic>.from(trailJson));
          await saveTrail(trail);
        } catch (e) {
          // Skip invalid trails
          continue;
        }
      }
    }

    // Import settings
    final settingsData = data['settings'] as Map?;
    if (settingsData != null) {
      for (final entry in settingsData.entries) {
        await saveSetting(entry.key, entry.value);
      }
    }
  }

  /// Close storage boxes
  Future<void> close() async {
    await Future.wait([
      _documentsBoxInstance?.close() ?? Future.value(),
      _trailsBoxInstance?.close() ?? Future.value(),
      _settingsBoxInstance?.close() ?? Future.value(),
    ]);
  }
}

/// Learning statistics model
class LearningStats {
  final int totalDocuments;
  final int completedDocuments;
  final int totalFlashcards;
  final int learnedFlashcards;
  final int totalQuizzes;
  final double overallProgress;

  const LearningStats({
    required this.totalDocuments,
    required this.completedDocuments,
    required this.totalFlashcards,
    required this.learnedFlashcards,
    required this.totalQuizzes,
    required this.overallProgress,
  });

  double get completionRate => totalDocuments > 0 ? 
    completedDocuments / totalDocuments : 0.0;

  double get flashcardMasteryRate => totalFlashcards > 0 ? 
    learnedFlashcards / totalFlashcards : 0.0;
}
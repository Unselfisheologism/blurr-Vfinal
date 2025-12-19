import 'package:hive_flutter/hive_flutter.dart';

import '../models/document_item.dart';
import '../models/learning_trail.dart';

/// Local persistence for the Learning Platform.
///
/// Stores each entity as a JSON string (keeps migrations simple and avoids Hive adapters).
class LearningStorageService {
  static const String _documentsBoxName = 'learning_platform_documents';
  static const String _trailsBoxName = 'learning_platform_trails';

  Box<String>? _documentsBox;
  Box<String>? _trailsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _documentsBox = await Hive.openBox<String>(_documentsBoxName);
    _trailsBox = await Hive.openBox<String>(_trailsBoxName);
  }

  void _ensureInitialized() {
    if (_documentsBox == null || _trailsBox == null) {
      throw StateError('LearningStorageService not initialized. Call initialize() first.');
    }
  }

  // Documents

  Future<void> saveDocument(DocumentItem document) async {
    _ensureInitialized();
    await _documentsBox!.put(document.id, document.toJsonString());
  }

  Future<DocumentItem?> loadDocument(String id) async {
    _ensureInitialized();
    final json = _documentsBox!.get(id);
    if (json == null) return null;
    return DocumentItem.tryFromJsonString(json);
  }

  Future<void> deleteDocument(String id) async {
    _ensureInitialized();
    await _documentsBox!.delete(id);
  }

  Future<List<DocumentItem>> listDocuments() async {
    _ensureInitialized();

    final docs = <DocumentItem>[];
    for (final key in _documentsBox!.keys) {
      final json = _documentsBox!.get(key);
      if (json == null) continue;
      final doc = DocumentItem.tryFromJsonString(json);
      if (doc != null) {
        docs.add(doc);
      }
    }

    docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return docs;
  }

  Future<int> documentCount() async {
    _ensureInitialized();
    return _documentsBox!.length;
  }

  // Trails

  Future<void> saveTrail(LearningTrail trail) async {
    _ensureInitialized();
    await _trailsBox!.put(trail.id, trail.toJsonString());
  }

  Future<void> deleteTrail(String id) async {
    _ensureInitialized();
    await _trailsBox!.delete(id);
  }

  Future<List<LearningTrail>> listTrails() async {
    _ensureInitialized();

    final trails = <LearningTrail>[];
    for (final key in _trailsBox!.keys) {
      final json = _trailsBox!.get(key);
      if (json == null) continue;
      final trail = LearningTrail.tryFromJsonString(json);
      if (trail != null) {
        trails.add(trail);
      }
    }

    trails.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return trails;
  }

  Future<int> trailCount() async {
    _ensureInitialized();
    return _trailsBox!.length;
  }

  Future<void> clearAll() async {
    _ensureInitialized();
    await _documentsBox!.clear();
    await _trailsBox!.clear();
  }

  Future<void> close() async {
    await _documentsBox?.close();
    await _trailsBox?.close();
  }
}

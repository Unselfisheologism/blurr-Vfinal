import 'package:hive_flutter/hive_flutter.dart';

import '../models/document_item.dart';

/// Local persistence for the Learning Platform.
///
/// Stores each document as a JSON string (keeps migrations simple and avoids Hive adapters).
class LearningStorageService {
  static const String _boxName = 'learning_platform_documents';

  Box<String>? _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  void _ensureInitialized() {
    if (_box == null) {
      throw StateError('LearningStorageService not initialized. Call initialize() first.');
    }
  }

  Future<void> saveDocument(DocumentItem document) async {
    _ensureInitialized();
    await _box!.put(document.id, document.toJsonString());
  }

  Future<DocumentItem?> loadDocument(String id) async {
    _ensureInitialized();
    final json = _box!.get(id);
    if (json == null) return null;
    return DocumentItem.tryFromJsonString(json);
  }

  Future<void> deleteDocument(String id) async {
    _ensureInitialized();
    await _box!.delete(id);
  }

  Future<List<DocumentItem>> listDocuments() async {
    _ensureInitialized();

    final docs = <DocumentItem>[];
    for (final key in _box!.keys) {
      final json = _box!.get(key);
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
    return _box!.length;
  }

  Future<void> clearAll() async {
    _ensureInitialized();
    await _box!.clear();
  }

  Future<void> close() async {
    await _box?.close();
  }
}

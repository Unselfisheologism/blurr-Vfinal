import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document.dart';

/// Service for managing document persistence
/// 
/// Uses Hive for document storage with automatic syncing.
/// Provides CRUD operations and document listing.
class DocumentService {
  static const String _boxName = 'text_editor_documents';
  static const String _recentDocsKey = 'recent_document_ids';
  static const int _maxRecentDocs = 10;

  Box<String>? _documentsBox;
  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    // Hive is initialized globally in main.dart, so we can directly open boxes
    _documentsBox = await Hive.openBox<String>(_boxName);
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (_documentsBox == null || _prefs == null) {
      throw StateError('DocumentService not initialized. Call initialize() first.');
    }
  }

  /// Save a document
  Future<void> saveDocument(EditorDocument document) async {
    _ensureInitialized();
    
    final json = jsonEncode(document.toJson());
    await _documentsBox!.put(document.id, json);
    
    // Update recent documents list
    await _addToRecentDocuments(document.id);
  }

  /// Load a document by ID
  Future<EditorDocument?> loadDocument(String id) async {
    _ensureInitialized();
    
    final json = _documentsBox!.get(id);
    if (json == null) return null;
    
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return EditorDocument.fromJson(map);
    } catch (e) {
      print('Error loading document $id: $e');
      return null;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    _ensureInitialized();
    
    await _documentsBox!.delete(id);
    await _removeFromRecentDocuments(id);
  }

  /// Get all documents
  Future<List<EditorDocument>> getAllDocuments() async {
    _ensureInitialized();
    
    final documents = <EditorDocument>[];
    
    for (final key in _documentsBox!.keys) {
      final doc = await loadDocument(key as String);
      if (doc != null && !doc.isTemplate) {
        documents.add(doc);
      }
    }
    
    // Sort by updatedAt descending (most recent first)
    documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return documents;
  }

  /// Get recent documents
  Future<List<EditorDocument>> getRecentDocuments() async {
    _ensureInitialized();
    
    final recentIds = _prefs!.getStringList(_recentDocsKey) ?? [];
    final documents = <EditorDocument>[];
    
    for (final id in recentIds) {
      final doc = await loadDocument(id);
      if (doc != null) {
        documents.add(doc);
      }
    }
    
    return documents;
  }

  /// Search documents by title or content
  Future<List<EditorDocument>> searchDocuments(String query) async {
    _ensureInitialized();
    
    if (query.trim().isEmpty) {
      return getAllDocuments();
    }
    
    final allDocs = await getAllDocuments();
    final lowerQuery = query.toLowerCase();
    
    return allDocs.where((doc) {
      final titleMatch = doc.title.toLowerCase().contains(lowerQuery);
      final contentMatch = doc.getPlainText().toLowerCase().contains(lowerQuery);
      final tagMatch = doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      
      return titleMatch || contentMatch || tagMatch;
    }).toList();
  }

  /// Get documents by tag
  Future<List<EditorDocument>> getDocumentsByTag(String tag) async {
    _ensureInitialized();
    
    final allDocs = await getAllDocuments();
    return allDocs.where((doc) => doc.tags.contains(tag)).toList();
  }

  /// Get all unique tags
  Future<List<String>> getAllTags() async {
    _ensureInitialized();
    
    final allDocs = await getAllDocuments();
    final tagsSet = <String>{};
    
    for (final doc in allDocs) {
      tagsSet.addAll(doc.tags);
    }
    
    final tags = tagsSet.toList()..sort();
    return tags;
  }

  /// Duplicate a document
  Future<EditorDocument> duplicateDocument(EditorDocument original) async {
    _ensureInitialized();
    
    final duplicate = EditorDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${original.title} (Copy)',
      content: List.from(original.content),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: List.from(original.tags),
    );
    
    await saveDocument(duplicate);
    return duplicate;
  }

  /// Create document from template
  Future<EditorDocument> createFromTemplate(EditorDocument template) async {
    _ensureInitialized();
    
    final newDoc = EditorDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: template.title.replaceAll('Template', 'Document'),
      content: List.from(template.content),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: template.tags.where((tag) => tag != 'template').toList(),
    );
    
    await saveDocument(newDoc);
    return newDoc;
  }

  /// Export document as JSON
  String exportDocumentAsJson(EditorDocument document) {
    return jsonEncode(document.toJson());
  }

  /// Import document from JSON
  Future<EditorDocument?> importDocumentFromJson(String json) async {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final document = EditorDocument.fromJson(map);
      
      // Generate new ID to avoid conflicts
      final imported = document.copyWith(
        title: '${document.title} (Imported)',
      );
      
      await saveDocument(imported);
      return imported;
    } catch (e) {
      print('Error importing document: $e');
      return null;
    }
  }

  /// Get document count
  Future<int> getDocumentCount() async {
    _ensureInitialized();
    
    final allDocs = await getAllDocuments();
    return allDocs.length;
  }

  /// Check if document limit reached (for Pro gating)
  Future<bool> isDocumentLimitReached(int freeLimit) async {
    final count = await getDocumentCount();
    return count >= freeLimit;
  }

  /// Add document to recent list
  Future<void> _addToRecentDocuments(String id) async {
    final recentIds = _prefs!.getStringList(_recentDocsKey) ?? [];
    
    // Remove if already exists
    recentIds.remove(id);
    
    // Add to front
    recentIds.insert(0, id);
    
    // Keep only max recent docs
    if (recentIds.length > _maxRecentDocs) {
      recentIds.removeRange(_maxRecentDocs, recentIds.length);
    }
    
    await _prefs!.setStringList(_recentDocsKey, recentIds);
  }

  /// Remove document from recent list
  Future<void> _removeFromRecentDocuments(String id) async {
    final recentIds = _prefs!.getStringList(_recentDocsKey) ?? [];
    recentIds.remove(id);
    await _prefs!.setStringList(_recentDocsKey, recentIds);
  }

  /// Clear all documents (use with caution!)
  Future<void> clearAllDocuments() async {
    _ensureInitialized();
    await _documentsBox!.clear();
    await _prefs!.remove(_recentDocsKey);
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    _ensureInitialized();
    
    final allDocs = await getAllDocuments();
    final totalWords = allDocs.fold<int>(0, (sum, doc) => sum + doc.getWordCount());
    final totalSize = _documentsBox!.values.fold<int>(0, (sum, json) => sum + json.length);
    
    return {
      'documentCount': allDocs.length,
      'totalWords': totalWords,
      'totalSizeBytes': totalSize,
      'averageWordsPerDoc': allDocs.isEmpty ? 0 : (totalWords / allDocs.length).round(),
    };
  }

  /// Close the service
  Future<void> close() async {
    await _documentsBox?.close();
  }
}

/// Canvas storage service using Hive
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_layer_node.dart';

class CanvasStorageService {
  static const String _boxName = 'media_canvas';
  static const String _listKey = 'canvas_list';

  Box<String>? _box;

  /// Initialize the service
  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (_box == null) {
      throw StateError('CanvasStorageService not initialized. Call initialize() first.');
    }
  }

  /// Get or open Hive box
  Future<Box> _getBox() async {
    _ensureInitialized();
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  /// Save canvas document
  Future<void> saveDocument(CanvasDocument document) async {
    final box = await _getBox();
    await box.put(document.id, jsonEncode(document.toJson()));
    
    // Update document list
    await _updateDocumentList(document.id, document.name);
  }

  /// Load canvas document
  Future<CanvasDocument> loadDocument(String documentId) async {
    final box = await _getBox();
    final jsonString = box.get(documentId) as String?;
    
    if (jsonString == null) {
      throw Exception('Canvas not found: $documentId');
    }
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return CanvasDocument.fromJson(json);
  }

  /// Delete canvas document
  Future<void> deleteDocument(String documentId) async {
    final box = await _getBox();
    await box.delete(documentId);
    
    // Remove from document list
    final list = await getDocumentList();
    list.removeWhere((doc) => doc['id'] == documentId);
    await box.put(_listKey, jsonEncode(list));
  }

  /// Get list of all canvases
  Future<List<Map<String, dynamic>>> getDocumentList() async {
    final box = await _getBox();
    final listJson = box.get(_listKey) as String?;
    
    if (listJson == null) {
      return [];
    }
    
    final list = jsonDecode(listJson) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// Update document list
  Future<void> _updateDocumentList(String id, String name) async {
    final box = await _getBox();
    final list = await getDocumentList();
    
    // Remove existing entry
    list.removeWhere((doc) => doc['id'] == id);
    
    // Add new entry
    list.add({
      'id': id,
      'name': name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    // Sort by updatedAt (newest first)
    list.sort((a, b) => (b['updatedAt'] as String).compareTo(a['updatedAt'] as String));
    
    await box.put(_listKey, jsonEncode(list));
  }

  /// Export canvas as JSON
  Future<String> exportAsJson(String documentId) async {
    final document = await loadDocument(documentId);
    return jsonEncode(document.toJson());
  }

  /// Import canvas from JSON
  Future<CanvasDocument> importFromJson(String jsonString) async {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final document = CanvasDocument.fromJson(json);
    
    // Generate new ID to avoid conflicts
    final newDocument = document.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      updatedAt: DateTime.now(),
    );
    
    await saveDocument(newDocument);
    return newDocument;
  }
}

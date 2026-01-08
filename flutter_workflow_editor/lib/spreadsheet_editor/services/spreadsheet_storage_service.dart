/// Local storage service for spreadsheet documents
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/spreadsheet_document.dart';

class SpreadsheetStorageService {
  static const String _boxName = 'spreadsheets';
  static const String _listKey = 'spreadsheet_list';

  Box<String>? _box;

  /// Initialize the service
  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (_box == null) {
      throw StateError('SpreadsheetStorageService not initialized. Call initialize() first.');
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

  /// Save spreadsheet document
  Future<void> saveDocument(SpreadsheetDocument document) async {
    final box = await _getBox();
    await box.put(document.id, jsonEncode(document.toJson()));
    
    // Update document list
    await _updateDocumentList(document.id, document.name);
  }

  /// Load spreadsheet document
  Future<SpreadsheetDocument> loadDocument(String documentId) async {
    final box = await _getBox();
    final jsonString = box.get(documentId) as String?;
    
    if (jsonString == null) {
      throw Exception('Document not found: $documentId');
    }
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SpreadsheetDocument.fromJson(json);
  }

  /// Delete spreadsheet document
  Future<void> deleteDocument(String documentId) async {
    final box = await _getBox();
    await box.delete(documentId);
    
    // Remove from document list
    final list = await getDocumentList();
    list.removeWhere((doc) => doc['id'] == documentId);
    await box.put(_listKey, jsonEncode(list));
  }

  /// Get list of all documents (id, name, updatedAt)
  Future<List<Map<String, dynamic>>> getDocumentList() async {
    final box = await _getBox();
    final listJson = box.get(_listKey) as String?;
    
    if (listJson == null) {
      return [];
    }
    
    final list = jsonDecode(listJson) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// Update document list with new/updated document
  Future<void> _updateDocumentList(String id, String name) async {
    final box = await _getBox();
    final list = await getDocumentList();
    
    // Remove existing entry if present
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

  /// Export document as JSON string
  Future<String> exportAsJson(String documentId) async {
    final document = await loadDocument(documentId);
    return jsonEncode(document.toJson());
  }

  /// Import document from JSON string
  Future<SpreadsheetDocument> importFromJson(String jsonString) async {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final document = SpreadsheetDocument.fromJson(json);
    
    // Generate new ID to avoid conflicts
    final newDocument = document.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      updatedAt: DateTime.now(),
    );
    
    await saveDocument(newDocument);
    return newDocument;
  }
}

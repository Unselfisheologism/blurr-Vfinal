import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../models/document_item.dart';

/// Platform channel service for AI + native capabilities (document parsing, TTS, etc).
class LearningPlatformService {
  static const MethodChannel _channel = MethodChannel('com.blurr.learning_platform/bridge');

  Future<bool> checkProAccess() async {
    try {
      final result = await _channel.invokeMethod('checkProAccess');
      return result as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Extracts plain text from an uploaded file.
  ///
  /// For text-like formats (txt/md), Flutter can decode directly; however this provides
  /// consistent behavior and enables PDF/DOCX parsing on the Kotlin side.
  Future<String> extractDocumentText({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final result = await _channel.invokeMethod('extractDocumentText', {
      'bytes': bytes,
      'fileName': fileName,
    });
    return (result as String?) ?? '';
  }

  Future<String> generateSummary({
    required String documentText,
    String? preferredStyle,
  }) async {
    final result = await _channel.invokeMethod('generateSummary', {
      'documentText': documentText,
      'preferredStyle': preferredStyle ?? 'mobile',
    });
    return (result as String?) ?? '';
  }

  Future<String> generateStudyGuide({
    required String documentText,
  }) async {
    final result = await _channel.invokeMethod('generateStudyGuide', {
      'documentText': documentText,
    });
    return (result as String?) ?? '';
  }

  Future<String> generateQuiz({
    required String documentText,
    int questionCount = 8,
  }) async {
    final result = await _channel.invokeMethod('generateQuiz', {
      'documentText': documentText,
      'questionCount': questionCount,
    });
    return (result as String?) ?? '';
  }

  Future<String> generateFlashcards({
    required String documentText,
    int cardCount = 12,
  }) async {
    final result = await _channel.invokeMethod('generateFlashcards', {
      'documentText': documentText,
      'cardCount': cardCount,
    });
    return (result as String?) ?? '';
  }

  Future<String> synthesizeAudioOverview({
    required String text,
    String? voice,
  }) async {
    final result = await _channel.invokeMethod('synthesizeAudio', {
      'text': text,
      'voice': voice,
    });
    return (result as String?) ?? '';
  }

  Future<String> generateInfographic({
    required String topic,
    String style = 'professional',
    String method = 'd3js',
    String? data,
  }) async {
    final result = await _channel.invokeMethod('generateInfographic', {
      'topic': topic,
      'style': style,
      'method': method,
      'data': data,
    });
    return (result as String?) ?? '';
  }

  Future<String> askQuestion({
    required String documentText,
    required String question,
    List<ChatMessage> history = const [],
  }) async {
    final result = await _channel.invokeMethod('askQuestion', {
      'documentText': documentText,
      'question': question,
      'history': history.map((m) => m.toJson()).toList(),
    });
    return (result as String?) ?? '';
  }
}

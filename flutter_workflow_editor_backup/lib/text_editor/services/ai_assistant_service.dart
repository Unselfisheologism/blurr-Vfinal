import 'package:flutter/services.dart';
import 'dart:async';

/// Service for AI assistance integration via Platform Channels
/// 
/// Communicates with the Kotlin side to execute AI operations
/// using the existing UltraGeneralistAgent and tool infrastructure.
class AIAssistantService {
  static const MethodChannel _channel = MethodChannel('ai_assistance');

  /// AI operation types
  static const String operationRewrite = 'rewrite';
  static const String operationSummarize = 'summarize';
  static const String operationExpand = 'expand';
  static const String operationContinue = 'continue';
  static const String operationGrammar = 'grammar';
  static const String operationTranslate = 'translate';
  static const String operationGenerate = 'generate';

  /// Rewrite tone options
  static const String toneProfessional = 'professional';
  static const String toneCasual = 'casual';
  static const String toneCreative = 'creative';
  static const String toneFormal = 'formal';
  static const String toneFriendly = 'friendly';

  /// Summarize length options
  static const String lengthBrief = 'brief';
  static const String lengthDetailed = 'detailed';

  /// Process an AI request
  /// 
  /// Sends the request to the Kotlin agent and returns the response.
  /// Throws [PlatformException] if the operation fails.
  Future<AIAssistantResult> processRequest({
    required String operation,
    required String text,
    String? instruction,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final result = await _channel.invokeMethod('processRequest', {
        'operation': operation,
        'text': text,
        'instruction': instruction ?? '',
        'context': additionalContext ?? {},
      });

      if (result is Map) {
        return AIAssistantResult.fromMap(Map<String, dynamic>.from(result));
      } else if (result is String) {
        return AIAssistantResult.success(result);
      } else {
        throw Exception('Unexpected result type: ${result.runtimeType}');
      }
    } on PlatformException catch (e) {
      return AIAssistantResult.error(e.message ?? 'Unknown error');
    } catch (e) {
      return AIAssistantResult.error(e.toString());
    }
  }

  /// Rewrite text with specified tone
  Future<AIAssistantResult> rewriteText({
    required String text,
    required String tone,
  }) async {
    return processRequest(
      operation: operationRewrite,
      text: text,
      instruction: 'Rewrite this text in a $tone tone',
      additionalContext: {'tone': tone},
    );
  }

  /// Summarize text
  Future<AIAssistantResult> summarizeText({
    required String text,
    required String length,
  }) async {
    return processRequest(
      operation: operationSummarize,
      text: text,
      instruction: 'Provide a $length summary of this text',
      additionalContext: {'length': length},
    );
  }

  /// Expand text with more details
  Future<AIAssistantResult> expandText({
    required String text,
  }) async {
    return processRequest(
      operation: operationExpand,
      text: text,
      instruction: 'Expand on this text with more details and examples',
    );
  }

  /// Continue writing from cursor position
  Future<AIAssistantResult> continueWriting({
    required String precedingText,
    String? hint,
  }) async {
    return processRequest(
      operation: operationContinue,
      text: precedingText,
      instruction: hint ?? 'Continue writing from here',
      additionalContext: {'hint': hint},
    );
  }

  /// Fix grammar and spelling
  Future<AIAssistantResult> fixGrammar({
    required String text,
  }) async {
    return processRequest(
      operation: operationGrammar,
      text: text,
      instruction: 'Fix grammar and spelling errors in this text',
    );
  }

  /// Translate text to target language
  Future<AIAssistantResult> translateText({
    required String text,
    required String targetLanguage,
  }) async {
    return processRequest(
      operation: operationTranslate,
      text: text,
      instruction: 'Translate this text to $targetLanguage',
      additionalContext: {'targetLanguage': targetLanguage},
    );
  }

  /// Generate text from prompt
  Future<AIAssistantResult> generateFromPrompt({
    required String prompt,
    String? context,
  }) async {
    return processRequest(
      operation: operationGenerate,
      text: context ?? '',
      instruction: prompt,
      additionalContext: {'prompt': prompt},
    );
  }

  /// Check if user has Pro access
  Future<bool> checkProAccess() async {
    try {
      final result = await _channel.invokeMethod('checkProAccess');
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking Pro access: $e');
      return false;
    }
  }

  /// Check if operation requires Pro
  Future<bool> isProOperationAllowed({
    required String operation,
    int? textLength,
  }) async {
    try {
      final result = await _channel.invokeMethod('isProOperationAllowed', {
        'operation': operation,
        'textLength': textLength ?? 0,
      });
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking Pro operation: $e');
      return false;
    }
  }

  /// Get AI operation usage count (for Pro gating)
  Future<int> getOperationCount() async {
    try {
      final result = await _channel.invokeMethod('getOperationCount');
      return result as int? ?? 0;
    } catch (e) {
      print('Error getting operation count: $e');
      return 0;
    }
  }

  /// Get AI operation limit for free tier
  Future<int> getOperationLimit() async {
    try {
      final result = await _channel.invokeMethod('getOperationLimit');
      return result as int? ?? 50;
    } catch (e) {
      print('Error getting operation limit: $e');
      return 50;
    }
  }

  /// Stream for AI responses (for streaming mode if implemented)
  Stream<String> streamResponse({
    required String operation,
    required String text,
    String? instruction,
  }) {
    final controller = StreamController<String>();
    
    // For now, just return the full response
    // Can be extended to support true streaming if Kotlin side implements it
    processRequest(
      operation: operation,
      text: text,
      instruction: instruction,
    ).then((result) {
      if (result.success) {
        controller.add(result.text);
        controller.close();
      } else {
        controller.addError(result.error ?? 'Unknown error');
        controller.close();
      }
    }).catchError((error) {
      controller.addError(error);
      controller.close();
    });
    
    return controller.stream;
  }
}

/// Result of an AI assistance operation
class AIAssistantResult {
  final bool success;
  final String text;
  final String? error;
  final Map<String, dynamic>? metadata;

  AIAssistantResult({
    required this.success,
    required this.text,
    this.error,
    this.metadata,
  });

  factory AIAssistantResult.success(String text, {Map<String, dynamic>? metadata}) {
    return AIAssistantResult(
      success: true,
      text: text,
      metadata: metadata,
    );
  }

  factory AIAssistantResult.error(String error) {
    return AIAssistantResult(
      success: false,
      text: '',
      error: error,
    );
  }

  factory AIAssistantResult.fromMap(Map<String, dynamic> map) {
    return AIAssistantResult(
      success: map['success'] as bool? ?? false,
      text: map['text'] as String? ?? '',
      error: map['error'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'text': text,
      'error': error,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    if (success) {
      return 'AIAssistantResult(success: true, textLength: ${text.length})';
    } else {
      return 'AIAssistantResult(success: false, error: $error)';
    }
  }
}

/// Predefined AI operation configurations
class AIOperationConfig {
  final String operation;
  final String displayName;
  final String description;
  final bool requiresPro;
  final int? maxFreeLength;

  const AIOperationConfig({
    required this.operation,
    required this.displayName,
    required this.description,
    this.requiresPro = false,
    this.maxFreeLength,
  });

  static const List<AIOperationConfig> allOperations = [
    AIOperationConfig(
      operation: AIAssistantService.operationRewrite,
      displayName: 'Rewrite',
      description: 'Rewrite text in different tones',
      requiresPro: false,
    ),
    AIOperationConfig(
      operation: AIAssistantService.operationSummarize,
      displayName: 'Summarize',
      description: 'Create a brief or detailed summary',
      requiresPro: false,
    ),
    AIOperationConfig(
      operation: AIAssistantService.operationExpand,
      displayName: 'Expand',
      description: 'Add more details and examples',
      requiresPro: false,
    ),
    AIOperationConfig(
      operation: AIAssistantService.operationContinue,
      displayName: 'Continue',
      description: 'Continue writing from here',
      requiresPro: false,
    ),
    AIOperationConfig(
      operation: AIAssistantService.operationGrammar,
      displayName: 'Fix Grammar',
      description: 'Correct grammar and spelling',
      requiresPro: false,
    ),
    AIOperationConfig(
      operation: AIAssistantService.operationTranslate,
      displayName: 'Translate',
      description: 'Translate to another language',
      requiresPro: false,
    ),
    AIOperationConfig(
      operation: AIAssistantService.operationGenerate,
      displayName: 'Generate',
      description: 'Generate text from prompt',
      requiresPro: true,
      maxFreeLength: 500,
    ),
  ];

  static AIOperationConfig? getConfig(String operation) {
    try {
      return allOperations.firstWhere((config) => config.operation == operation);
    } catch (e) {
      return null;
    }
  }
}

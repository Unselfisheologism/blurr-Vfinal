import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/learning_material.dart';
import '../models/learning_activity.dart';
import '../models/learning_path.dart';

class AILearningService {
  static const MethodChannel _channel = MethodChannel('com.blurr.learning_platform/ai');
  
  // AI Operations for Learning Materials
  static Future<AISummary> generateSummary(String content, {
    String summaryType = 'brief', // 'brief', 'detailed', 'key_points'
    int? maxLength,
  }) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('generateSummary', {
        'content': content,
        'summaryType': summaryType,
        'maxLength': maxLength,
      });
      
      return AISummary(
        briefSummary: result['brief'] ?? '',
        detailedSummary: result['detailed'],
        keyPoints: result['keyPoints']?.cast<String>(),
        mainTopics: result['mainTopics']?.cast<String>(),
        difficultyLevel: result['difficultyLevel'],
        prerequisites: result['prerequisites']?.cast<String>(),
      );
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }
  
  static Future<LearningActivity> generateQuizFromMaterial(LearningMaterial material) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('generateQuiz', {
        'materialId': material.id,
        'content': material.content ?? '',
        'title': material.title,
      });
      
      return LearningActivity(
        id: result['id'] ?? 'quiz_${material.id}',
        title: result['title'] ?? 'Quiz: ${material.title}',
        type: ActivityType.quiz,
        learningMaterialId: material.id,
        description: result['description'],
        aiGeneratedContent: result['prompt'],
        quizData: QuizData(
          questions: (result['questions'] as List)
              .map((q) => Question(
                    id: q['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    text: q['text'],
                    type: _parseQuestionType(q['type']),
                    options: q['options']?.cast<String>(),
                    correctAnswers: q['correctAnswers']?.cast<String>(),
                    explanation: q['explanation'],
                    points: q['points'] ?? 1,
                  ))
              .toList(),
          settings: QuizSettings(
            showAnswers: true,
            shuffleQuestions: true,
            shuffleOptions: true,
            passingScore: 70,
          ),
        ),
      );
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }
  
  static Future<LearningActivity> generateFlashcardsFromMaterial(LearningMaterial material) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('generateFlashcards', {
        'materialId': material.id,
        'content': material.content ?? '',
      });
      
      return LearningActivity(
        id: result['id'] ?? 'flashcards_${material.id}',
        title: result['title'] ?? 'Flashcards: ${material.title}',
        type: ActivityType.flashcard,
        learningMaterialId: material.id,
        description: result['description'],
        aiGeneratedContent: result['prompt'],
        flashcardData: FlashcardData(
          cards: (result['flashcards'] as List)
              .map((f) => Flashcard(
                    id: f['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    front: f['front'],
                    back: f['back'],
                    hint: f['hint'],
                    tags: f['tags']?.cast<String>() ?? [],
                  ))
              .toList(),
        ),
      );
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }
  
  static Future<LearningPath> generateLearningPath(List<LearningMaterial> materials, {
    required String title,
    String? description,
    List<String>? learningObjectives,
  }) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('generateLearningPath', {
        'materialIds': materials.map((m) => m.id).toList(),
        'titles': materials.map((m) => m.title).toList(),
        'contents': materials.map((m) => m.content ?? '').toList(),
        'pathTitle': title,
        'pathDescription': description,
        'learningObjectives': learningObjectives,
      });
      
      return LearningPath(
        id: result['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title'] ?? title,
        description: result['description'] ?? description,
        creatorId: 'ai', // AI generated
        materialIds: materials.map((m) => m.id).toList(),
        activityIds: result['activityIds']?.cast<String>() ?? [],
        isLinear: result['isLinear'] ?? true,
        isAdaptive: result['isAdaptive'] ?? true,
        estimatedDuration: result['estimatedDuration'] ?? 0,
        prerequisites: result['prerequisites']?.cast<String>(),
        aiEnhanced: true,
        aiContent: AIGeneratedPathContent(
          learningObjective: learningObjectives?.first ?? '',
          keyTopics: result['keyTopics']?.cast<String>() ?? [],
          skills: result['skills']?.cast<String>() ?? [],
          difficultyAssessment: result['difficultyLevel'] ?? 'intermediate',
          learningOutcomes: result['learningOutcomes'],
        ),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to generate learning path: $e');
    }
  }
  
  // Q&A for learning materials
  static Future<String> answerQuestion({
    required String materialId,
    required String question,
    required String contentContext,
  }) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('answerQuestion', {
        'materialId': materialId,
        'question': question,
        'context': contentContext,
      });
      
      return result['answer'] ?? 'No answer generated';
    } catch (e) {
      throw Exception('Failed to answer question: $e');
    }
  }
  
  // Adaptive learning recommendations
  static Future<List<MaterialRecommendation>> getRecommendations({
    required String userId,
    List<String>? completedMaterials,
    List<String>? interests,
    int? limit = 10,
  }) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getRecommendations', {
        'userId': userId,
        'completedMaterials': completedMaterials ?? [],
        'interests': interests ?? [],
        'limit': limit,
      });
      
      return result.map((r) => MaterialRecommendation(
        materialId: r['materialId'],
        relevanceScore: r['relevanceScore']?.toDouble() ?? 0.0,
        reason: r['reason'] ?? '',
        prerequisites: r['prerequisites']?.cast<String>(),
        difficultyLevel: r['difficultyLevel'],
      )).toList();
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }
  
  // Audio overview generation
  static Future<String> generateAudioOverview({
    required String content,
    required String title,
  }) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('generateAudioOverview', {
        'content': content,
        'title': title,
      });
      
      return result['audioFilePath'] ?? '';
    } catch (e) {
      throw Exception('Failed to generate audio overview: $e');
    }
  }
  
  // Helper methods
  static QuestionType _parseQuestionType(String? type) {
    switch (type) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'single_choice':
        return QuestionType.singleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'fill_in_the_blank':
        return QuestionType.fillInTheBlank;
      case 'matching':
        return QuestionType.matching;
      case 'essay':
        return QuestionType.essay;
      default:
        return QuestionType.singleChoice;
    }
  }
  
  // Difficulty analysis
  static Future<Map<String, dynamic>> analyzeDifficulty(String content) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('analyzeDifficulty', {
        'content': content,
      });
      
      return {
        'difficultyLevel': result['difficultyLevel'] ?? 'intermediate',
        'readabilityScore': result['readabilityScore'] ?? 0,
        'estimatedReadTime': result['estimatedReadTime'] ?? 0,
        'keyConcepts': result['keyConcepts']?.cast<String>() ?? [],
        'vocabularyLevel': result['vocabularyLevel'] ?? 'intermediate',
      };
    } catch (e) {
      throw Exception('Failed to analyze difficulty: $e');
    }
  }
}
import 'package:hive/hive.dart';

class HiveInitializer {
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    _registerAdapters();
    
    _isInitialized = true;
  }
  
  static void _registerAdapters() {
    // Material adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LearningMaterialAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AISummaryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LearningActivityAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(QuizQuestionAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(FlashcardAdapter());
    }
    // Add more adapters as needed
  }
}
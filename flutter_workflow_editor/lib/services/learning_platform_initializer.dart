import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/learning_material.dart';
import '../models/learning_activity.dart';
import '../models/learning_path.dart';
import '../models/adapters/learning_material_adapter.dart';
import '../models/adapters/learning_activity_adapter.dart';

class LearningPlatformInitializer {
  static bool _isInitialized = false;
  static Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    
    // Initialize Hive
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init('${appDir.path}/learning_platform');
    
    // Register adapters
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
    
    _isInitialized = true;
  }
  
  static Future<void> openBoxes() async {
    await Hive.openBox('learning_materials');
    await Hive.openBox('learning_activities');
    await Hive.openBox('learning_paths');
    await Hive.openBox('learning_progress');
    await Hive.openBox('learning_stats');
  }
}
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/learning_material.dart';
import '../models/learning_activity.dart';
import '../models/learning_path.dart';

class LearningStorageService {
  static const String _materialsBoxName = 'learning_materials';
  static const String _activitiesBoxName = 'learning_activities';
  static const String _pathsBoxName = 'learning_paths';
  static const String _progressBoxName = 'learning_progress';
  static const String _statsBoxName = 'learning_stats';
  
  static LearningStorageService? _instance;
  static LearningStorageService get instance => _instance ??= LearningStorageService._internal();
  
  LearningStorageService._internal();
  
  // Initialize Hive boxes
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init('${appDir.path}/learning_platform');
    
    // Register adapters if not already registered
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
      Hive.registerAdapter(LearningPathAdapter());
    }
    
    await Hive.openBox(_materialsBoxName);
    await Hive.openBox(_activitiesBoxName);
    await Hive.openBox(_pathsBoxName);
    await Hive.openBox(_progressBoxName);
    await Hive.openBox(_statsBoxName);
  }
  
  // Learning Material CRUD
  Future<String> saveMaterial(LearningMaterial material) async {
    final box = Hive.box(_materialsBoxName);
    final id = material.id;
    await box.put(id, material.toJson());
    return id;
  }
  
  Future<LearningMaterial?> getMaterial(String id) async {
    final box = Hive.box(_materialsBoxName);
    final data = box.get(id);
    if (data != null) {
      return LearningMaterial.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  Future<List<LearningMaterial>> getAllMaterials() async {
    final box = Hive.box(_materialsBoxName);
    final keys = box.keys.cast<String>();
    final materials = <LearningMaterial>[];
    
    for (final key in keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          final material = LearningMaterial.fromJson(Map<String, dynamic>.from(data));
          materials.add(material);
        } catch (e) {
          // Skip corrupted entries
        }
      }
    }
    
    return materials;
  }
  
  Future<List<LearningMaterial>> getMaterialsByType(MaterialType type) async {
    final materials = await getAllMaterials();
    return materials.where((m) => m.type == type).toList();
  }
  
  Future<List<LearningMaterial>> searchMaterials(String query) async {
    final materials = await getAllMaterials();
    final lowerQuery = query.toLowerCase();
    
    return materials.where((m) {
      final titleMatch = m.title.toLowerCase().contains(lowerQuery);
      final descMatch = m.description?.toLowerCase().contains(lowerQuery) ?? false;
      final tagsMatch = m.tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false;
      return titleMatch || descMatch || tagsMatch;
    }).toList();
  }
  
  Future<void> deleteMaterial(String id) async {
    final box = Hive.box(_materialsBoxName);
    await box.delete(id);
  }
  
  // Mark material as AI processed
  Future<void> markAsAIProcessed(String materialId, AISummary aiSummary) async {
    final material = await getMaterial(materialId);
    if (material != null) {
      final updatedMaterial = material.copyWith(
        aiProcessed: true,
        aiSummary: aiSummary,
      );
      await saveMaterial(updatedMaterial);
    }
  }
  
  // Update material progress
  Future<void> updateMaterialProgress(String materialId, double progress) async {
    final material = await getMaterial(materialId);
    if (material != null) {
      final updatedMaterial = material.copyWith(
        progress: progress,
        lastAccessedAt: DateTime.now(),
        completedAt: progress >= 100 ? DateTime.now() : material.completedAt,
      );
      await saveMaterial(updatedMaterial);
    }
  }
  
  // Learning Activity CRUD
  Future<String> saveActivity(LearningActivity activity) async {
    final box = Hive.box(_activitiesBoxName);
    final id = activity.id;
    await box.put(id, activity.toJson());
    return id;
  }
  
  Future<LearningActivity?> getActivity(String id) async {
    final box = Hive.box(_activitiesBoxName);
    final data = box.get(id);
    if (data != null) {
      return LearningActivity.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  Future<List<LearningActivity>> getActivitiesByMaterial(String materialId) async {
    final box = Hive.box(_activitiesBoxName);
    final keys = box.keys.cast<String>();
    final activities = <LearningActivity>[];
    
    for (final key in keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          final activity = LearningActivity.fromJson(Map<String, dynamic>.from(data));
          if (activity.learningMaterialId == materialId) {
            activities.add(activity);
          }
        } catch (e) {
          // Skip corrupted entries
        }
      }
    }
    
    return activities;
  }
  
  Future<List<LearningActivity>> getActivitiesByType(ActivityType type) async {
    final box = Hive.box(_activitiesBoxName);
    final keys = box.keys.cast<String>();
    final activities = <LearningActivity>[];
    
    for (final key in keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          final activity = LearningActivity.fromJson(Map<String, dynamic>.from(data));
          if (activity.type == type) {
            activities.add(activity);
          }
        } catch (e) {
          // Skip corrupted entries
        }
      }
    }
    
    return activities;
  }
  
  Future<void> deleteActivity(String id) async {
    final box = Hive.box(_activitiesBoxName);
    await box.delete(id);
  }
  
  // Learning Path CRUD
  Future<String> savePath(LearningPath path) async {
    final box = Hive.box(_pathsBoxName);
    final id = path.id;
    await box.put(id, path.toJson());
    return id;
  }
  
  Future<LearningPath?> getPath(String id) async {
    final box = Hive.box(_pathsBoxName);
    final data = box.get(id);
    if (data != null) {
      return LearningPath.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  Future<List<LearningPath>> getAllPaths() async {
    final box = Hive.box(_pathsBoxName);
    final keys = box.keys.cast<String>();
    final paths = <LearningPath>[];
    
    for (final key in keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          final path = LearningPath.fromJson(Map<String, dynamic>.from(data));
          paths.add(path);
        } catch (e) {
          // Skip corrupted entries
        }
      }
    }
    
    return paths;
  }
  
  Future<List<LearningPath>> getPublishedPaths() async {
    final paths = await getAllPaths();
    return paths.where((p) => p.isPublished).toList();
  }
  
  Future<List<LearningPath>> searchPaths(String query) async {
    final paths = await getAllPaths();
    final lowerQuery = query.toLowerCase();
    
    return paths.where((p) {
      final titleMatch = p.title.toLowerCase().contains(lowerQuery);
      final descMatch = p.description?.toLowerCase().contains(lowerQuery) ?? false;
      return titleMatch || descMatch;
    }).toList();
  }
  
  Future<void> deletePath(String id) async {
    final box = Hive.box(_pathsBoxName);
    await box.delete(id);
  }
  
  // Progress tracking
  Future<void> savePathProgress(PathProgress progress) async {
    final box = Hive.box(_progressBoxName);
    final key = '${progress.pathId}_${progress.userId}';
    await box.put(key, progress.toJson());
  }
  
  Future<PathProgress?> getPathProgress(String pathId, String userId) async {
    final box = Hive.box(_progressBoxName);
    final data = box.get('${pathId}_$userId');
    if (data != null) {
      return PathProgress.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  Future<List<PathProgress>> getUserProgress(String userId) async {
    final box = Hive.box(_progressBoxName);
    final keys = box.keys.cast<String>();
    final progressList = <PathProgress>[];
    
    for (final key in keys) {
      final data = box.get(key);
      if (data != null && key.contains(userId)) {
        try {
          final progress = PathProgress.fromJson(Map<String, dynamic>.from(data));
          progressList.add(progress);
        } catch (e) {
          // Skip corrupted entries
        }
      }
    }
    
    return progressList;
  }
  
  Future<ActivityProgress?> getActivityProgress(String activityId, String userId) async {
    final box = Hive.box(_progressBoxName);
    final data = box.get('${activityId}_$userId');
    if (data != null) {
      return ActivityProgress.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  Future<void> saveActivityProgress(ActivityProgress progress) async {
    final box = Hive.box(_progressBoxName);
    final key = '${progress.activityId}_${progress.userId}';
    await box.put(key, progress.toJson());
  }
  
  // Statistics and analytics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final box = Hive.box(_statsBoxName);
    final data = box.get(userId);
    
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    
    // Return default stats
    return {
      'totalMaterials': 0,
      'totalActivities': 0,
      'totalPaths': 0,
      'totalStudyTime': 0,
      'streakDays': 0,
      'completionRate': 0.0,
      'favoriteSubjects': [],
      'strongTopics': [],
      'weakTopics': [],
      'achievements': [],
      'currentStreak': 0,
    };
  }
  
  Future<void> updateUserStats(String userId, Map<String, dynamic> stats) async {
    final box = Hive.box(_statsBoxName);
    await box.put(userId, stats);
  }
  
  Future<void> incrementStudyTime(String userId, int minutes) async {
    final stats = await getUserStats(userId);
    stats['totalStudyTime'] = (stats['totalStudyTime'] ?? 0) + minutes;
    await updateUserStats(userId, stats);
  }
  
  Future<void> incrementStreak(String userId) async {
    final stats = await getUserStats(userId);
    stats['currentStreak'] = (stats['currentStreak'] ?? 0) + 1;
    stats['streakDays'] = (stats['streakDays'] ?? 0) + 1;
    await updateUserStats(userId, stats);
  }
  
  // Export/Import functionality
  Future<String> exportData(String userId) async {
    final materials = await getAllMaterials();
    final paths = await getUserProgress(userId);
    final stats = await getUserStats(userId);
    
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'materials': materials.map((m) => m.toJson()).toList(),
      'userProgress': paths.map((p) => p.toJson()).toList(),
      'stats': stats,
    };
    
    return jsonEncode(exportData);
  }
  
  Future<void> importData(String userId, String jsonString) async {
    final data = jsonDecode(jsonString);
    
    // Import materials
    final materialsData = data['materials'] as List;
    for (final materialData in materialsData) {
      final material = LearningMaterial.fromJson(materialData);
      await saveMaterial(material);
    }
    
    // Import user progress
    final progressData = data['userProgress'] as List;
    for (final progressDataItem in progressData) {
      final progress = PathProgress.fromJson(progressDataItem);
      await savePathProgress(progress);
    }
    
    // Import stats
    if (data['stats'] != null) {
      await updateUserStats(userId, Map<String, dynamic>.from(data['stats']));
    }
  }
  
  // Backup and restore
  Future<void> backupData(String userId) async {
    final export = await exportData(userId);
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupFileName = 'learning_backup_$userId_$timestamp.json';
    
    // Store backup in app directory
    final appDir = await getApplicationDocumentsDirectory();
    final backupFile = File('${appDir.path}/backups/$backupFileName');
    await backupFile.create(recursive: true);
    await backupFile.writeAsString(export);
  }
  
  Future<void> cleanupBackups({int maxAgeDays = 30}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    
    if (backupDir.existsSync()) {
      final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays));
      
      for (final file in backupDir.listSync()) {
        if (file is File) {
          final stat = file.statSync();
          if (stat.modified.isBefore(cutoff)) {
            file.deleteSync();
          }
        }
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'models/learning_material.dart';
import 'models/learning_activity.dart';
import 'models/learning_path.dart';
import 'services/ai_learning_service.dart';
import 'services/learning_storage_service.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  final LearningStorageService _storageService = LearningStorageService.instance;
  final AILearningService _aiService = AILearningService();
  
  List<LearningMaterial> _materials = [];
  List<LearningActivity> _activities = [];
  List<LearningPath> _paths = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _storageService.initialize();
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final materials = await _storageService.getAllMaterials();
      final paths = await _storageService.getAllPaths();
      
      setState(() {
        _materials = materials;
        _paths = paths;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load data: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportData();
                  break;
                case 'help':
                  _showHelp();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Data'),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Text('Help'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMaterialDialog,
        tooltip: 'Add Learning Material',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Tab navigation
        TabBar(
          controller: TabController(length: 4, vsync: this, initialIndex: _selectedTab),
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          tabs: const [
            Tab(text: 'Library', icon: Icon(Icons.library_books)),
            Tab(text: 'Activities', icon: Icon(Icons.task)),
            Tab(text: 'Paths', icon: Icon(Icons.route)),
            Tab(text: 'AI Assistant', icon: Icon(Icons.smart_toy)),
          ],
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _buildLibraryView(),
              _buildActivitiesView(),
              _buildPathsView(),
              _buildAIAssistantView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryView() {
    if (_materials.isEmpty) {
      return _buildEmptyState(
        icon: Icons.library_books,
        title: 'No Learning Materials',
        subtitle: 'Add your first document to start learning',
        actionLabel: 'Add Material',
        onAction: _showAddMaterialDialog,
      );
    }

    return ListView.builder(
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final material = _materials[index];
        return _buildMaterialCard(material);
      },
    );
  }

  Widget _buildActivitiesView() {
    return FutureBuilder<List<LearningActivity>>(
      future: _storageService.getActivitiesByType(ActivityType.quiz),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final activities = snapshot.data ?? [];
        
        if (activities.isEmpty) {
          return _buildEmptyState(
            icon: Icons.task,
            title: 'No Activities',
            subtitle: 'Generate activities from your materials',
            actionLabel: 'Generate Quiz',
            onAction: () => _showGenerateActivityDialog(),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityCard(activity);
          },
        );
      },
    );
  }

  Widget _buildPathsView() {
    if (_paths.isEmpty) {
      return _buildEmptyState(
        icon: Icons.route,
        title: 'No Learning Paths',
        subtitle: 'Create a structured learning path',
        actionLabel: 'Create Path',
        onAction: _showCreatePathDialog,
      );
    }

    return ListView.builder(
      itemCount: _paths.length,
      itemBuilder: (context, index) {
        final path = _paths[index];
        return _buildPathCard(path);
      },
    );
  }

  Widget _buildAIAssistantView() {
    return const Center(
      child: Text('AI Assistant coming soon...'),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(LearningMaterial material) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(
          _getMaterialIcon(material.type),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(material.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(material.description ?? 'No description'),
            if (material.aiProcessed) ...[
              const SizedBox(height: 4),
              Chip(
                label: const Text('AI Processed'),
                backgroundColor: Colors.green[100],
                avatar: const Icon(Icons.auto_awesome, size: 16),
              ),
            ],
            _buildProgressIndicator(material.progress),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMaterialAction(value, material),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View')),
            const PopupMenuItem(value: 'ai_summarize', child: Text('AI Summarize')),
            const PopupMenuItem(value: 'generate_quiz', child: Text('Generate Quiz')),
            const PopupMenuItem(value: 'generate_flashcards', child: Text('Generate Flashcards')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(LearningActivity activity) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(
          _getActivityIcon(activity.type),
          color: Theme.of(context).secondaryHeaderColor,
        ),
        title: Text(activity.title),
        subtitle: Text('Type: ${activity.type.name}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleActivityAction(value, activity),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'start', child: Text('Start')),
            const PopupMenuItem(value: 'preview', child: Text('Preview')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Widget _buildPathCard(LearningPath path) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        leading: Icon(
          Icons.route,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(path.title),
        subtitle: Text(path.description ?? 'No description'),
        trailing: Chip(
          label: Text('${path.materialIds.length} materials'),
          backgroundColor: Colors.blue[100],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (path.aiEnhanced)
                  Chip(
                    label: const Text('AI Enhanced'),
                    backgroundColor: Colors.purple[100],
                    avatar: const Icon(Icons.auto_awesome, size: 16),
                  ),
                const SizedBox(height: 8),
                Text('Estimated duration: ${path.estimatedDuration} minutes'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _startPath(path),
                  child: const Text('Start Path'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(MaterialType type) {
    switch (type) {
      case MaterialType.pdf:
        return Icons.picture_as_pdf;
      case MaterialType.text:
        return Icons.text_snippet;
      case MaterialType.markdown:
        return Icons.format_shapes;
      case MaterialType.url:
        return Icons.link;
      case MaterialType.quiz:
        return Icons.quiz;
      case MaterialType.flashcardDeck:
        return Icons.style;
      case MaterialType.audio:
        return Icons.audio_file;
      case MaterialType.video:
        return Icons.video_file;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.quiz:
        return Icons.quiz;
      case ActivityType.flashcard:
        return Icons.style;
      case ActivityType.read:
        return Icons.menu_book;
      case ActivityType.listen:
        return Icons.headphones;
      case ActivityType.practice:
        return Icons.psychology;
      case ActivityType.video:
        return Icons.ondemand_video;
      case ActivityType.exercise:
        return Icons.fitness_center;
      default:
        return Icons.task;
    }
  }

  Widget _buildProgressIndicator(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (progress > 0) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
            minHeight: 4,
          ),
          Text(
            '${progress.round()}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  void _handleMaterialAction(String action, LearningMaterial material) async {
    switch (action) {
      case 'view':
        _viewMaterial(material);
        break;
      case 'ai_summarize':
        await _generateAISummary(material);
        break;
      case 'generate_quiz':
        await _generateQuizFromMaterial(material);
        break;
      case 'generate_flashcards':
        await _generateFlashcardsFromMaterial(material);
        break;
      case 'delete':
        await _deleteMaterial(material);
        break;
    }
  }

  void _handleActivityAction(String action, LearningActivity activity) {
    switch (action) {
      case 'start':
        _startActivity(activity);
        break;
      case 'preview':
        _previewActivity(activity);
        break;
      case 'delete':
        _deleteActivity(activity);
        break;
    }
  }

  void _viewMaterial(LearningMaterial material) {
    // TODO: Implement material viewer
    _showSuccess('Viewing material: ${material.title}');
  }

  Future<void> _generateAISummary(LearningMaterial material) async {
    try {
      final summary = await _aiService.generateSummary(material.content ?? '');
      await _storageService.markAsAIProcessed(material.id, summary);
      _showSuccess('AI summary generated successfully');
      await _loadAllData();
    } catch (e) {
      _showError('Failed to generate AI summary: $e');
    }
  }

  Future<void> _generateQuizFromMaterial(LearningMaterial material) async {
    try {
      final activity = await _aiService.generateQuizFromMaterial(material);
      await _storageService.saveActivity(activity);
      _showSuccess('Quiz generated successfully');
      await _loadAllData();
    } catch (e) {
      _showError('Failed to generate quiz: $e');
    }
  }

  Future<void> _generateFlashcardsFromMaterial(LearningMaterial material) async {
    try {
      final activity = await _aiService.generateFlashcardsFromMaterial(material);
      await _storageService.saveActivity(activity);
      _showSuccess('Flashcards generated successfully');
      await _loadAllData();
    } catch (e) {
      _showError('Failed to generate flashcards: $e');
    }
  }

  Future<void> _deleteMaterial(LearningMaterial material) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _storageService.deleteMaterial(material.id);
              Navigator.of(context).pop();
              _showSuccess('Material deleted successfully');
              await _loadAllData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Learning Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Upload Document'),
              onTap: () {
                Navigator.of(context).pop();
                _showUploadOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Write Text'),
              onTap: () {
                Navigator.of(context).pop();
                _showTextInputDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Add URL'),
              onTap: () {
                Navigator.of(context).pop();
                _showUrlInputDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return Container();
  }

  void _showUploadOptions() {
    // TODO: Implement file picker for document upload
    _showSuccess('File upload feature coming soon');
  }

  void _showTextInputDialog() {
    // TODO: Implement text input dialog
  }

  void _showUrlInputDialog() {
    // TODO: Implement URL input dialog
  }

  void _showGenerateActivityDialog() {
    // TODO: Implement activity generation dialog
    _showSuccess('Activity generation dialog coming soon');
  }

  void _showCreatePathDialog() {
    // TODO: Implement path creation dialog
    _showSuccess('Path creation dialog coming soon');
  }

  void _startActivity(LearningActivity activity) {
    _showSuccess('Starting activity: ${activity.title}');
  }

  void _previewActivity(LearningActivity activity) {
    _showSuccess('Previewing activity: ${activity.title}');
  }

  void _deleteActivity(LearningActivity activity) {
    // TODO: Implement activity deletion
  }

  void _startPath(LearningPath path) {
    _showSuccess('Starting path: ${path.title}');
  }

  Future<void> _exportData() async {
    try {
      // TODO: Get current user ID
      final userId = 'current_user';
      final data = await _storageService.exportData(userId);
      _showSuccess('Data exported successfully');
      // TODO: Implement file save dialog
    } catch (e) {
      _showError('Failed to export data: $e');
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Learning Hub Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Upload documents and learning materials\n'),
            Text('• Get AI-generated summaries and insights\n'),
            Text('• Generate quizzes and flashcards from content\n'),
            Text('• Create structured learning paths\n'),
            Text('• Track your progress and achievements'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class TabBar extends StatelessWidget {
  final TabController controller;
  final ValueChanged<int> onTap;
  final List<Tab> tabs;

  const TabBar({
    required this.controller,
    required this.onTap,
    required this.tabs,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        tabs: tabs,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
    );
  }
}

mixin SingleTickerProviderStateMixin<T extends StatefulWidget> {
  // This mixin is typically provided by Flutter's TickerProviderStateMixin
  // For this custom implementation, we'll create a simple version
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
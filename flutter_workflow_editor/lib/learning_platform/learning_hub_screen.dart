import 'package:flutter/material.dart';
import '../models/document_item.dart';
import '../services/learning_platform_service.dart';
import '../services/learning_storage_service.dart';
import '../widgets/document_library_widget.dart';
import '../widgets/ai_toolbar_widget.dart';
import '../widgets/study_content_widget.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/chat_interface_widget.dart';

/// Main screen for AI-Native Learning Platform
/// 
/// Provides comprehensive learning environment with document management,
/// AI-powered content generation, and interactive study tools.
class LearningHubScreen extends StatefulWidget {
  final DocumentItem? initialDocument;

  const LearningHubScreen({
    Key? key,
    this.initialDocument,
  }) : super(key: key);

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen>
    with TickerProviderStateMixin {
  // Services
  final LearningPlatformService _learningService = LearningPlatformService();
  final LearningStorageService _storageService = LearningStorageService();

  // State
  DocumentItem? _selectedDocument;
  LearningMode _currentMode = LearningMode.library;
  bool _isProUser = false;
  bool _isProcessingAI = false;

  // Animation controllers
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize storage
    await _storageService.initialize();
    
    // Check Pro status
    _isProUser = await _learningService.checkProAccess();

    // Set initial document if provided
    if (widget.initialDocument != null) {
      _selectedDocument = widget.initialDocument;
      _currentMode = LearningMode.study;
    }

    // Setup animations
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));

    _fabController.forward();

    setState(() {});
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onDocumentSelected(DocumentItem document) {
    setState(() {
      _selectedDocument = document;
      _currentMode = LearningMode.study;
    });
  }

  void _onModeChanged(LearningMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  Future<void> _handleAIOperation(String operation) async {
    if (_selectedDocument == null) {
      _showError('Please select a document first');
      return;
    }

    if (_selectedDocument!.content.isEmpty) {
      _showError('Document content is not available');
      return;
    }

    // Check Pro access for advanced features
    if (_isAdvancedOperation(operation) && !_isProUser) {
      _showProUpgradeDialog();
      return;
    }

    setState(() {
      _isProcessingAI = true;
    });

    try {
      AIGenerationResult? result;

      switch (operation) {
        case 'summarize':
          result = await _learningService.generateSummary(
            content: _selectedDocument!.content,
          );
          if (result.success && result.text != null) {
            final updatedDoc = _selectedDocument!.copyWith(
              summary: result.text,
              updatedAt: DateTime.now(),
            );
            await _storageService.saveDocument(updatedDoc);
            setState(() {
              _selectedDocument = updatedDoc;
            });
            _showSuccess('Summary generated successfully');
          }
          break;

        case 'quiz':
          result = await _learningService.generateQuiz(
            content: _selectedDocument!.content,
          );
          if (result.success && result.data != null) {
            // Convert result data to quiz questions
            final quizQuestions = _convertToQuizQuestions(result.data!);
            final updatedDoc = _selectedDocument!.copyWith(
              quizQuestions: quizQuestions,
              updatedAt: DateTime.now(),
            );
            await _storageService.saveDocument(updatedDoc);
            setState(() {
              _selectedDocument = updatedDoc;
            });
            _showSuccess('Quiz generated successfully');
          }
          break;

        case 'flashcards':
          result = await _learningService.generateFlashcards(
            content: _selectedDocument!.content,
          );
          if (result.success && result.data != null) {
            final flashcards = _convertToFlashcards(result.data!);
            final updatedDoc = _selectedDocument!.copyWith(
              flashcards: flashcards,
              updatedAt: DateTime.now(),
            );
            await _storageService.saveDocument(updatedDoc);
            setState(() {
              _selectedDocument = updatedDoc;
            });
            _showSuccess('Flashcards generated successfully');
          }
          break;

        case 'study_guide':
          result = await _learningService.generateStudyGuide(
            content: _selectedDocument!.content,
          );
          if (result.success && result.data != null) {
            final studyGuides = _convertToStudyGuides(result.data!);
            final updatedDoc = _selectedDocument!.copyWith(
              studyGuides: studyGuides,
              updatedAt: DateTime.now(),
            );
            await _storageService.saveDocument(updatedDoc);
            setState(() {
              _selectedDocument = updatedDoc;
            });
            _showSuccess('Study guide generated successfully');
          }
          break;

        case 'audio':
          if (!_isProUser) {
            _showProUpgradeDialog();
            return;
          }
          
          final audioResult = await _learningService.generateAudioOverview(
            content: _selectedDocument!.content,
          );
          if (audioResult.success && audioResult.audioPath != null) {
            final audioOverview = AudioOverview(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Audio Overview - ${_selectedDocument!.name}',
              filePath: audioResult.audioPath!,
              duration: audioResult.duration ?? 0,
              createdAt: DateTime.now(),
            );
            
            final updatedDoc = _selectedDocument!.copyWith(
              audioOverview: audioOverview,
              updatedAt: DateTime.now(),
            );
            await _storageService.saveDocument(updatedDoc);
            setState(() {
              _selectedDocument = updatedDoc;
            });
            _showSuccess('Audio overview generated successfully');
          }
          break;

        case 'key_points':
          result = await _learningService.extractKeyPoints(
            content: _selectedDocument!.content,
          );
          if (result.success && result.data != null) {
            final keyPoints = List<String>.from(result.data!);
            final updatedDoc = _selectedDocument!.copyWith(
              keyPoints: keyPoints,
              updatedAt: DateTime.now(),
            );
            await _storageService.saveDocument(updatedDoc);
            setState(() {
              _selectedDocument = updatedDoc;
            });
            _showSuccess('Key points extracted successfully');
          }
          break;
      }

      if (result?.success == false) {
        _showError(result?.error ?? 'AI operation failed');
      }
    } catch (e) {
      _showError('Error during AI operation: $e');
    } finally {
      setState(() {
        _isProcessingAI = false;
      });
    }
  }

  bool _isAdvancedOperation(String operation) {
    return operation == 'audio' || operation == 'study_guide';
  }

  List<QuizQuestion> _convertToQuizQuestions(List<dynamic> data) {
    // Convert AI result to QuizQuestion objects
    // This would depend on the actual structure returned by the AI
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return QuizQuestion(
          id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          question: item['question'] ?? '',
          options: List<String>.from(item['options'] ?? []),
          correctAnswer: item['correct_answer'] ?? '',
          explanation: item['explanation'] ?? '',
          type: item['type'] ?? 'multiple_choice',
          createdAt: DateTime.now(),
        );
      }
      return QuizQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: item.toString(),
        options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
        correctAnswer: 'Option 1',
        explanation: '',
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  List<Flashcard> _convertToFlashcards(List<dynamic> data) {
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return Flashcard(
          id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          front: item['front'] ?? '',
          back: item['back'] ?? '',
          difficulty: item['difficulty'] ?? 'medium',
          createdAt: DateTime.now(),
        );
      }
      return Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        front: 'Front',
        back: 'Back',
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  List<StudyGuide> _convertToStudyGuides(List<dynamic> data) {
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return StudyGuide(
          id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: item['title'] ?? '',
          content: item['content'] ?? '',
          type: item['type'] ?? 'topic',
          keyTerms: List<String>.from(item['key_terms'] ?? []),
          createdAt: DateTime.now(),
        );
      }
      return StudyGuide(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Study Guide',
        content: 'Content',
        type: 'topic',
        keyTerms: [],
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: const Text(
          'This feature is available for Pro users only. '
          'Upgrade to unlock advanced AI features, unlimited documents, '
          'and audio study guides.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to Pro purchase screen
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        actions: [
          if (_selectedDocument != null) ...[
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () => _onModeChanged(LearningMode.chat),
              tooltip: 'Q&A Chat',
            ),
            IconButton(
              icon: const Icon(Icons.audio_file),
              onPressed: () => _onModeChanged(LearningMode.audio),
              tooltip: 'Audio Overview',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
            tooltip: 'Settings',
          ),
        ],
        bottom: _buildTabBar(),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: TabBar(
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(
              icon: const Icon(Icons.library_books),
              text: _currentMode == LearningMode.library ? 'Library' : 'Documents',
            ),
            if (_selectedDocument != null) ...[
              Tab(
                icon: const Icon(Icons.menu_book),
                text: 'Study',
              ),
              Tab(
                icon: const Icon(Icons.quiz),
                text: 'Quiz',
              ),
              Tab(
                icon: const Icon(Icons.flash_on),
                text: 'Cards',
              ),
            ],
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                _onModeChanged(LearningMode.library);
                break;
              case 1:
                _onModeChanged(LearningMode.study);
                break;
              case 2:
                _onModeChanged(LearningMode.quiz);
                break;
              case 3:
                _onModeChanged(LearningMode.flashcards);
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentMode) {
      case LearningMode.library:
        return DocumentLibraryWidget(
          onDocumentSelected: _onDocumentSelected,
          learningService: _learningService,
          storageService: _storageService,
        );
      
      case LearningMode.study:
        if (_selectedDocument == null) {
          return const Center(child: Text('No document selected'));
        }
        return StudyContentWidget(
          document: _selectedDocument!,
          onAIOperation: _handleAIOperation,
          isProcessing: _isProcessingAI,
        );
      
      case LearningMode.quiz:
        if (_selectedDocument?.quizQuestions?.isNotEmpty == true) {
          return QuizWidget(
            questions: _selectedDocument!.quizQuestions!,
            onAnswerSelected: _onQuizAnswerSelected,
          );
        }
        return const Center(child: Text('No quiz available. Generate one first!'));
      
      case LearningMode.flashcards:
        if (_selectedDocument?.flashcards?.isNotEmpty == true) {
          return _buildFlashcardsView();
        }
        return const Center(child: Text('No flashcards available. Generate them first!'));
      
      case LearningMode.audio:
        if (_selectedDocument?.audioOverview != null) {
          return AudioPlayerWidget(
            audioOverview: _selectedDocument!.audioOverview!,
          );
        }
        return const Center(child: Text('No audio overview available. Generate one first!'));
      
      case LearningMode.chat:
        if (_selectedDocument != null) {
          return ChatInterfaceWidget(
            document: _selectedDocument!,
            learningService: _learningService,
          );
        }
        return const Center(child: Text('No document selected for Q&A'));
    }
  }

  Widget _buildFlashcardsView() {
    final flashcards = _selectedDocument!.flashcards!;
    
    return StatefulBuilder(
      builder: (context, setFlashcardState) {
        int currentIndex = 0;
        bool showBack = false;

        return Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: flashcards.where((card) => card.isLearned).length / flashcards.length,
            ),
            
            // Flashcard viewer
            Expanded(
              child: Center(
                child: flashcards.isEmpty
                    ? const Text('No flashcards available')
                    : GestureDetector(
                        onTap: () {
                          setFlashcardState(() {
                            showBack = !showBack;
                          });
                        },
                        child: Container(
                          width: 300,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                showBack 
                                    ? flashcards[currentIndex].back
                                    : flashcards[currentIndex].front,
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            
            // Navigation and controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentIndex > 0 
                        ? () {
                            setFlashcardState(() {
                              if (currentIndex > 0) currentIndex--;
                              showBack = false;
                            });
                          }
                        : null,
                  ),
                  
                  Text('${currentIndex + 1} / ${flashcards.length}'),
                  
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: currentIndex < flashcards.length - 1 
                        ? () {
                            setFlashcardState(() {
                              currentIndex++;
                              showBack = false;
                            });
                          }
                        : null,
                  ),
                  
                  IconButton(
                    icon: Icon(
                      flashcards[currentIndex].isLearned 
                          ? Icons.check_circle 
                          : Icons.circle_outlined,
                      color: flashcards[currentIndex].isLearned 
                          ? Colors.green 
                          : Colors.grey,
                    ),
                    onPressed: () async {
                      final updatedCard = flashcards[currentIndex].copyWith(
                        isLearned: !flashcards[currentIndex].isLearned,
                      );
                      
                      final updatedFlashcards = [...flashcards];
                      updatedFlashcards[currentIndex] = updatedCard;
                      
                      final updatedDoc = _selectedDocument!.copyWith(
                        flashcards: updatedFlashcards,
                      );
                      
                      await _storageService.saveDocument(updatedDoc);
                      
                      setFlashcardState(() {
                        _selectedDocument = updatedDoc;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedDocument == null || _currentMode == LearningMode.library) {
      return null;
    }

    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: _isProcessingAI ? null : () => _showAIToolbar(),
            icon: _isProcessingAI
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isProcessingAI ? 'Processing...' : 'AI Tools'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _showAIToolbar() {
    if (_selectedDocument == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AIToolbarWidget(
        document: _selectedDocument!,
        isProUser: _isProUser,
        onOperationSelected: _handleAIOperation,
        isProcessing: _isProcessingAI,
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                _isProUser ? Icons.star : Icons.star_border,
                color: _isProUser ? Colors.amber : null,
              ),
              title: Text(_isProUser ? 'Pro User' : 'Free User'),
              subtitle: Text(_isProUser ? 'All features unlocked' : 'Upgrade for advanced features'),
              trailing: _isProUser ? null : ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showProUpgradeDialog();
                },
                child: const Text('Upgrade'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear All Data'),
              subtitle: const Text('Remove all documents and progress'),
              onTap: () => _showClearDataDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all documents, trails, and progress. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context); // Close settings
              
              await _storageService.clearAllData();
              setState(() {
                _selectedDocument = null;
                _currentMode = LearningMode.library;
              });
              
              _showSuccess('All data cleared successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onQuizAnswerSelected(String questionId, String selectedAnswer, bool isCorrect) {
    // Update quiz progress
    // This could save performance metrics
  }
}

/// Learning mode enumeration
enum LearningMode {
  library,
  study,
  quiz,
  flashcards,
  audio,
  chat,
}
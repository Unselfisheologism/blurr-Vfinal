import 'package:flutter/material.dart';
import '../models/document_item.dart';

/// Interactive quiz widget for Learning Platform
/// 
/// Displays quiz questions with multiple choice options,
/// provides immediate feedback, and tracks quiz performance.
class QuizWidget extends StatefulWidget {
  final List<QuizQuestion> questions;
  final Function(String questionId, String selectedAnswer, bool isCorrect) onAnswerSelected;
  final bool? showResults;

  const QuizWidget({
    Key? key,
    required this.questions,
    required this.onAnswerSelected,
    this.showResults,
  }) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  
  // For tracking answers
  final Map<String, String> _userAnswers = {};
  final Map<String, bool> _answerCorrectness = {};
  
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _feedbackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No quiz questions available'),
            SizedBox(height: 8),
            Text('Generate a quiz from your document to get started'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Quiz header with progress
        _buildQuizHeader(),
        
        // Current question
        Expanded(
          child: _buildQuestionCard(),
        ),
        
        // Navigation controls
        _buildNavigationControls(),
      ],
    );
  }

  Widget _buildQuizHeader() {
    final progress = _currentQuestionIndex / widget.questions.length;
    final correctPercentage = _totalAnswered > 0 ? 
      (_correctAnswers / _totalAnswered * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Quiz Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                'Score: $_correctAnswers/$_totalAnswered ($correctPercentage%)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(correctPercentage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 4),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${widget.questions.length}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = widget.questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getQuestionTypeLabel(question.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (question.explanation.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: _showExplanation,
                          tooltip: 'Show Explanation',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Answer options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = _selectedAnswer == option;
                final isCorrectOption = option == question.correctAnswer;
                final showCorrectness = _showFeedback;
                
                Color backgroundColor;
                Color borderColor;
                Color textColor;
                
                if (showCorrectness) {
                  if (isCorrectOption) {
                    backgroundColor = Colors.green[100]!;
                    borderColor = Colors.green;
                    textColor = Colors.green[800]!;
                  } else if (isSelected && !isCorrectOption) {
                    backgroundColor = Colors.red[100]!;
                    borderColor = Colors.red;
                    textColor = Colors.red[800]!;
                  } else {
                    backgroundColor = Colors.grey[100]!;
                    borderColor = Colors.grey[300]!;
                    textColor = Colors.grey[600]!;
                  }
                } else {
                  backgroundColor = isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.white;
                  borderColor = isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300]!;
                  textColor = isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.black87;
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: _showFeedback ? null : () => _selectAnswer(option),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: borderColor,
                                width: 2,
                              ),
                              color: showCorrectness && isCorrectOption
                                ? Colors.green
                                : isSelected ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            ),
                            child: showCorrectness && isCorrectOption
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : isSelected
                                ? const Icon(Icons.circle, color: Colors.white, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentQuestionIndex > 0 
              ? _previousQuestion 
              : null,
            tooltip: 'Previous Question',
          ),
          
          const Spacer(),
          
          // Submit/Next button
          if (!_showFeedback && _selectedAnswer != null)
            ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text('Submit Answer'),
            )
          else if (_showFeedback)
            ElevatedButton(
              onPressed: _nextQuestion,
              child: Text(_currentQuestionIndex < widget.questions.length - 1 
                ? 'Next Question' 
                : 'Finish Quiz'),
            ),
          
          const Spacer(),
          
          // Skip button (for practice mode)
          if (!_showFeedback && _selectedAnswer == null)
            TextButton(
              onPressed: _skipQuestion,
              child: const Text('Skip'),
            ),
          
          // Next button (when no answer selected)
          if (_currentQuestionIndex < widget.questions.length - 1 && _showFeedback)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _nextQuestion,
              tooltip: 'Next Question',
            ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    final question = widget.questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == question.correctAnswer;
    
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
      if (isCorrect) _correctAnswers++;
      _totalAnswered++;
      
      _userAnswers[question.id] = _selectedAnswer!;
      _answerCorrectness[question.id] = isCorrect;
    });
    
    // Trigger feedback animation
    _feedbackController.forward();
    
    // Notify parent
    widget.onAnswerSelected(question.id, _selectedAnswer!, isCorrect);
    
    // Auto-advance after delay (optional)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _showFeedback) {
        _nextQuestion();
      }
    });
  }

  void _skipQuestion() {
    setState(() {
      _selectedAnswer = null;
      _currentQuestionIndex++;
      if (_currentQuestionIndex >= widget.questions.length) {
        _showQuizResults();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _selectedAnswer = null;
      _showFeedback = false;
      _currentQuestionIndex++;
      
      if (_currentQuestionIndex >= widget.questions.length) {
        _showQuizResults();
      }
    });
    
    _feedbackController.reset();
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer = _userAnswers[widget.questions[_currentQuestionIndex].id];
        _showFeedback = _answerCorrectness.containsKey(widget.questions[_currentQuestionIndex].id);
        if (_showFeedback) {
          _isCorrect = _answerCorrectness[widget.questions[_currentQuestionIndex].id] ?? false;
        }
      });
    }
  }

  void _showQuizResults() {
    final percentage = widget.questions.isNotEmpty 
      ? (_correctAnswers / widget.questions.length * 100).toInt()
      : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getResultIcon(percentage),
              size: 64,
              color: _getScoreColor(percentage),
            ),
            const SizedBox(height: 16),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(percentage),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You got $_correctAnswers out of ${widget.questions.length} questions correct',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getResultMessage(percentage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            child: const Text('Retry'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showExplanation() {
    final question = widget.questions[_currentQuestionIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Explanation'),
        content: Text(question.explanation.isNotEmpty 
          ? question.explanation 
          : 'No explanation available for this question.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showFeedback = false;
      _correctAnswers = 0;
      _totalAnswered = 0;
      _userAnswers.clear();
      _answerCorrectness.clear();
    });
    _feedbackController.reset();
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'fill_blank':
        return 'Fill in Blank';
      case 'true_false':
        return 'True/False';
      default:
        return 'Question';
    }
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getResultIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  String _getResultMessage(int percentage) {
    if (percentage >= 90) return 'Excellent! You have a strong understanding of the material.';
    if (percentage >= 80) return 'Great job! You have a good grasp of the concepts.';
    if (percentage >= 70) return 'Good work! Review the missed questions to improve further.';
    if (percentage >= 60) return 'Not bad! Consider studying the material more thoroughly.';
    return 'Keep studying! Review the document and try again.';
  }
}
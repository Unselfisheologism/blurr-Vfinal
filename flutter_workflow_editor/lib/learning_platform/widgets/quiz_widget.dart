import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document_item.dart';
import '../state/learning_platform_state.dart';

class QuizWidget extends StatefulWidget {
  const QuizWidget({super.key});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final Map<String, int> _answers = {};

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<LearningPlatformState>().selected;

    if (doc == null) {
      return const _Empty(message: 'Select a document in Library.');
    }

    final questions = doc.quizQuestions;
    if (questions.isEmpty) {
      return const _Empty(message: 'No quiz yet. Tap “Quiz” to generate questions.');
    }

    final answeredCount = _answers.length;
    final correctCount = questions.where((q) => _answers[q.id] == q.answerIndex).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Progress: $answeredCount/${questions.length} • Score: $correctCount',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(_answers.clear),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...questions.map((q) => _QuestionCard(
              question: q,
              selectedIndex: _answers[q.id],
              onSelect: (index) {
                setState(() {
                  _answers[q.id] = index;
                });
              },
            )),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAnswered = selectedIndex != null;
    final isCorrect = isAnswered && selectedIndex == question.answerIndex;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...List.generate(question.choices.length, (index) {
              final choice = question.choices[index];
              final selected = selectedIndex == index;
              final isCorrectChoice = index == question.answerIndex;

              Color? border;
              Color? fill;
              if (isAnswered) {
                if (isCorrectChoice) {
                  border = cs.tertiary;
                  fill = cs.tertiaryContainer;
                } else if (selected && !isCorrectChoice) {
                  border = cs.error;
                  fill = cs.errorContainer;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border ?? cs.outlineVariant),
                ),
                child: RadioListTile<int>(
                  value: index,
                  groupValue: selectedIndex,
                  onChanged: (v) {
                    if (v == null) return;
                    onSelect(v);
                  },
                  dense: true,
                  title: Text(choice),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }),
            if (isAnswered) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_outline : Icons.error_outline,
                    color: isCorrect ? cs.tertiary : cs.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCorrect ? 'Correct' : 'Incorrect',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              if (question.explanation?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  question.explanation!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;

  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

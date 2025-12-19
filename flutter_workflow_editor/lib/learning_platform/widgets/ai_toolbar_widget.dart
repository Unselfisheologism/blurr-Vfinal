import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/learning_platform_state.dart';

class AIToolbarWidget extends StatelessWidget {
  final VoidCallback? onNavigateToStudy;
  final VoidCallback? onNavigateToQuiz;
  final VoidCallback? onNavigateToFlashcards;
  final VoidCallback? onNavigateToAudio;

  const AIToolbarWidget({
    super.key,
    this.onNavigateToStudy,
    this.onNavigateToQuiz,
    this.onNavigateToFlashcards,
    this.onNavigateToAudio,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningPlatformState>();
    final doc = state.selected;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          if (doc == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select a document to unlock learning tools',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${doc.wordCount} words',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  if (state.isBusy) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                _ActionChip(
                  icon: Icons.summarize_outlined,
                  label: 'Summarize',
                  enabled: doc != null && !state.isBusy,
                  onPressed: () async {
                    await _run(context, () => context.read<LearningPlatformState>().generateSummary());
                    onNavigateToStudy?.call();
                  },
                ),
                _ActionChip(
                  icon: Icons.menu_book_outlined,
                  label: 'Study Guide',
                  enabled: doc != null && !state.isBusy,
                  onPressed: () async {
                    await _run(context, () => context.read<LearningPlatformState>().generateStudyGuide());
                    onNavigateToStudy?.call();
                  },
                ),
                _ActionChip(
                  icon: Icons.quiz_outlined,
                  label: 'Quiz',
                  enabled: doc != null && !state.isBusy,
                  onPressed: () async {
                    await _run(context, () => context.read<LearningPlatformState>().generateQuiz());
                    onNavigateToQuiz?.call();
                  },
                ),
                _ActionChip(
                  icon: Icons.style_outlined,
                  label: 'Flashcards',
                  enabled: doc != null && !state.isBusy,
                  onPressed: () async {
                    await _run(context, () => context.read<LearningPlatformState>().generateFlashcards());
                    onNavigateToFlashcards?.call();
                  },
                ),
                _ActionChip(
                  icon: Icons.graphic_eq_outlined,
                  label: 'Audio',
                  pro: true,
                  enabled: doc != null && !state.isBusy,
                  onPressed: () async {
                    await _run(context, () => context.read<LearningPlatformState>().generateAudioOverview());
                    onNavigateToAudio?.call();
                  },
                ),
                _ActionChip(
                  icon: Icons.auto_graph_outlined,
                  label: 'Infographic',
                  pro: true,
                  enabled: doc != null && !state.isBusy,
                  onPressed: () async {
                    final topic = await _askTopic(context);
                    if (topic == null) return;
                    await _run(context, () => context.read<LearningPlatformState>().generateInfographic(topic: topic));
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String?> _askTopic(BuildContext context) async {
    final controller = TextEditingController();

    final topic = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Infographic topic'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'e.g., "Key concepts" or "Timeline"',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return topic?.trim().isEmpty == true ? null : topic;
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool pro;
  final VoidCallback onPressed;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.pro = false,
  });

  @override
  Widget build(BuildContext context) {
    final isProUser = context.watch<LearningPlatformState>().isProUser;
    final showProBadge = pro && !isProUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (showProBadge) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Pro',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ),
            ],
          ],
        ),
        onPressed: enabled
            ? () {
                if (pro && !isProUser) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This feature requires Pro.')),
                  );
                  return;
                }
                onPressed();
              }
            : null,
      ),
    );
  }
}

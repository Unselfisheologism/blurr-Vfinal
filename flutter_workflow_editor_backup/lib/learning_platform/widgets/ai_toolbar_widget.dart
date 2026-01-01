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
                    final req = await _askInfographicRequest(context);
                    if (req == null) return;
                    await _run(
                      context,
                      () => context.read<LearningPlatformState>().generateInfographic(
                            topic: req.topic,
                            method: req.method,
                            data: req.data,
                          ),
                    );
                    onNavigateToStudy?.call();
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

  Future<_InfographicRequest?> _askInfographicRequest(BuildContext context) async {
    final topicController = TextEditingController();
    final dataController = TextEditingController();

    var method = 'd3js';

    final req = await showDialog<_InfographicRequest>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Infographic'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: topicController,
                    decoration: const InputDecoration(
                      labelText: 'Topic',
                      hintText: 'e.g., Key concepts, Timeline, Comparison',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: method,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'd3js',
                        child: Text('D3.js (SVG, fast)'),
                      ),
                      DropdownMenuItem(
                        value: 'nano_banana_pro',
                        child: Text('Nano Banana Pro (AI image)'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => method = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dataController,
                    decoration: const InputDecoration(
                      labelText: 'Optional data (JSON)',
                      hintText: '[10, 20, 30] or [{"label":"A","value":10}]',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 6,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final topic = topicController.text.trim();
                    if (topic.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a topic.')),
                      );
                      return;
                    }
                    Navigator.of(context).pop(
                      _InfographicRequest(
                        topic: topic,
                        method: method,
                        data: dataController.text.trim().isEmpty ? null : dataController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );

    topicController.dispose();
    dataController.dispose();

    return req;
  }
}

class _InfographicRequest {
  final String topic;
  final String method;
  final String? data;

  const _InfographicRequest({
    required this.topic,
    required this.method,
    this.data,
  });
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

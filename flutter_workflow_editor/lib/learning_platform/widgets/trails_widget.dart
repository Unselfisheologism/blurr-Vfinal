import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_trail.dart';
import '../state/learning_platform_state.dart';

class TrailsWidget extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const TrailsWidget({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningPlatformState>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Learning Trails',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: state.isBusy
                    ? null
                    : () async {
                        try {
                          final trail = await context
                              .read<LearningPlatformState>()
                              .createQuickTrailForSelectedDocument();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Created trail: ${trail.title}')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                icon: const Icon(Icons.add),
                label: const Text('Quick trail'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Trails are LearnHouse-inspired sequences of activities. Create one for the selected document, then run steps one-by-one.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: state.trails.isEmpty
              ? const _Empty()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: state.trails.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final trail = state.trails[index];
                    return _TrailCard(
                      trail: trail,
                      isBusy: state.isBusy,
                      onRunNext: () async {
                        try {
                          final step = await context
                              .read<LearningPlatformState>()
                              .runNextTrailStep(trail.id);
                          if (!context.mounted) return;

                          if (step == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Trail completed.')),
                            );
                            return;
                          }

                          onNavigateToTab?.call(_tabForActivity(step.activityType));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ran: ${step.title}')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      onReset: () async {
                        try {
                          await context
                              .read<LearningPlatformState>()
                              .resetTrailProgress(trail.id);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete trail?'),
                              content: Text('Remove "${trail.title}" from this device?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await context.read<LearningPlatformState>().deleteTrail(trail.id);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  int _tabForActivity(String activityType) {
    // Must match LearningHubScreen's tab order.
    return switch (activityType) {
      LearningActivityType.summary || LearningActivityType.studyGuide || LearningActivityType.infographic => 1,
      LearningActivityType.quiz => 2,
      LearningActivityType.flashcards => 3,
      LearningActivityType.audioOverview => 4,
      LearningActivityType.chatQuestion => 5,
      _ => 0,
    };
  }
}

class _TrailCard extends StatelessWidget {
  final LearningTrail trail;
  final bool isBusy;
  final VoidCallback onRunNext;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  const _TrailCard({
    required this.trail,
    required this.isBusy,
    required this.onRunNext,
    required this.onReset,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (trail.progress * 100).round();
    final step = trail.nextStep;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trail.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    switch (v) {
                      case 'reset':
                        onReset();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(value: 'reset', child: Text('Reset progress')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ];
                  },
                )
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: trail.progress, minHeight: 8),
            const SizedBox(height: 6),
            Text(
              trail.steps.isEmpty
                  ? 'No steps'
                  : trail.isComplete
                      ? '100% • Completed'
                      : '$pct% • Step ${trail.currentStepIndex + 1}/${trail.steps.length}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            if (step != null) ...[
              const SizedBox(height: 10),
              Text(
                'Next: ${step.title}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ]
            else ...[
              const SizedBox(height: 10),
              Text(
                'Completed',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy || trail.isComplete ? null : onRunNext,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(trail.isComplete ? 'Done' : 'Run next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No trails yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a document in Library and tap “Quick trail” to create a learning sequence.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

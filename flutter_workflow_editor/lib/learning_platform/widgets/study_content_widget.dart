import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/learning_platform_state.dart';

class StudyContentWidget extends StatelessWidget {
  const StudyContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningPlatformState>();
    final doc = state.selected;

    if (doc == null) {
      return _EmptyState(
        title: 'No document selected',
        message: 'Open Library and tap a document to start studying.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _Section(
          title: 'Summary',
          subtitle: doc.summaryMarkdown?.isNotEmpty == true
              ? null
              : 'Tap “Summarize” to generate a NotebookLM-style overview.',
          child: doc.summaryMarkdown?.isNotEmpty == true
              ? SelectableText(doc.summaryMarkdown!)
              : const Text('No summary yet.'),
        ),
        _Section(
          title: 'Study Guide',
          subtitle: doc.studyGuideMarkdown?.isNotEmpty == true
              ? null
              : 'Tap “Study Guide” to generate a structured guide with key terms and questions.',
          child: doc.studyGuideMarkdown?.isNotEmpty == true
              ? SelectableText(doc.studyGuideMarkdown!)
              : const Text('No study guide yet.'),
        ),
        _Section(
          title: 'Source text',
          subtitle: '${doc.wordCount} words • ${doc.charCount} chars',
          child: SelectableText(doc.content),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

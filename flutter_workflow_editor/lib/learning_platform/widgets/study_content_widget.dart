import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          title: 'Infographic',
          subtitle: (doc.infographicFilePath?.trim().isNotEmpty == true)
              ? null
              : state.isProUser
                  ? 'Tap “Infographic” to generate a visual overview.'
                  : 'Infographics are a Pro feature.',
          child: (doc.infographicFilePath?.trim().isNotEmpty == true)
              ? _InfographicPreview(path: doc.infographicFilePath!)
              : const Text('No infographic yet.'),
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

class _InfographicPreview extends StatelessWidget {
  final String path;

  const _InfographicPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    final file = File(path);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        final exists = snapshot.data ?? false;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!exists) {
          return const Text('Infographic file not found.');
        }

        final lower = path.toLowerCase();
        final Widget preview = lower.endsWith('.svg')
            ? SvgPicture.file(file, fit: BoxFit.contain)
            : Image.file(file, fit: BoxFit.contain);

        return InkWell(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) {
                return Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4,
                      child: preview,
                    ),
                  ),
                );
              },
            );
          },
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: preview,
                ),
              ),
            ),
          ),
        );
      },
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

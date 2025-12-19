import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'models/document_item.dart';
import 'state/learning_platform_state.dart';
import 'widgets/ai_toolbar_widget.dart';
import 'widgets/audio_overview_widget.dart';
import 'widgets/chat_interface_widget.dart';
import 'widgets/document_library_widget.dart';
import 'widgets/flashcards_widget.dart';
import 'widgets/quiz_widget.dart';
import 'widgets/study_content_widget.dart';
import 'widgets/trails_widget.dart';

/// NotebookLM-inspired AI-native learning hub.
///
/// Mobile-first flow:
/// 1) Upload documents/notes into a local library.
/// 2) Generate learning artifacts (summary, study guide, quizzes, audio).
/// 3) Chat with your knowledge, scoped to the selected document.
class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LearningPlatformState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningPlatformState>();
    final doc = state.selected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        actions: [
          if (state.isProUser)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Pro',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            enabled: doc != null,
            onSelected: (value) => _handleMenu(context, value),
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'export_markdown', child: Text('Export notes (Markdown)')),
                PopupMenuItem(value: 'export_json', child: Text('Export document (JSON)')),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AIToolbarWidget(
            onNavigateToStudy: () => setState(() => _tabIndex = 1),
            onNavigateToQuiz: () => setState(() => _tabIndex = 2),
            onNavigateToFlashcards: () => setState(() => _tabIndex = 3),
            onNavigateToAudio: () => setState(() => _tabIndex = 4),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                const DocumentLibraryWidget(),
                const StudyContentWidget(),
                const QuizWidget(),
                const FlashcardsWidget(),
                const AudioOverviewWidget(),
                const ChatInterfaceWidget(),
                TrailsWidget(onNavigateToTab: (i) => setState(() => _tabIndex = i)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.library_books_outlined), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Study'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'Quiz'),
          NavigationDestination(icon: Icon(Icons.style_outlined), label: 'Cards'),
          NavigationDestination(icon: Icon(Icons.graphic_eq_outlined), label: 'Audio'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Trails'),
        ],
      ),
    );
  }

  Future<void> _handleMenu(BuildContext context, String value) async {
    final doc = context.read<LearningPlatformState>().selected;
    if (doc == null) return;

    switch (value) {
      case 'export_markdown':
        final md = _buildMarkdownExport(doc);
        await Share.share(md, subject: 'Learning notes - ${doc.title}');
        break;
      case 'export_json':
        final json = const JsonEncoder.withIndent('  ').convert(doc.toJson());
        await Share.share(json, subject: 'Learning document - ${doc.title}');
        break;
    }
  }

  String _buildMarkdownExport(DocumentItem doc) {
    final buffer = StringBuffer();

    buffer.writeln('# ${doc.title}');
    buffer.writeln();

    if (doc.summaryMarkdown?.trim().isNotEmpty == true) {
      buffer.writeln('## Summary');
      buffer.writeln(doc.summaryMarkdown!.trim());
      buffer.writeln();
    }

    if (doc.studyGuideMarkdown?.trim().isNotEmpty == true) {
      buffer.writeln('## Study Guide');
      buffer.writeln(doc.studyGuideMarkdown!.trim());
      buffer.writeln();
    }

    if (doc.quizQuestions.isNotEmpty) {
      buffer.writeln('## Quiz');
      for (var i = 0; i < doc.quizQuestions.length; i++) {
        final q = doc.quizQuestions[i];
        buffer.writeln('${i + 1}. ${q.question}');
        for (var c = 0; c < q.choices.length; c++) {
          final prefix = c == q.answerIndex ? '**' : '';
          final suffix = c == q.answerIndex ? '**' : '';
          buffer.writeln('   - $prefix${q.choices[c]}$suffix');
        }
        if (q.explanation?.trim().isNotEmpty == true) {
          buffer.writeln('   - _${q.explanation!.trim()}_');
        }
        buffer.writeln();
      }
    }

    if (doc.flashcards.isNotEmpty) {
      buffer.writeln('## Flashcards');
      for (final c in doc.flashcards) {
        buffer.writeln('- **${c.front}** — ${c.back}');
      }
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln('_Generated locally in Blurr AI Learning Hub._');

    return buffer.toString();
  }
}

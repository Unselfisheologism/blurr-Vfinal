import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document_item.dart';
import '../state/learning_platform_state.dart';

class DocumentLibraryWidget extends StatefulWidget {
  const DocumentLibraryWidget({super.key});

  @override
  State<DocumentLibraryWidget> createState() => _DocumentLibraryWidgetState();
}

class _DocumentLibraryWidgetState extends State<DocumentLibraryWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningPlatformState>();
    final query = _searchController.text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? state.documents
        : state.documents.where((d) {
            return d.title.toLowerCase().contains(query) ||
                (d.fileName?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search library…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: state.isBusy ? null : () => _uploadDocument(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: state.isBusy ? null : () => _createNote(context),
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('New note'),
              ),
              const SizedBox(width: 12),
              if (!state.isProUser)
                Text(
                  'Free: ${state.documents.length}/5 docs',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? _EmptyLibrary(isBusy: state.isBusy)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final selected = state.selected?.id == doc.id;

                    return Dismissible(
                      key: ValueKey('doc_${doc.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context, doc),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      child: Card(
                        elevation: selected ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => state.selectDocument(doc),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                _DocIcon(doc: doc),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _subtitle(doc),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: -8,
                                        children: [
                                          if (doc.summaryMarkdown?.isNotEmpty == true)
                                            const _Pill(label: 'Summary'),
                                          if (doc.studyGuideMarkdown?.isNotEmpty == true)
                                            const _Pill(label: 'Study guide'),
                                          if (doc.quizQuestions.isNotEmpty)
                                            _Pill(label: 'Quiz (${doc.quizQuestions.length})'),
                                          if (doc.flashcards.isNotEmpty)
                                            _Pill(label: 'Cards (${doc.flashcards.length})'),
                                          if (doc.audioFilePath?.isNotEmpty == true)
                                            const _Pill(label: 'Audio'),
                                          if (doc.infographicFilePath?.isNotEmpty == true)
                                            const _Pill(label: 'Infographic'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _subtitle(DocumentItem doc) {
    final type = doc.sourceType == LearningDocumentSourceType.note ? 'Note' : 'File';
    final ext = doc.fileExtension;
    final stats = doc.wordCount == 0 ? '${doc.charCount} chars' : '${doc.wordCount} words';
    if (type == 'File' && ext != null && ext.isNotEmpty) {
      return '$type • .$ext • $stats';
    }
    return '$type • $stats';
  }

  Future<void> _uploadDocument(BuildContext context) async {
    final state = context.read<LearningPlatformState>();

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'txt', 'md', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        _showSnack(context, 'Failed to read file bytes.');
        return;
      }

      final doc = await state.importFile(fileName: file.name, bytes: bytes);
      state.selectDocument(doc);
      _showSnack(context, 'Imported "${file.name}"');
    } catch (e) {
      _showSnack(context, e.toString());
    }
  }

  Future<void> _createNote(BuildContext context) async {
    final state = context.read<LearningPlatformState>();

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final created = await showModalBottomSheet<DocumentItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Paste notes',
                  border: OutlineInputBorder(),
                ),
                minLines: 6,
                maxLines: 12,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          final doc = await state.createNote(
                            title: titleController.text,
                            content: contentController.text,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop(doc);
                          }
                        } catch (e) {
                          _showSnack(context, e.toString());
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    titleController.dispose();
    contentController.dispose();

    if (created != null) {
      state.selectDocument(created);
    }
  }

  Future<bool> _confirmDelete(BuildContext context, DocumentItem doc) async {
    final state = context.read<LearningPlatformState>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete document?'),
          content: Text('This will remove "${doc.title}" from your local library.'),
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

    if (shouldDelete == true) {
      await state.delete(doc.id);
      if (context.mounted) {
        _showSnack(context, 'Deleted');
      }
      return true;
    }

    return false;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _DocIcon extends StatelessWidget {
  final DocumentItem doc;

  const _DocIcon({required this.doc});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final icon = switch (doc.sourceType) {
      LearningDocumentSourceType.note => Icons.sticky_note_2_outlined,
      _ => Icons.description_outlined,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: colorScheme.onPrimaryContainer),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  final bool isBusy;

  const _EmptyLibrary({required this.isBusy});

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
              isBusy ? 'Working…' : 'Your library is empty',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a PDF, DOCX, or notes to start generating summaries, quizzes, and flashcards.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

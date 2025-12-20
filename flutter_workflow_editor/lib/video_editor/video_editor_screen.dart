import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

import 'state/video_editor_state.dart';
import 'models/video_track.dart';
import 'widgets/media_bin_drawer.dart';
import 'widgets/preview/video_preview_panel.dart';
import 'widgets/timeline/timeline_view.dart';
import 'widgets/video_ai_toolbar.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // Initialize once the provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoEditorState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MediaBinDrawer(),
      appBar: AppBar(
        title: const Text('AI Video Editor'),
        actions: [
          Consumer<VideoEditorState>(
            builder: (context, state, child) {
              return Row(
                children: [
                  IconButton(
                    tooltip: 'Undo',
                    icon: const Icon(Icons.undo),
                    onPressed: state.canUndo ? state.undo : null,
                  ),
                  IconButton(
                    tooltip: 'Redo',
                    icon: const Icon(Icons.redo),
                    onPressed: state.canRedo ? state.redo : null,
                  ),
                  IconButton(
                    tooltip: 'Import media',
                    icon: const Icon(Icons.video_library),
                    onPressed: state.isLoading ? null : state.importMediaFromDevice,
                  ),
                  IconButton(
                    tooltip: 'Add track',
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () => _showAddTrackSheet(context),
                  ),
                  IconButton(
                    tooltip: 'Delete clip',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: state.selectedClip == null ? null : state.deleteSelectedClip,
                  ),
                  IconButton(
                    tooltip: 'Export',
                    icon: state.isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.ios_share),
                    onPressed: state.isExporting ? null : () => _handleExport(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<VideoEditorState>(
          builder: (context, state, child) {
            _maybeShowError(context, state);

            if (state.isLoading && !state.hasProject) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Preview
                const Expanded(
                  child: VideoPreviewPanel(),
                ),

                // AI toolbar
                Material(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  child: VideoAIToolbar(
                    onGenerateClip: () => _handleGenerateClip(context),
                    onAutoCaptions: () => _handleAutoCaptions(context),
                    onSmartTransitions: () => _handleSmartTransitions(context),
                    onEnhance: () => _handleEnhance(context),
                  ),
                ),

                // Timeline
                SizedBox(
                  height: 260,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                    ),
                    child: const TimelineView(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _maybeShowError(BuildContext context, VideoEditorState state) {
    final error = state.error;
    if (error == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      state.clearError();
    });
  }

  Future<void> _handleGenerateClip(BuildContext context) async {
    final prompt = await _promptDialog(
      context,
      title: 'Generate clip',
      hintText: 'e.g., "A cinematic sunrise over mountains, 5 seconds"',
    );
    if (prompt == null || prompt.trim().isEmpty) return;

    await context.read<VideoEditorState>().generateClipFromPrompt(prompt.trim());
  }

  Future<void> _handleAutoCaptions(BuildContext context) async {
    final srt = await context.read<VideoEditorState>().generateCaptionsForSelectedClip();
    if (!context.mounted || srt == null) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Captions (SRT)'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(child: Text(srt)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _handleSmartTransitions(BuildContext context) async {
    await context.read<VideoEditorState>().suggestAndApplyTransitions();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transitions suggested and applied.')),
    );
  }

  Future<void> _handleEnhance(BuildContext context) async {
    final intent = await _promptDialog(
      context,
      title: 'Enhance video',
      hintText: 'e.g., "Reduce noise and boost contrast"',
      optional: true,
    );

    await context.read<VideoEditorState>().enhanceSelectedClip(intent: intent?.trim().isEmpty ?? true ? null : intent!.trim());
  }

  Future<void> _handleExport(BuildContext context) async {
    final state = context.read<VideoEditorState>();

    final project = state.project;
    if (project == null) return;

    // Optional burn-in captions toggle.
    var burnIn = project.burnInCaptions;
    if (project.captionsSrt != null && project.captionsSrt!.trim().isNotEmpty) {
      final chosen = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Export options'),
              content: CheckboxListTile(
                value: burnIn,
                onChanged: (v) {
                  setLocalState(() => burnIn = v ?? false);
                },
                title: const Text('Burn captions into video'),
                subtitle: const Text('If off, captions are exported as a separate .srt file.'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Export'),
                ),
              ],
            );
          },
        ),
      );

      if (chosen != true) return;
      state.setBurnInCaptions(burnIn);
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Exporting… (FFmpeg)\nThis may take a while for longer timelines.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );

    await state.exportProject();

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (state.error == null) {
      final path = state.lastExportPath;
      if (path == null || path.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export complete.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported: $path'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () {
              Share.shareXFiles([XFile(path)], text: 'Exported with Twent Video Editor');
            },
          ),
        ),
      );
    }
  }

  Future<String?> _promptDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    bool optional = false,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          autofocus: true,
          minLines: 1,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(optional ? '' : null),
            child: Text(optional ? 'Skip' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Run'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Future<void> _showAddTrackSheet(BuildContext context) async {
    final state = context.read<VideoEditorState>();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('Add video track'),
              onTap: () {
                state.addTrack(VideoTrackType.video);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Add audio track'),
              onTap: () {
                state.addTrack(VideoTrackType.audio);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.closed_caption),
              title: const Text('Add captions track'),
              onTap: () {
                state.addTrack(VideoTrackType.captions);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

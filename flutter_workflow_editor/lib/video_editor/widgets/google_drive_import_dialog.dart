import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/google_drive_file.dart';
import '../state/video_editor_state.dart';

class GoogleDriveImportDialog extends StatefulWidget {
  const GoogleDriveImportDialog({super.key});

  @override
  State<GoogleDriveImportDialog> createState() => _GoogleDriveImportDialogState();
}

class _GoogleDriveImportDialogState extends State<GoogleDriveImportDialog> {
  bool _loading = true;
  bool _requiresAuth = false;
  String? _error;

  List<GoogleDriveFile> _files = [];
  final Set<String> _selectedIds = {};

  bool _importView = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _requiresAuth = false;
      _error = null;
      _files = [];
      _selectedIds.clear();
      _importView = false;
    });

    final state = context.read<VideoEditorState>();
    final result = await state.listGoogleDriveVideoFiles();

    setState(() {
      _loading = false;
      _requiresAuth = result.requiresAuth;
      _error = result.error;
      _files = result.files;
      if (_files.length <= 5) {
        _selectedIds.addAll(_files.map((f) => f.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import from Google Drive'),
      content: SizedBox(
        width: 520,
        child: _buildContent(context),
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_requiresAuth) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'To import videos from Drive, please sign in and grant read-only Drive access.\n\n'
            'We do not expose your access token to Flutter code. All Drive API calls run on the native side.',
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      );
    }

    if (_importView) {
      return Consumer<VideoEditorState>(
        builder: (context, state, _) {
          final selected = _files.where((f) => _selectedIds.contains(f.id)).toList();

          if (selected.isEmpty) {
            return const Text('No files selected.');
          }

          return ListView.separated(
            shrinkWrap: true,
            itemCount: selected.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final file = selected[index];
              final importStatus = state.driveImports[file.id];
              final status = importStatus?.status ?? 'queued';
              final progress = importStatus?.progress ?? 0.0;
              final error = importStatus?.error;

              final barValue = switch (status) {
                'completed' => 1.0,
                'error' => 0.0,
                _ => progress,
              };

              return ListTile(
                dense: true,
                title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: barValue),
                    const SizedBox(height: 6),
                    Text(
                      error != null ? 'Error: $error' : status,
                      style: TextStyle(color: error != null ? Theme.of(context).colorScheme.error : null),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    if (_files.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No video files found in your Google Drive.'),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _files.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final file = _files[index];
              final selected = _selectedIds.contains(file.id);

              return CheckboxListTile(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedIds.add(file.id);
                    } else {
                      _selectedIds.remove(file.id);
                    }
                  });
                },
                title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(file.mimeType),
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_loading) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }

    if (_requiresAuth) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await context.read<VideoEditorState>().authenticateGoogleDrive();
            if (!mounted) return;
            await Future<void>.delayed(const Duration(milliseconds: 400));
            await _load();
          },
          child: const Text('Sign in with Google'),
        ),
      ];
    }

    if (_importView) {
      final state = context.watch<VideoEditorState>();
      final active = state.driveImports.values.any((s) => s.isActive);

      return [
        TextButton(
          onPressed: active ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: _files.isEmpty
            ? null
            : () {
                setState(() {
                  if (_selectedIds.length == _files.length) {
                    _selectedIds.clear();
                  } else {
                    _selectedIds
                      ..clear()
                      ..addAll(_files.map((f) => f.id));
                  }
                });
              },
        child: Text(_selectedIds.length == _files.length ? 'Select none' : 'Select all'),
      ),
      FilledButton(
        onPressed: _selectedIds.isEmpty
            ? null
            : () async {
                final selected = _files.where((f) => _selectedIds.contains(f.id)).toList();
                await context.read<VideoEditorState>().startGoogleDriveImports(selected);
                if (!mounted) return;
                setState(() => _importView = true);
              },
        child: const Text('Import'),
      ),
    ];
  }
}

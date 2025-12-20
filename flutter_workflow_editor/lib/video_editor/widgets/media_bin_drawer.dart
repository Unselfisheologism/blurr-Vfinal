import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_asset.dart';
import '../state/video_editor_state.dart';

class MediaBinDrawer extends StatelessWidget {
  const MediaBinDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Consumer<VideoEditorState>(
          builder: (context, state, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        'Media Bin',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Import',
                        icon: const Icon(Icons.add),
                        onPressed: state.isLoading ? null : () => state.importMediaFromDevice(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.mediaBin.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Import videos, photos, and audio to start editing.'),
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.mediaBin.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final asset = state.mediaBin[index];
                            return ListTile(
                              leading: _buildLeading(asset),
                              title: Text(asset.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(_subtitle(asset)),
                              onTap: () {
                                Navigator.of(context).pop();
                                state.addAssetToTimeline(asset);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeading(MediaAsset asset) {
    final icon = switch (asset.type) {
      MediaAssetType.video => Icons.movie,
      MediaAssetType.image => Icons.photo,
      MediaAssetType.audio => Icons.music_note,
    };

    if (asset.type == MediaAssetType.image && !asset.isNetwork) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(asset.uri),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(icon),
        ),
      );
    }

    return CircleAvatar(child: Icon(icon));
  }

  String _subtitle(MediaAsset asset) {
    final d = asset.durationMs;
    final durationText = d == null ? '' : _formatMs(d);

    return '${mediaAssetTypeToString(asset.type)}${durationText.isEmpty ? '' : ' • $durationText'}';
  }

  String _formatMs(int ms) {
    final totalSec = (ms / 1000).round();
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

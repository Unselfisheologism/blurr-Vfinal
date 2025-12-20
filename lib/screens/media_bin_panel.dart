import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_bin.dart';
import '../providers/media_bin_provider.dart';
import '../providers/timeline_provider.dart';
import '../services/media_service.dart';

class MediaBinPanel extends ConsumerWidget {
  const MediaBinPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaBinState = ref.watch(mediaBinProvider);
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildHeader(context, ref, mediaBinState),
          _buildFolderSelector(mediaBinState),
          _buildSearchBar(mediaBinState),
          _buildFilterChips(ref),
          Expanded(
            child: _buildAssetGrid(context, ref, mediaBinState),
          ),
          _buildImportButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, MediaBinState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Media Bin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Media',
            onPressed: () => ref.read(mediaBinProvider.notifier).refreshMediaAssets(),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSelector(MediaBinState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.folder, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: state.selectedFolderId ?? 'all',
              isExpanded: true,
              underline: const SizedBox(),
              items: state.folders.map((folder) {
                return DropdownMenuItem(
                  value: folder.id,
                  child: Text(folder.name),
                );
              }).toList(),
              onChanged: (folderId) {
                if (folderId != null) {
                  // Handle folder selection through provider
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MediaBinState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search media...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: state.searchQuery?.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Clear search
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (query) {
          // Update search query
        },
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref) {
    const filters = [
      (ClipType.video, 'Video', Icons.videocam),
      (ClipType.audio, 'Audio', Icons.audiotrack),
      (ClipType.image, 'Image', Icons.image),
      (ClipType.text, 'Text', Icons.text_fields),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: filters.map((filter) {
          final (type, label, icon) = filter;
          final isSelected = false; // This would come from state
          
          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                Text(label),
              ],
            ),
            onSelected: (selected) {
              ref.read(mediaBinProvider.notifier).toggleFilter(type);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssetGrid(BuildContext context, WidgetRef ref, MediaBinState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(state.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(mediaBinProvider.notifier).loadMediaAssets(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final assets = state.filteredAssets;
    
    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No media assets found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showImportDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Import Media'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return _buildAssetCard(context, ref, asset);
      },
    );
  }

  Widget _buildAssetCard(BuildContext context, WidgetRef ref, MediaAsset asset) {
    return Card(
      child: InkWell(
        onTap: () => _handleAssetTap(context, ref, asset),
        onDoubleTap: () => _handleAssetDoubleTap(context, ref, asset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildAssetThumbnail(asset),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    asset.displayDuration.isNotEmpty
                        ? asset.displayDuration
                        : asset.type.toString().split('.').last,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetThumbnail(MediaAsset asset) {
    if (asset.thumbnailPath != null) {
      return Image.file(
        File(asset.thumbnailPath!),
        fit: BoxFit.cover,
      );
    }

    // Placeholder based on asset type
    IconData iconData;
    Color color;
    
    switch (asset.type) {
      case ClipType.video:
        iconData = Icons.videocam;
        color = Colors.orange;
        break;
      case ClipType.audio:
        iconData = Icons.audiotrack;
        color = Colors.green;
        break;
      case ClipType.image:
        iconData = Icons.image;
        color = Colors.purple;
        break;
      case ClipType.text:
        iconData = Icons.text_fields;
        color = Colors.blue;
        break;
      case ClipType.transition:
        iconData = Icons.transform;
        color = Colors.pink;
        break;
    }

    return Container(
      color: color.withOpacity(0.1),
      child: Icon(
        iconData,
        size: 48,
        color: color,
      ),
    );
  }

  Widget _buildImportButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _showImportDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Import Media'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }

  void _handleAssetTap(BuildContext context, WidgetRef ref, MediaAsset asset) {
    // Preview asset
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Previewing ${asset.name}'),
      ),
    );
  }

  void _handleAssetDoubleTap(BuildContext context, WidgetRef ref, MediaAsset asset) {
    // Add asset to timeline
    ref.read(timelineNotifierProvider.notifier).addClip(
      '', // trackId would be determined based on asset type
      VideoClip(
        id: 'clip_${DateTime.now().millisecondsSinceEpoch}',
        name: asset.name,
        filePath: asset.filePath,
        type: asset.type,
        startTime: ref.read(timelineStateProvider).currentTime,
        duration: asset.duration ?? 5.0,
        color: _getClipColor(asset.type),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${asset.name} to timeline'),
      ),
    );
  }

  Color _getClipColor(ClipType type) {
    switch (type) {
      case ClipType.video:
        return Colors.orange;
      case ClipType.audio:
        return Colors.green;
      case ClipType.image:
        return Colors.purple;
      case ClipType.text:
        return Colors.blue;
      case ClipType.transition:
        return Colors.pink;
    }
  }

  Future<void> _showImportDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Media'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('Audio'),
              onTap: () => Navigator.pop(context, 'audio'),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      await ref.read(mediaBinProvider.notifier).importMediaAsset(
        _parseClipType(result),
      );
    }
  }

  ClipType _parseClipType(String type) {
    switch (type) {
      case 'video':
        return ClipType.video;
      case 'audio':
        return ClipType.audio;
      case 'image':
        return ClipType.image;
      default:
        return ClipType.video;
    }
  }
}

  Widget _buildProBadge() {
    final proService = ref.read(proGatingServiceProvider);
    
    if (!proService.showProBadges) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _loadProject(Map<String, dynamic> args) async {
    final projectName = args['project_name']?.toString();
    final projectPath = args['project_path']?.toString();
    
    if (mounted) {
      await ref.read(timelineNotifierProvider).loadProject(projectName, projectPath);
    }
  }

  void _handleClipOption(String option, VideoClip clip) {
    switch (option) {
      case 'delete':
        ref.read(timelineNotifierProvider.notifier).deleteClip(clip.id, '');
        break;
      case 'enhance':
        ref.read(timelineNotifierProvider.notifier).enhanceVideo();
        break;
      case 'captions':
        ref.read(timelineNotifierProvider.notifier).generateAiCaptions();
        break;
    }
  }

  void _showBottomSheet(VideoClip clip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Clip'),
            onTap: () {
              Navigator.pop(context);
              _handleClipOption('delete', clip);
            },
          ),
          if (clip.type == ClipType.video) ...[
            ListTile(
              leading: const Icon(Icons.auto_fix_high),
              title: const Text('Enhance Video'),
              onTap: () {
                Navigator.pop(context);
                _handleClipOption('enhance', clip);
              },
            ),
            ListTile(
              leading: const Icon(Icons.closed_caption),
              title: const Text('Generate Captions'),
              onTap: () {
                Navigator.pop(context);
                _handleClipOption('captions', clip);
              },
            ),
          ],
        ],
      ),
    );
  }
}

@riverpod
TimelineNotifier timelineNotifier(TimelineNotifierRef ref) {
  return TimelineNotifier(
    ref.watch(videoEditorServiceProvider),
    ref.watch(proGatingServiceProvider),
  );
}

@riverpod
TimelineState timelineState(TimelineStateRef ref) {
  return ref.watch(timelineNotifierProvider);
}
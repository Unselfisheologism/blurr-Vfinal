import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_clip.dart';
import '../models/video_track.dart';
import '../models/media_bin.dart';
import '../providers/timeline_provider.dart';
import '../providers/media_bin_provider.dart';
import '../services/video_editor_service.dart';
import '../services/pro_gating_service.dart';
import 'media_bin_panel.dart';
import 'timeline_panel.dart';
import 'preview_panel.dart';
import 'ai_toolbar.dart';
import 'timeline_controls.dart';

class VideoEditorScreen extends ConsumerStatefulWidget {
  const VideoEditorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends ConsumerState<VideoEditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditor();
    });
  }

  Future<void> _initializeEditor() async {
    // Load project if provided via Intent extras
    // In production, this would be passed from the Kotlin activity
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final projectName = args['project_name']?.toString();
      final projectPath = args['project_path']?.toString();
      
      if (mounted) {
        await ref.read(timelineNotifierProvider).loadProject(projectName, projectPath);
      }
    } else {
      // Initialize with default tracks
      ref.read(timelineNotifierProvider.notifier)._initializeDefaultTracks();
    }

    // Load media assets
    ref.read(mediaBinProvider.notifier).loadMediaAssets();
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineStateProvider);
    
    return Scaffold(
      appBar: _buildAppBar(timelineState.projectName),
      body: _buildBody(timelineState),
      floatingActionButton: _buildFloatingActionButton(timelineState),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar(String? projectName) {
    return AppBar(
      title: Text(projectName ?? 'Video Editor'),
      actions: [
        _buildProBadge(),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: _showSettingsDialog,
        ),
        IconButton(
          icon: const Icon(Icons.help),
          tooltip: 'Help',
          onPressed: _showHelpDialog,
        ),
      ],
    );
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

  Widget _buildBody(TimelineState timelineState) {
    return Row(
      children: [
        // Left: Media Bin Panel (collapsible)
        _buildMediaBinPanel(),
        
        // Center: Main Editor Area
        Expanded(
          child: Column(
            children: [
              // Video Preview Area
              _buildPreviewPanel(timelineState),
              
              // AI Toolbar
              _buildAiToolbar(),
              
              // Timeline Controls
              _buildTimelineControls(),
              
              // Timeline Panel
              Expanded(
                child: TimelinePanel(
                  timelineState: timelineState,
                  onClipSelected: (clip, track) {
                    ref.read(timelineNotifierProvider.notifier)
                        .selectClip(clip?.id, track?.id);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaBinPanel() {
    return const SizedBox(
      width: 280,
      child: MediaBinPanel(),
    );
  }

  Widget _buildPreviewPanel(TimelineState timelineState) {
    return PreviewPanel(
      currentTime: timelineState.currentTime,
      isPlaying: timelineState.isPlaying,
      duration: timelineState.projectDuration,
      onPlayPause: () => ref.read(timelineNotifierProvider.notifier).togglePlayback(),
      onSeek: (time) => ref.read(timelineStateProvider.notifier).setCurrentTime(time),
    );
  }

  Widget _buildAiToolbar() {
    return AiToolbar(
      onGenerateCaptions: () => ref.read(timelineNotifierProvider.notifier).generateAiCaptions(),
      onApplyTransitions: () => ref.read(timelineNotifierProvider.notifier).applyAiTransition(),
      onGenerateVideo: (prompt) => ref.read(timelineNotifierProvider.notifier).generateAiVideo(prompt),
      onEnhanceVideo: () => ref.read(timelineNotifierProvider.notifier).enhanceVideo(),
    );
  }

  Widget _buildTimelineControls() {
    return TimelineControls(
      currentTime: ref.watch(timelineStateProvider).currentTime,
      zoomLevel: ref.watch(timelineStateProvider).zoomLevel,
      onZoomIn: () => ref.read(timelineStateProvider.notifier).setZoomLevel(
        (ref.read(timelineStateProvider).zoomLevel * 1.2).clamp(0.1, 10.0)
      ),
      onZoomOut: () => ref.read(timelineStateProvider.notifier).setZoomLevel(
        (ref.read(timelineStateProvider).zoomLevel / 1.2).clamp(0.1, 10.0)
      ),
      onSeek: (time) => ref.read(timelineStateProvider.notifier).setCurrentTime(time),
      onAddTrack: (type) => ref.read(timelineNotifierProvider.notifier).addTrack(type, 'New Track'),
    );
  }

  Widget? _buildFloatingActionButton(TimelineState timelineState) {
    if (timelineState.selectedClip == null) return null;

    return FloatingActionButton.extended(
      onPressed: () => _showClipOptions(timelineState.selectedClip!),
      icon: const Icon(Icons.edit),
      label: const Text('Edit Clip'),
    );
  }

  Future<void> _showClipOptions(VideoClip clip) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _buildClipOptionsSheet(clip),
    );

    if (result != null && mounted) {
      await _handleClipOption(result, clip);
    }
  }

  Widget _buildClipOptionsSheet(VideoClip clip) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.content_cut),
            title: const Text('Trim Clip'),
            onTap: () => Navigator.pop(context, 'trim'),
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicate'),
            onTap: () => Navigator.pop(context, 'duplicate'),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
          if (clip.type == ClipType.video) ...[
            ListTile(
              leading: const Icon(Icons.auto_fix_high),
              title: const Text('AI Enhance'),
              onTap: () => Navigator.pop(context, 'enhance'),
            ),
            ListTile(
              leading: const Icon(Icons.closed_caption),
              title: const Text('Generate Captions'),
              onTap: () => Navigator.pop(context, 'captions'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleClipOption(String option, VideoClip clip) async {
    switch (option) {
      case 'trim':
        // Show trim dialog
        break;
      case 'duplicate':
        // Duplicate clip logic
        break;
      case 'delete':
        await ref.read(timelineNotifierProvider.notifier)
            .deleteClip(clip.id, ''); // trackId would be determined
        break;
      case 'enhance':
        await ref.read(timelineNotifierProvider.notifier).enhanceVideo();
        break;
      case 'captions':
        await ref.read(timelineNotifierProvider.notifier).generateAiCaptions();
        break;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Editor Settings'),
        content: const Text('Settings would be configured here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Editor Help'),
        content: const Text('Help information would be displayed here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
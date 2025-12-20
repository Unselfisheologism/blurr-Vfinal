import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/media_asset.dart';
import '../../models/video_clip.dart';
import '../../state/video_editor_state.dart';

class VideoPreviewPanel extends StatefulWidget {
  const VideoPreviewPanel({super.key});

  @override
  State<VideoPreviewPanel> createState() => _VideoPreviewPanelState();
}

class _VideoPreviewPanelState extends State<VideoPreviewPanel> {
  VideoPlayerController? _controller;
  String? _currentClipId;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoEditorState>(
      builder: (context, state, child) {
        final clip = state.selectedClip;
        _ensureControllerForClip(clip);

        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: _buildPreviewBody(clip),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildControls(state, clip),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewBody(VideoClip? clip) {
    if (clip == null) {
      return const Text('Select a clip to preview');
    }

    if (clip.type == MediaAssetType.image && !clip.isNetwork) {
      return Image.file(
        File(clip.uri),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text('Failed to load image'),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }

  Widget _buildControls(VideoEditorState state, VideoClip? clip) {
    final controller = _controller;
    final isInitialized = controller?.value.isInitialized ?? false;

    final clipDurationMs = clip?.durationMs ?? 0;
    final relativePositionMs = _relativePositionMs(state, clip);

    return Row(
      children: [
        IconButton(
          tooltip: (controller?.value.isPlaying ?? false) ? 'Pause' : 'Play',
          icon: Icon(
            (controller?.value.isPlaying ?? false) ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: (!isInitialized || clip == null) ? null : _togglePlay,
        ),
        Expanded(
          child: Slider(
            value: clip == null ? 0 : relativePositionMs.toDouble().clamp(0, clipDurationMs.toDouble()),
            max: clip == null ? 1 : (clipDurationMs.toDouble().clamp(1, double.infinity)),
            onChanged: (!isInitialized || clip == null)
                ? null
                : (v) {
                    final next = v.toInt();
                    final absolute = clip.startMs + next;
                    state.setPlayheadMs(absolute);
                    _seekToPlayhead(state, clip);
                  },
          ),
        ),
        Text(_formatMs(relativePositionMs)),
      ],
    );
  }

  int _relativePositionMs(VideoEditorState state, VideoClip? clip) {
    if (clip == null) return 0;
    return (state.project?.playheadMs ?? 0) - clip.startMs;
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    setState(() {});
  }

  void _ensureControllerForClip(VideoClip? clip) {
    if (clip == null) {
      if (_currentClipId != null) {
        _controller?.dispose();
        _controller = null;
        _currentClipId = null;
      }
      return;
    }

    if (clip.type != MediaAssetType.video) {
      if (_currentClipId != null) {
        _controller?.dispose();
        _controller = null;
        _currentClipId = null;
      }
      return;
    }

    if (_currentClipId == clip.id) return;

    _currentClipId = clip.id;
    _controller?.dispose();
    _controller = null;

    final controller = clip.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(clip.uri))
        : VideoPlayerController.file(File(clip.uri));

    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      _seekToPlayhead(context.read<VideoEditorState>(), clip);
      setState(() {});
    }).catchError((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _seekToPlayhead(VideoEditorState state, VideoClip clip) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final rel = _relativePositionMs(state, clip).clamp(0, clip.durationMs);
    final target = Duration(milliseconds: clip.trimStartMs + rel);
    await controller.seekTo(target);
  }

  String _formatMs(int ms) {
    final totalSec = (ms / 1000).floor();
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

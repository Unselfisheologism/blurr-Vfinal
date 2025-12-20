import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/media_asset.dart';
import '../../models/video_clip.dart';
import '../../state/video_editor_state.dart';

class TimelineClipWidget extends StatelessWidget {
  final VideoClip clip;
  final double pixelsPerSecond;
  final bool isSelected;

  const TimelineClipWidget({
    super.key,
    required this.clip,
    required this.pixelsPerSecond,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = (clip.durationMs / 1000.0) * pixelsPerSecond;

    final baseColor = switch (clip.type) {
      MediaAssetType.video => Colors.blue,
      MediaAssetType.image => Colors.purple,
      MediaAssetType.audio => Colors.green,
    };

    final containerColor = isSelected ? baseColor.withOpacity(0.9) : baseColor.withOpacity(0.75);

    return Positioned(
      left: (clip.startMs / 1000.0) * pixelsPerSecond,
      top: 8,
      bottom: 8,
      width: width.clamp(24.0, double.infinity),
      child: _ClipBody(
        clip: clip,
        color: containerColor,
        isSelected: isSelected,
        pixelsPerSecond: pixelsPerSecond,
      ),
    );
  }
}

class _ClipBody extends StatelessWidget {
  final VideoClip clip;
  final Color color;
  final bool isSelected;
  final double pixelsPerSecond;

  const _ClipBody({
    required this.clip,
    required this.color,
    required this.isSelected,
    required this.pixelsPerSecond,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<VideoEditorState>();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => state.selectClip(clip.id),
        onPanUpdate: (details) {
          final deltaMs = (details.delta.dx / pixelsPerSecond * 1000).round();
          if (deltaMs != 0) {
            state.moveClip(clip.id, deltaMs);
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.black.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  clip.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),

              // Trim handles
              Align(
                alignment: Alignment.centerLeft,
                child: _TrimHandle(
                  onDrag: (deltaMs) => state.trimClipStart(clip.id, deltaMs),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _TrimHandle(
                  onDrag: (deltaMs) => state.trimClipEnd(clip.id, deltaMs),
                  isRight: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrimHandle extends StatelessWidget {
  final bool isRight;
  final void Function(int deltaMs) onDrag;

  const _TrimHandle({
    required this.onDrag,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withOpacity(0.85);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        final state = context.read<VideoEditorState>();
        final deltaMs = (details.delta.dx / state.pixelsPerSecond * 1000).round();
        if (deltaMs == 0) return;
        onDrag(deltaMs);
      },
      child: Container(
        width: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isRight ? 0 : 10),
            right: Radius.circular(isRight ? 10 : 0),
          ),
        ),
        child: Icon(
          isRight ? Icons.drag_handle : Icons.drag_handle,
          size: 12,
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}

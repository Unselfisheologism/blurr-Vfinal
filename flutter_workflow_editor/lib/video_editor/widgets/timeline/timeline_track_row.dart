import 'package:flutter/material.dart';

import '../../models/video_project.dart';
import '../../models/video_track.dart';
import '../../models/video_transition.dart';
import '../../models/video_clip.dart';
import 'timeline_clip_widget.dart';

class TimelineTrackRow extends StatelessWidget {
  final VideoTrack track;
  final VideoProject project;
  final double pixelsPerSecond;
  final int maxMs;

  const TimelineTrackRow({
    super.key,
    required this.track,
    required this.project,
    required this.pixelsPerSecond,
    required this.maxMs,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                track.name,
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: (maxMs / 1000.0) * pixelsPerSecond,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
                  ),
                ),
                child: Stack(
                  children: [
                    ...track.clips.map((clip) {
                      final isSelected = project.selectedClipId == clip.id;
                      return TimelineClipWidget(
                        clip: clip,
                        pixelsPerSecond: pixelsPerSecond,
                        isSelected: isSelected,
                      );
                    }),
                    ..._buildTransitionMarkers(
                      transitions: project.transitions,
                      clips: track.clips,
                      pixelsPerSecond: pixelsPerSecond,
                      color: colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTransitionMarkers({
    required List<VideoTransition> transitions,
    required List<VideoClip> clips,
    required double pixelsPerSecond,
    required Color color,
  }) {
    if (transitions.isEmpty || clips.isEmpty) return const [];

    final clipById = {for (final c in clips) c.id: c};

    return transitions.map((t) {
      final from = clipById[t.fromClipId];
      final to = clipById[t.toClipId];
      if (from == null || to == null) return const SizedBox.shrink();

      final x = (from.endMs / 1000.0) * pixelsPerSecond;
      return Positioned(
        left: x - 6,
        top: 4,
        bottom: 4,
        width: 12,
        child: Center(
          child: Transform.rotate(
            angle: 0.785398, // 45deg
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
    }).where((w) => w is! SizedBox).toList();
  }
}

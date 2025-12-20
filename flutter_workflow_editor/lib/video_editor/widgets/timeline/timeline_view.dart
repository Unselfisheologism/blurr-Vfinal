import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/video_project.dart';
import '../../state/video_editor_state.dart';
import 'timeline_ruler.dart';
import 'timeline_track_row.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoEditorState>(
      builder: (context, state, child) {
        final project = state.project;
        if (project == null) {
          return const SizedBox.shrink();
        }

        final maxMs = _computeTimelineMaxMs(project);
        final contentWidth = 110 + (maxMs / 1000.0) * state.pixelsPerSecond;

        return GestureDetector(
          onScaleUpdate: (details) {
            // Pinch zoom: keep it subtle to avoid accidental zoom.
            if (details.scale == 1.0) return;
            state.setPixelsPerSecond(state.pixelsPerSecond * details.scale);
          },
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: contentWidth,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 110),
                          TimelineRuler(
                            pixelsPerSecond: state.pixelsPerSecond,
                            maxMs: maxMs,
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: project.tracks.length,
                          itemBuilder: (context, index) {
                            final track = project.tracks[index];
                            return TimelineTrackRow(
                              track: track,
                              project: project,
                              pixelsPerSecond: state.pixelsPerSecond,
                              maxMs: maxMs,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Playhead overlay
                  Positioned(
                    left: 110 + (project.playheadMs / 1000.0) * state.pixelsPerSecond,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        final deltaMs = (details.delta.dx / state.pixelsPerSecond * 1000).round();
                        if (deltaMs == 0) return;
                        state.setPlayheadMs(project.playheadMs + deltaMs);
                      },
                      child: Container(
                        width: 2,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),

                  // Tap-to-seek surface.
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (details) {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final local = box.globalToLocal(details.globalPosition);
                        final x = (local.dx - 110).clamp(0.0, double.infinity);
                        final ms = (x / state.pixelsPerSecond * 1000).round();
                        state.setPlayheadMs(ms);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _computeTimelineMaxMs(VideoProject project) {
    var maxMs = 10 * 1000;
    for (final t in project.tracks) {
      for (final c in t.clips) {
        maxMs = maxMs < c.endMs ? c.endMs : maxMs;
      }
    }
    maxMs = maxMs < project.playheadMs ? project.playheadMs : maxMs;
    return maxMs + 2000;
  }
}

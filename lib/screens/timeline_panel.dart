import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_clip.dart';
import '../models/video_track.dart';

class TimelinePanel extends StatelessWidget {
  final TimelineState timelineState;
  final Function(VideoClip?, VideoTrack?) onClipSelected;

  const TimelinePanel({
    Key? key,
    required this.timelineState,
    required this.onClipSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          _buildTimelineHeader(context),
          Expanded(
            child: _buildTimelineTracks(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // Track header
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'TRACKS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          // Timeline ruler
          Expanded(
            child: CustomPaint(
              painter: TimelineRulerPainter(
                duration: timelineState.projectDuration,
                zoomLevel: timelineState.zoomLevel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTracks(BuildContext context) {
    if (timelineState.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tracks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add media to start editing',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: timelineState.tracks.length,
      itemBuilder: (context, index) {
        final track = timelineState.tracks[index];
        return _buildTrackRow(context, track, index);
      },
    );
  }

  Widget _buildTrackRow(BuildContext context, VideoTrack track, int index) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // Track header
          _buildTrackHeader(context, track, index),
          // Timeline track
          Expanded(
            child: _buildTrackTimeline(context, track),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackHeader(BuildContext context, VideoTrack track, int index) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: track.color.withOpacity(0.1),
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          _buildTrackTypeIcon(track.type),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  track.name,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${track.clipCount} clips',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _buildTrackControls(track),
        ],
      ),
    );
  }

  Widget _buildTrackControls(VideoTrack track) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            track.isMuted ? Icons.volume_off : Icons.volume_up,
            size: 16,
          ),
          onPressed: () {
            // Toggle mute
          },
        ),
        IconButton(
          icon: Icon(
            track.isLocked ? Icons.lock : Icons.lock_open,
            size: 16,
          ),
          onPressed: () {
            // Toggle lock
          },
        ),
        if (track.maxClips != null)
          Tooltip(
            message: 'Pro feature: Unlimited clips',
            child: IconButton(
              icon: const Icon(Icons.star, size: 16),
              onPressed: () {
                // Show upgrade dialog
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTrackTimeline(BuildContext context, VideoTrack track) {
    return GestureDetector(
      onTapDown: (details) {
        // Handle track click for adding clips
      },
      child: CustomPaint(
        painter: TrackTimelinePainter(
          clips: track.clips,
          duration: timelineState.projectDuration,
          zoomLevel: timelineState.zoomLevel,
          trackHeight: 60,
          selectedClip: timelineState.selectedClip,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildTrackTypeIcon(TrackType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case TrackType.video:
        iconData = Icons.videocam;
        color = Colors.orange;
        break;
      case TrackType.audio:
        iconData = Icons.audiotrack;
        color = Colors.green;
        break;
      case TrackType.text:
        iconData = Icons.text_fields;
        color = Colors.blue;
        break;
      case TrackType.effect:
        iconData = Icons.auto_awesome;
        color = Colors.purple;
        break;
      case TrackType.transition:
        iconData = Icons.transform;
        color = Colors.pink;
        break;
    }

    return Icon(iconData, size: 20, color: color);
  }
}

class TimelineRulerPainter extends CustomPainter {
  final double duration;
  final double zoomLevel;

  TimelineRulerPainter({
    required this.duration,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw time markers
    const timeInterval = 1.0; // seconds
    final pixelsPerSecond = size.width / duration * zoomLevel;

    for (double time = 0; time <= duration; time += timeInterval) {
      final x = time * pixelsPerSecond;

      if (x >= 0 && x <= size.width) {
        // Draw tick
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, time % 5 == 0 ? 20 : 10),
          paint,
        );

        // Draw time label for major ticks
        if (time % 5 == 0) {
          textPainter.text = TextSpan(
            text: _formatTime(time),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          );

          textPainter.layout();
          textPainter.paint(canvas, Offset(x + 2, 2));
        }
      }
    }
  }

  String _formatTime(double seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toStringAsFixed(0).padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(TimelineRulerPainter oldDelegate) {
    return oldDelegate.duration != duration || oldDelegate.zoomLevel != zoomLevel;
  }
}

class TrackTimelinePainter extends CustomPainter {
  final List<VideoClip> clips;
  final double duration;
  final double zoomLevel;
  final double trackHeight;
  final VideoClip? selectedClip;

  TrackTimelinePainter({
    required this.clips,
    required this.duration,
    required this.zoomLevel,
    required this.trackHeight,
    this.selectedClip,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelsPerSecond = size.width / duration * zoomLevel;

    // Draw clips
    for (final clip in clips) {
      // Calculate clip position and dimensions
      final clipX = clip.startTime * pixelsPerSecond;
      final clipWidth = clip.trimmedDuration * pixelsPerSecond;
      final clipHeight = trackHeight * 0.8;
      final clipY = (trackHeight - clipHeight) / 2;

      // Check if clip is visible
      if (clipX + clipWidth < 0 || clipX > size.width) continue;

      final isSelected = clip == selectedClip;

      // Draw clip background
      final backgroundPaint = Paint()
        ..color = clip.color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            clipX.clamp(0, size.width),
            clipY,
            clipWidth.clamp(0, size.width - clipX.clamp(0, size.width)),
            clipHeight,
          ),
          const Radius.circular(4),
        ),
        backgroundPaint,
      );

      // Draw clip border
      final borderPaint = Paint()
        ..color = isSelected ? Colors.white : Colors.black
        ..strokeWidth = isSelected ? 2 : 1
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            clipX.clamp(0, size.width),
            clipY,
            clipWidth.clamp(0, size.width - clipX.clamp(0, size.width)),
            clipHeight,
          ),
          const Radius.circular(4),
        ),
        borderPaint,
      );

      // Draw clip handles for trimming
      if (isSelected) {
        final handlePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        // Left handle
        canvas.drawRect(
          Rect.fromLTWH(clipX.clamp(0, size.width) - 2, clipY, 4, clipHeight),
          handlePaint,
        );

        // Right handle
        final rightEdge = (clipX + clipWidth).clamp(0, size.width);
        canvas.drawRect(
          Rect.fromLTWH(rightEdge - 2, clipY, 4, clipHeight),
          handlePaint,
        );
      }

      // Draw clip label
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getClipLabel(clip),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      );

      textPainter.layout(maxWidth: clipWidth);
      textPainter.paint(
        canvas,
        Offset(clipX + 4, clipY + 4),
      );
    }
  }

  String _getClipLabel(VideoClip clip) {
    if (clip.name != null) return clip.name!;
    
    switch (clip.type) {
      case ClipType.video:
        return 'Video';
      case ClipType.audio:
        return 'Audio';
      case ClipType.image:
        return 'Image';
      case ClipType.text:
        return (clip as TextClip).text;
      case ClipType.transition:
        return (clip as TransitionClip).transitionType;
    }
  }

  @override
  bool shouldRepaint(TrackTimelinePainter oldDelegate) {
    return oldDelegate.clips != clips ||
        oldDelegate.duration != duration ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.selectedClip != selectedClip;
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/daw_state.dart';
import '../models/daw_track.dart';
import '../models/audio_clip.dart';
import 'daw_waveform_painter.dart';

/// Main timeline canvas with tracks, clips, and waveforms
class DawTimelineCanvas extends StatefulWidget {
  const DawTimelineCanvas({Key? key}) : super(key: key);

  @override
  State<DawTimelineCanvas> createState() => _DawTimelineCanvasState();
}

class _DawTimelineCanvasState extends State<DawTimelineCanvas> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  
  double _dragStartX = 0;
  double _dragStartY = 0;
  String? _draggingClipId;
  String? _draggingTrackId;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DawState>(
      builder: (context, state, _) {
        final pixelsPerSecond = state.project.zoomLevel;
        final totalDuration = state.project.duration;
        final totalWidth = (totalDuration / 1000) * pixelsPerSecond + 1000;

        return Column(
          children: [
            // Ruler/timeline
            _buildRuler(context, state, pixelsPerSecond, totalWidth),
            
            // Track area
            Expanded(
              child: Stack(
                children: [
                  // Background grid
                  CustomPaint(
                    painter: _GridPainter(
                      pixelsPerSecond: pixelsPerSecond,
                      gridSize: state.gridSize,
                    ),
                    child: Container(),
                  ),
                  
                  // Scrollable timeline content
                  Scrollbar(
                    controller: _horizontalScrollController,
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          child: SizedBox(
                            width: totalWidth,
                            height: _calculateTotalHeight(state.project.tracks),
                            child: Stack(
                              children: [
                                // Tracks and clips
                                _buildTracks(context, state, pixelsPerSecond),
                                
                                // Playhead
                                _buildPlayhead(state, pixelsPerSecond),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRuler(
    BuildContext context,
    DawState state,
    double pixelsPerSecond,
    double totalWidth,
  ) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: CustomPaint(
        painter: _RulerPainter(
          pixelsPerSecond: pixelsPerSecond,
          totalWidth: totalWidth,
        ),
        child: GestureDetector(
          onTapDown: (details) {
            final positionMs = (details.localPosition.dx / pixelsPerSecond) * 1000;
            state.seek(positionMs);
          },
        ),
      ),
    );
  }

  Widget _buildTracks(
    BuildContext context,
    DawState state,
    double pixelsPerSecond,
  ) {
    double yOffset = 0;
    
    return Stack(
      children: state.project.tracks.map((track) {
        final trackWidget = Positioned(
          left: 0,
          top: yOffset,
          right: 0,
          height: track.height,
          child: _buildTrack(context, state, track, pixelsPerSecond),
        );
        
        yOffset += track.height;
        return trackWidget;
      }).toList(),
    );
  }

  Widget _buildTrack(
    BuildContext context,
    DawState state,
    DawTrack track,
    double pixelsPerSecond,
  ) {
    final isSelected = state.selectedTrackId == track.id;
    
    return GestureDetector(
      onTap: () => state.selectTrack(track.id),
      child: Container(
        decoration: BoxDecoration(
          color: Color(track.color).withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Track name indicator (left edge)
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(track.color).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  track.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Clips on this track
            ...track.clips.map((clip) {
              return _buildClip(context, state, track, clip, pixelsPerSecond);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildClip(
    BuildContext context,
    DawState state,
    DawTrack track,
    AudioClip clip,
    double pixelsPerSecond,
  ) {
    final left = (clip.startTime / 1000) * pixelsPerSecond;
    final width = (clip.duration / 1000) * pixelsPerSecond;
    final isSelected = state.selectedClipId == clip.id;
    
    return Positioned(
      left: left,
      top: 20,
      width: width,
      height: track.height - 40,
      child: GestureDetector(
        onTapDown: (details) {
          state.selectClip(clip.id);
          state.selectTrack(track.id);
        },
        onPanStart: (details) {
          _dragStartX = details.globalPosition.dx;
          _dragStartY = details.globalPosition.dy;
          _draggingClipId = clip.id;
          _draggingTrackId = track.id;
        },
        onPanUpdate: (details) {
          if (_draggingClipId == clip.id) {
            final deltaX = details.globalPosition.dx - _dragStartX;
            final deltaTimeMs = (deltaX / pixelsPerSecond) * 1000;
            
            var newStartTime = clip.startTime + deltaTimeMs;
            newStartTime = state.snapPositionToGrid(newStartTime);
            newStartTime = newStartTime.clamp(0.0, double.infinity);
            
            final updatedClip = clip.copyWith(startTime: newStartTime);
            state.updateClip(track.id, updatedClip);
            
            _dragStartX = details.globalPosition.dx;
          }
        },
        onPanEnd: (details) {
          _draggingClipId = null;
          _draggingTrackId = null;
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(clip.color).withOpacity(clip.isMuted ? 0.3 : 0.8),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Waveform visualization
                if (clip.waveformData != null && clip.waveformData!.isNotEmpty)
                  CustomPaint(
                    painter: DawWaveformPainter(
                      waveformData: clip.waveformData!,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Container(),
                  ),
                
                // Clip name
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    clip.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // AI badge
                if (clip.isAiGenerated)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayhead(DawState state, double pixelsPerSecond) {
    final playheadX = (state.playbackPosition / 1000) * pixelsPerSecond;
    
    return Positioned(
      left: playheadX,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: Colors.red,
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                width: 2,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalHeight(List<DawTrack> tracks) {
    return tracks.fold(0.0, (sum, track) => sum + track.height);
  }
}

/// Painter for the timeline ruler
class _RulerPainter extends CustomPainter {
  final double pixelsPerSecond;
  final double totalWidth;

  _RulerPainter({
    required this.pixelsPerSecond,
    required this.totalWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw tick marks and time labels every second
    for (int second = 0; second < (totalWidth / pixelsPerSecond); second++) {
      final x = second * pixelsPerSecond;
      
      // Major tick every 5 seconds
      if (second % 5 == 0) {
        canvas.drawLine(
          Offset(x, size.height - 10),
          Offset(x, size.height),
          paint,
        );
        
        // Time label
        final minutes = second ~/ 60;
        final seconds = second % 60;
        final timeLabel = '$minutes:${seconds.toString().padLeft(2, '0')}';
        
        textPainter.text = TextSpan(
          text: timeLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + 2, 2));
      } else {
        // Minor tick
        canvas.drawLine(
          Offset(x, size.height - 5),
          Offset(x, size.height),
          paint..strokeWidth = 0.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter for the background grid
class _GridPainter extends CustomPainter {
  final double pixelsPerSecond;
  final double gridSize; // in milliseconds

  _GridPainter({
    required this.pixelsPerSecond,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    final gridPixels = (gridSize / 1000) * pixelsPerSecond;

    // Vertical grid lines
    for (double x = 0; x < size.width; x += gridPixels) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

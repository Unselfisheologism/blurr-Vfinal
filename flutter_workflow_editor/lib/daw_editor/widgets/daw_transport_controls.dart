import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/daw_state.dart';

/// Bottom transport controls for playback
class DawTransportControls extends StatelessWidget {
  const DawTransportControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DawState>(
      builder: (context, state, _) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Playback controls
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () => state.seek(0),
                tooltip: 'Go to start',
              ),
              
              const SizedBox(width: 8),
              
              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    if (state.isPlaying) {
                      state.pause();
                    } else {
                      state.play();
                    }
                  },
                  tooltip: state.isPlaying ? 'Pause' : 'Play',
                ),
              ),
              
              const SizedBox(width: 8),
              
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: state.stop,
                tooltip: 'Stop',
              ),
              
              const SizedBox(width: 16),
              
              // Time display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatTime(state.playbackPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              Text(
                '/',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              
              const SizedBox(width: 8),
              
              Text(
                _formatTime(state.project.duration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
              
              const Spacer(),
              
              // Master volume
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              SizedBox(
                width: 150,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: state.project.masterVolume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.white24,
                    onChanged: (value) => state.setMasterVolume(value),
                  ),
                ),
              ),
              Text(
                '${(state.project.masterVolume * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(double milliseconds) {
    final totalSeconds = (milliseconds / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final ms = ((milliseconds % 1000) / 10).floor();
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }
}

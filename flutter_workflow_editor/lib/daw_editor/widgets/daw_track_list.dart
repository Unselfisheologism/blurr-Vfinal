import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/daw_state.dart';
import '../models/daw_track.dart';
import '../models/daw_project.dart';

/// Left sidebar showing list of tracks with controls
class DawTrackList extends StatelessWidget {
  const DawTrackList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DawState>(
      builder: (context, state, _) {
        final tracks = state.project.tracks;
        final canAddTrack = !state.project.hasReachedFreeLimit;

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Tracks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: canAddTrack
                        ? () => _showAddTrackDialog(context, state)
                        : () => _showProDialog(context),
                    tooltip: canAddTrack ? 'Add track' : 'Upgrade to Pro',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Track list
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  final isSelected = state.selectedTrackId == track.id;

                  return _TrackListItem(
                    track: track,
                    isSelected: isSelected,
                    onTap: () => state.selectTrack(track.id),
                    onMuteToggle: () => state.toggleTrackMute(track.id),
                    onSoloToggle: () => state.toggleTrackSolo(track.id),
                    onVolumeChanged: (volume) =>
                        state.setTrackVolume(track.id, volume),
                    onPanChanged: (pan) => state.setTrackPan(track.id, pan),
                    onDelete: tracks.length > 1
                        ? () => state.removeTrack(track.id)
                        : null,
                  );
                },
              ),
            ),

            // Free tier limit indicator
            if (state.project.hasReachedFreeLimit)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange.withOpacity(0.2),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Free: ${DawProject.freeTrackLimit} tracks max',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
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

  void _showAddTrackDialog(BuildContext context, DawState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Track'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('Audio Track'),
              onTap: () {
                state.addTrack();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: const Text(
          'Free tier is limited to 4 tracks. Upgrade to Pro for unlimited tracks and advanced effects!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to upgrade flow
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

/// Individual track list item with controls
class _TrackListItem extends StatelessWidget {
  final DawTrack track;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onMuteToggle;
  final VoidCallback onSoloToggle;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onPanChanged;
  final VoidCallback? onDelete;

  const _TrackListItem({
    Key? key,
    required this.track,
    required this.isSelected,
    required this.onTap,
    required this.onMuteToggle,
    required this.onSoloToggle,
    required this.onVolumeChanged,
    required this.onPanChanged,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Color(track.color).withOpacity(0.2)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Track name and color
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(track.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      track.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      color: Colors.white54,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Mute and Solo buttons
              Row(
                children: [
                  _ToggleButton(
                    label: 'M',
                    isActive: track.isMuted,
                    activeColor: Colors.red,
                    onPressed: onMuteToggle,
                  ),
                  const SizedBox(width: 4),
                  _ToggleButton(
                    label: 'S',
                    isActive: track.isSolo,
                    activeColor: Colors.yellow,
                    onPressed: onSoloToggle,
                  ),
                  const Spacer(),
                  Text(
                    '${(track.volume * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Volume slider
              Row(
                children: [
                  const Icon(Icons.volume_down, size: 14, color: Colors.white54),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: track.volume,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Color(track.color),
                        inactiveColor: Colors.white24,
                        onChanged: onVolumeChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle button for mute/solo
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onPressed;

  const _ToggleButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white12,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? activeColor : Colors.white24,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

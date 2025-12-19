import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/daw_state.dart';
import '../models/daw_track.dart';

/// Right panel showing mixing controls and effects for selected track
class DawMixerPanel extends StatelessWidget {
  final VoidCallback onClose;

  const DawMixerPanel({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DawState>(
      builder: (context, state, _) {
        final selectedTrack = state.selectedTrackId != null
            ? state.project.tracks.firstWhere(
                (t) => t.id == state.selectedTrackId,
                orElse: () => state.project.tracks.first,
              )
            : null;

        return Container(
          color: const Color(0xFF252525),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
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
                    const Icon(Icons.tune, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Mixer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: selectedTrack != null
                    ? _TrackMixerControls(track: selectedTrack)
                    : const Center(
                        child: Text(
                          'Select a track',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mixer controls for a specific track
class _TrackMixerControls extends StatelessWidget {
  final DawTrack track;

  const _TrackMixerControls({
    Key? key,
    required this.track,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DawState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track info
          _SectionHeader(title: track.name),
          const SizedBox(height: 16),

          // Volume fader
          _buildVolumeFader(context, state),
          const SizedBox(height: 24),

          // Pan control
          _buildPanControl(context, state),
          const SizedBox(height: 24),

          // Effects section
          _SectionHeader(title: 'Effects'),
          const SizedBox(height: 8),
          
          if (track.effects.isEmpty)
            _buildAddEffectButton(context, state)
          else
            ...track.effects.map((effect) {
              return _EffectCard(
                effect: effect,
                track: track,
              );
            }).toList(),

          const SizedBox(height: 8),
          if (track.effects.isNotEmpty)
            _buildAddEffectButton(context, state),
        ],
      ),
    );
  }

  Widget _buildVolumeFader(BuildContext context, DawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Volume',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(track.volume * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 7,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 16,
            ),
          ),
          child: Slider(
            value: track.volume,
            min: 0.0,
            max: 1.0,
            activeColor: Color(track.color),
            inactiveColor: Colors.white24,
            onChanged: (value) => state.setTrackVolume(track.id, value),
          ),
        ),
      ],
    );
  }

  Widget _buildPanControl(BuildContext context, DawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              track.pan == 0
                  ? 'Center'
                  : track.pan < 0
                      ? 'L ${(track.pan.abs() * 100).toInt()}'
                      : 'R ${(track.pan * 100).toInt()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 7,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 16,
            ),
          ),
          child: Slider(
            value: track.pan,
            min: -1.0,
            max: 1.0,
            activeColor: Color(track.color),
            inactiveColor: Colors.white24,
            onChanged: (value) => state.setTrackPan(track.id, value),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'L',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            Text(
              'C',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            Text(
              'R',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddEffectButton(BuildContext context, DawState state) {
    return OutlinedButton.icon(
      onPressed: () => _showAddEffectDialog(context, state),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Effect'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: const BorderSide(color: Colors.white24),
      ),
    );
  }

  void _showAddEffectDialog(BuildContext context, DawState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Effect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EffectType.values.map((type) {
            return ListTile(
              leading: Icon(_getEffectIcon(type)),
              title: Text(_getEffectName(type)),
              onTap: () {
                final effect = TrackEffect(type: type);
                final updatedTrack = track.addEffect(effect);
                state.updateTrack(updatedTrack);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getEffectIcon(EffectType type) {
    switch (type) {
      case EffectType.reverb:
        return Icons.waves;
      case EffectType.pitchShift:
        return Icons.graphic_eq;
      case EffectType.lowPass:
      case EffectType.highPass:
      case EffectType.bandPass:
        return Icons.filter_alt;
      case EffectType.echo:
        return Icons.mic;
      case EffectType.compressor:
        return Icons.compress;
      case EffectType.limiter:
        return Icons.equalizer;
    }
  }

  String _getEffectName(EffectType type) {
    return type.name.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

/// Effect card
class _EffectCard extends StatelessWidget {
  final TrackEffect effect;
  final DawTrack track;

  const _EffectCard({
    Key? key,
    required this.effect,
    required this.track,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DawState>();

    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: effect.enabled,
                  onChanged: (value) {
                    final updatedEffect = effect.copyWith(enabled: value);
                    final updatedTrack = track.updateEffect(updatedEffect);
                    state.updateTrack(updatedTrack);
                  },
                  activeColor: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getEffectName(effect.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                  onPressed: () {
                    final updatedTrack = track.removeEffect(effect.id);
                    state.updateTrack(updatedTrack);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // Effect parameters would go here in a full implementation
          ],
        ),
      ),
    );
  }

  String _getEffectName(EffectType type) {
    return type.name.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

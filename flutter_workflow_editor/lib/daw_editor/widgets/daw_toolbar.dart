import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/daw_state.dart';

/// Top toolbar with common DAW controls
class DawToolbar extends StatelessWidget {
  final VoidCallback onShowMixer;
  final VoidCallback onShowAi;

  const DawToolbar({
    Key? key,
    required this.onShowMixer,
    required this.onShowAi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DawState>(
      builder: (context, state, _) {
        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Tool mode selector
              _ToolModeButton(
                icon: Icons.mouse,
                label: 'Select',
                isActive: state.toolMode == ToolMode.select,
                onPressed: () => state.setToolMode(ToolMode.select),
              ),
              _ToolModeButton(
                icon: Icons.content_cut,
                label: 'Trim',
                isActive: state.toolMode == ToolMode.trim,
                onPressed: () => state.setToolMode(ToolMode.trim),
              ),
              _ToolModeButton(
                icon: Icons.call_split,
                label: 'Split',
                isActive: state.toolMode == ToolMode.split,
                onPressed: () => state.setToolMode(ToolMode.split),
              ),
              
              const VerticalDivider(color: Colors.white24),
              
              // Snap to grid
              _ToggleButton(
                icon: Icons.grid_on,
                label: 'Snap',
                isActive: state.snapToGrid,
                onPressed: state.toggleSnapToGrid,
              ),
              
              const VerticalDivider(color: Colors.white24),
              
              // Zoom controls
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                onPressed: () {
                  final newZoom = (state.project.zoomLevel - 20).clamp(20.0, 500.0);
                  state.setZoomLevel(newZoom);
                },
                tooltip: 'Zoom out',
              ),
              Text(
                '${state.project.zoomLevel.toInt()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white),
                onPressed: () {
                  final newZoom = (state.project.zoomLevel + 20).clamp(20.0, 500.0);
                  state.setZoomLevel(newZoom);
                },
                tooltip: 'Zoom in',
              ),
              
              const Spacer(),
              
              // Tempo display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.speed, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${state.project.tempo.toInt()} BPM',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // AI button
              ElevatedButton.icon(
                onPressed: onShowAi,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Mixer button
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: onShowMixer,
                tooltip: 'Show mixer',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tool mode button
class _ToolModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToolModeButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? Colors.blue : Colors.transparent,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.blue : Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Toggle button
class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToggleButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.orange.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.orange : Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }
}

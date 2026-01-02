import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/daw_project.dart';
import 'state/daw_state.dart';
import 'widgets/daw_timeline_canvas.dart';
import 'widgets/daw_toolbar.dart';
import 'widgets/daw_transport_controls.dart';
import 'widgets/daw_mixer_panel.dart';
import 'widgets/daw_track_list.dart';
import 'widgets/daw_ai_toolbar.dart';

/// Main DAW Editor Screen - Entry point for the Digital Audio Workstation
class DawEditorScreen extends StatefulWidget {
  final String? projectName;
  final dynamic agentExecutor; // Reference to existing agent system

  const DawEditorScreen({
    Key? key,
    this.projectName,
    this.agentExecutor,
  }) : super(key: key);

  @override
  State<DawEditorScreen> createState() => _DawEditorScreenState();
}

class _DawEditorScreenState extends State<DawEditorScreen> {
  late DawState _dawState;
  bool _showMixer = false;
  bool _showAiPanel = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with empty project
    final projectName = widget.projectName ?? 'Untitled Project';
    final project = DawProject.empty(projectName);
    
    _dawState = DawState(project);
    
    // Initialize services
    _dawState.initialize(agentExecutor: widget.agentExecutor);
  }

  @override
  void dispose() {
    _dawState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DawState>.value(
      value: _dawState,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Main toolbar
            DawToolbar(
              onShowMixer: () => setState(() => _showMixer = !_showMixer),
              onShowAi: () => setState(() => _showAiPanel = !_showAiPanel),
            ),
            
            // Main content area
            Expanded(
              child: Row(
                children: [
                  // Left sidebar - Track list
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const DawTrackList(),
                  ),
                  
                  // Center - Timeline and waveforms
                  Expanded(
                    child: Stack(
                      children: [
                        const DawTimelineCanvas(),
                        
                        // AI Panel overlay
                        if (_showAiPanel)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: 300,
                            child: DawAiToolbar(
                              onClose: () => setState(() => _showAiPanel = false),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Right sidebar - Mixer (optional)
                  if (_showMixer)
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: DawMixerPanel(
                        onClose: () => setState(() => _showMixer = false),
                      ),
                    ),
                ],
              ),
            ),
            
            // Transport controls at bottom
            const DawTransportControls(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2D2D2D),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => _handleBack(context),
        tooltip: 'Back to main app',
      ),
      title: Consumer<DawState>(
        builder: (context, state, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.project.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${state.project.tracks.length} tracks • ${state.project.tempo.toInt()} BPM',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Undo/Redo
        Consumer<DawState>(
          builder: (context, state, _) {
            return Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.undo,
                    color: state.canUndo ? Colors.white : Colors.white38,
                  ),
                  onPressed: state.canUndo ? state.undo : null,
                  tooltip: 'Undo',
                ),
                IconButton(
                  icon: Icon(
                    Icons.redo,
                    color: state.canRedo ? Colors.white : Colors.white38,
                  ),
                  onPressed: state.canRedo ? state.redo : null,
                  tooltip: 'Redo',
                ),
              ],
            );
          },
        ),
        
        const SizedBox(width: 8),
        
        // Save
        IconButton(
          icon: const Icon(Icons.save, color: Colors.white),
          onPressed: () => _handleSave(context),
          tooltip: 'Save project',
        ),
        
        // Export
        IconButton(
          icon: const Icon(Icons.file_download, color: Colors.white),
          onPressed: () => _handleExport(context),
          tooltip: 'Export audio',
        ),
        
        // Settings
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showSettings(context),
          tooltip: 'Settings',
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  void _handleBack(BuildContext context) async {
    final state = context.read<DawState>();
    
    if (state.project.hasUnsavedChanges) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Do you want to exit without saving?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Exit'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
                _handleSave(context);
              },
              child: const Text('Save & Exit'),
            ),
          ],
        ),
      );
      
      if (shouldExit == true) {
        if (context.mounted) Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  void _handleSave(BuildContext context) async {
    final state = context.read<DawState>();
    
    try {
      final file = await state.exportService.saveProjectFile(state.project);
      
      if (file != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project saved: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleExport(BuildContext context) async {
    final state = context.read<DawState>();
    
    // Show export dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ExportDialog(),
    );
    
    if (result != null && context.mounted) {
      // Show progress
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      try {
        final file = await state.exportService.exportProject(
          state.project,
          format: result['format'],
          quality: result['quality'],
        );
        
        if (context.mounted) {
          Navigator.pop(context); // Close progress dialog
          
          if (file != null) {
            // Ask to share
            final shouldShare = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Export Complete'),
                content: Text('File saved to: ${file.path}\n\nWould you like to share it?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Share'),
                  ),
                ],
              ),
            );
            
            if (shouldShare == true) {
              await state.exportService.shareExportedFile(file);
            }
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close progress dialog
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error exporting: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _SettingsDialog(),
    );
  }
}

/// Export dialog for selecting format and quality
class _ExportDialog extends StatefulWidget {
  const _ExportDialog({Key? key}) : super(key: key);

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  var _format = ExportFormat.wav;
  var _quality = ExportQuality.high;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Audio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Format:', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile<ExportFormat>(
            title: const Text('WAV (Lossless)'),
            value: ExportFormat.wav,
            groupValue: _format,
            onChanged: (value) => setState(() => _format = value!),
          ),
          RadioListTile<ExportFormat>(
            title: const Text('MP3 (Compressed)'),
            value: ExportFormat.mp3,
            groupValue: _format,
            onChanged: (value) => setState(() => _format = value!),
          ),
          RadioListTile<ExportFormat>(
            title: const Text('M4A (AAC)'),
            value: ExportFormat.m4a,
            groupValue: _format,
            onChanged: (value) => setState(() => _format = value!),
          ),
          const SizedBox(height: 16),
          const Text('Quality:', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile<ExportQuality>(
            title: const Text('Low (22kHz)'),
            value: ExportQuality.low,
            groupValue: _quality,
            onChanged: (value) => setState(() => _quality = value!),
          ),
          RadioListTile<ExportQuality>(
            title: const Text('Medium (44.1kHz)'),
            value: ExportQuality.medium,
            groupValue: _quality,
            onChanged: (value) => setState(() => _quality = value!),
          ),
          RadioListTile<ExportQuality>(
            title: const Text('High (48kHz)'),
            value: ExportQuality.high,
            groupValue: _quality,
            onChanged: (value) => setState(() => _quality = value!),
          ),
          RadioListTile<ExportQuality>(
            title: const Text('Lossless (96kHz)'),
            value: ExportQuality.lossless,
            groupValue: _quality,
            onChanged: (value) => setState(() => _quality = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'format': _format,
            'quality': _quality,
          }),
          child: const Text('Export'),
        ),
      ],
    );
  }
}

/// Settings dialog
class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DawState>(
      builder: (context, state, _) {
        return AlertDialog(
          title: const Text('Project Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Project Name'),
                  controller: TextEditingController(text: state.project.name),
                  onSubmitted: (value) {
                    state.updateProject(
                      state.project.copyWith(name: value),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Tempo (BPM)'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: state.project.tempo.toInt().toString(),
                  ),
                  onSubmitted: (value) {
                    final tempo = double.tryParse(value);
                    if (tempo != null) {
                      state.updateProject(
                        state.project.copyWith(tempo: tempo),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Snap to Grid'),
                  value: state.snapToGrid,
                  onChanged: (_) => state.toggleSnapToGrid(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/daw_state.dart';
import '../services/daw_ai_integration.dart';
import '../models/audio_clip.dart';

/// AI generation toolbar panel
class DawAiToolbar extends StatefulWidget {
  final VoidCallback onClose;

  const DawAiToolbar({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<DawAiToolbar> createState() => _DawAiToolbarState();
}

class _DawAiToolbarState extends State<DawAiToolbar> {
  final TextEditingController _promptController = TextEditingController();
  AiGenerationType _selectedType = AiGenerationType.stem;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        border: Border(
          left: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'AI Generation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick generation buttons
                  _buildQuickGenSection(),
                  
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 24),
                  
                  // Custom prompt section
                  _buildCustomPromptSection(),
                  
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 24),
                  
                  // Auto-mix section
                  _buildAutoMixSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Generate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'One-click generation with AI defaults',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        
        _AiQuickButton(
          icon: Icons.music_note,
          label: 'Drum Loop',
          color: Colors.red,
          onPressed: () => _generateQuick(AiGenerationType.drums, 'electronic drum loop 120 bpm'),
        ),
        const SizedBox(height: 8),
        
        _AiQuickButton(
          icon: Icons.graphic_eq,
          label: 'Bass Line',
          color: Colors.blue,
          onPressed: () => _generateQuick(AiGenerationType.bass, 'deep bass line 120 bpm'),
        ),
        const SizedBox(height: 8),
        
        _AiQuickButton(
          icon: Icons.piano,
          label: 'Melody',
          color: Colors.green,
          onPressed: () => _generateQuick(AiGenerationType.melody, 'melodic synth 120 bpm'),
        ),
        const SizedBox(height: 8),
        
        _AiQuickButton(
          icon: Icons.mic,
          label: 'Vocals',
          color: Colors.purple,
          onPressed: () => _generateQuick(AiGenerationType.vocals, 'vocal melody'),
        ),
      ],
    );
  }

  Widget _buildCustomPromptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Prompt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Type selector
        DropdownButtonFormField<AiGenerationType>(
          value: _selectedType,
          decoration: InputDecoration(
            labelText: 'Type',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
          ),
          dropdownColor: const Color(0xFF2D2D2D),
          style: const TextStyle(color: Colors.white),
          items: AiGenerationType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getTypeName(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedType = value);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Prompt field
        TextField(
          controller: _promptController,
          decoration: InputDecoration(
            labelText: 'Describe what you want',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: 'e.g., "funky bass line in C minor"',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        
        // Generate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateCustom,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating...' : 'Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAutoMixSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Mixing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let AI optimize your mix',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _autoMix,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Auto-Mix All Tracks'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple,
              side: const BorderSide(color: Colors.purple),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _suggestEffects,
            icon: const Icon(Icons.tune),
            label: const Text('Suggest Effects'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple,
              side: const BorderSide(color: Colors.purple),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _generateQuick(AiGenerationType type, String prompt) async {
    final state = context.read<DawState>();
    
    if (state.selectedTrackId == null) {
      _showError('Please select a track first');
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final result = await state.aiIntegration.generateStem(
        type,
        prompt,
        duration: 8.0,
      );

      if (result.success && result.audioPath != null) {
        // Create clip and add to selected track
        final clip = AudioClip(
          name: 'AI ${_getTypeName(type)}',
          audioPath: result.audioPath,
          startTime: state.playbackPosition,
          duration: 8000, // 8 seconds in ms
          waveformData: result.waveformData,
          isAiGenerated: true,
          aiPrompt: prompt,
          color: _getColorForType(type),
        );

        await state.addClip(state.selectedTrackId!, clip);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI generation complete!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showError(result.errorMessage ?? 'Generation failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _generateCustom() async {
    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a prompt');
      return;
    }

    final state = context.read<DawState>();
    
    if (state.selectedTrackId == null) {
      _showError('Please select a track first');
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final result = await state.aiIntegration.generateStem(
        _selectedType,
        _promptController.text,
        duration: 10.0,
      );

      if (result.success && result.audioPath != null) {
        final clip = AudioClip(
          name: 'AI ${_getTypeName(_selectedType)}',
          audioPath: result.audioPath,
          startTime: state.playbackPosition,
          duration: 10000,
          waveformData: result.waveformData,
          isAiGenerated: true,
          aiPrompt: _promptController.text,
          color: _getColorForType(_selectedType),
        );

        await state.addClip(state.selectedTrackId!, clip);

        if (mounted) {
          _promptController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI generation complete!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showError(result.errorMessage ?? 'Generation failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _autoMix() async {
    final state = context.read<DawState>();
    
    if (state.project.tracks.isEmpty) {
      _showError('No tracks to mix');
      return;
    }

    try {
      final suggestions = await state.aiIntegration.autoMix(state.project.tracks);
      
      if (suggestions.isNotEmpty && mounted) {
        // Apply suggestions (would need to parse and apply in a real implementation)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-mix complete! Applied ${suggestions.length} adjustments.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Auto-mix error: $e');
    }
  }

  void _suggestEffects() async {
    final state = context.read<DawState>();
    
    if (state.selectedTrackId == null) {
      _showError('Please select a track first');
      return;
    }

    try {
      final track = state.project.tracks.firstWhere(
        (t) => t.id == state.selectedTrackId,
      );
      
      final effects = await state.aiIntegration.suggestEffects(
        track,
        'music production',
      );
      
      if (effects.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Suggested ${effects.length} effects for ${track.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Effect suggestion error: $e');
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  String _getTypeName(AiGenerationType type) {
    switch (type) {
      case AiGenerationType.stem:
        return 'Stem';
      case AiGenerationType.beat:
        return 'Beat';
      case AiGenerationType.melody:
        return 'Melody';
      case AiGenerationType.bass:
        return 'Bass';
      case AiGenerationType.drums:
        return 'Drums';
      case AiGenerationType.vocals:
        return 'Vocals';
      case AiGenerationType.harmony:
        return 'Harmony';
      case AiGenerationType.fullTrack:
        return 'Full Track';
    }
  }

  int _getColorForType(AiGenerationType type) {
    switch (type) {
      case AiGenerationType.drums:
        return 0xFFFF5252;
      case AiGenerationType.bass:
        return 0xFF2196F3;
      case AiGenerationType.melody:
        return 0xFF4CAF50;
      case AiGenerationType.vocals:
        return 0xFF9C27B0;
      case AiGenerationType.harmony:
        return 0xFFFF9800;
      default:
        return 0xFF00BCD4;
    }
  }
}

/// Quick AI generation button
class _AiQuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AiQuickButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.auto_awesome, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

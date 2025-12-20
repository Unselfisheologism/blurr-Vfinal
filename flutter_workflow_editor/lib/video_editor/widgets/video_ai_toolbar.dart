import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/video_editor_state.dart';

class VideoAIToolbar extends StatelessWidget {
  final Future<void> Function() onGenerateClip;
  final Future<void> Function() onAutoCaptions;
  final Future<void> Function() onSmartTransitions;
  final Future<void> Function() onEnhance;

  const VideoAIToolbar({
    super.key,
    required this.onGenerateClip,
    required this.onAutoCaptions,
    required this.onSmartTransitions,
    required this.onEnhance,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoEditorState>(
      builder: (context, state, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _chip(
                context,
                icon: Icons.auto_awesome,
                label: 'Generate clip',
                isPro: true,
                enabled: !state.isExporting,
                onTap: onGenerateClip,
              ),
              const SizedBox(width: 8),
              _chip(
                context,
                icon: Icons.closed_caption,
                label: 'Auto captions',
                isPro: true,
                enabled: state.selectedClip != null,
                onTap: onAutoCaptions,
              ),
              const SizedBox(width: 8),
              _chip(
                context,
                icon: Icons.auto_fix_high,
                label: 'Smart transitions',
                isPro: true,
                enabled: (state.project?.tracks.any((t) => t.clips.length >= 2) ?? false),
                onTap: onSmartTransitions,
              ),
              const SizedBox(width: 8),
              _chip(
                context,
                icon: Icons.tune,
                label: 'Enhance',
                isPro: true,
                enabled: state.selectedClip != null,
                onTap: onEnhance,
              ),
              const SizedBox(width: 8),
              if (!state.isPro)
                Text(
                  'Pro required for AI features',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPro,
    required bool enabled,
    required Future<void> Function() onTap,
  }) {
    final state = context.read<VideoEditorState>();
    final blocked = isPro && !state.isPro;

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: (!enabled)
          ? null
          : () async {
              if (blocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upgrade to Pro to use this feature.')),
                );
                return;
              }
              await onTap();
            },
    );
  }
}

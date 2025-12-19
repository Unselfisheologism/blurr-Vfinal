import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../state/learning_platform_state.dart';

class AudioOverviewWidget extends StatefulWidget {
  const AudioOverviewWidget({super.key});

  @override
  State<AudioOverviewWidget> createState() => _AudioOverviewWidgetState();
}

class _AudioOverviewWidgetState extends State<AudioOverviewWidget> {
  final AudioPlayer _player = AudioPlayer();

  String? _loadedPath;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningPlatformState>();
    final doc = state.selected;

    if (doc == null) {
      return const _Empty(message: 'Select a document in Library.');
    }

    if (!state.isProUser) {
      return const _Empty(
        message: 'Audio overviews are a Pro feature. Upgrade to unlock.',
      );
    }

    final path = doc.audioFilePath;
    if (path == null || path.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No audio overview yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap Generate to create a short, listenable overview of this document.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.isBusy
                      ? null
                      : () async {
                          try {
                            await context.read<LearningPlatformState>().generateAudioOverview();
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  icon: const Icon(Icons.graphic_eq_outlined),
                  label: const Text('Generate'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Audio overview', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              FutureBuilder<void>(
                future: _loadIfNeeded(path),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text('Failed to load audio: ${snapshot.error}');
                  }

                  return StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, stateSnapshot) {
                      final playerState = stateSnapshot.data;
                      final playing = playerState?.playing ?? false;
                      final processing = playerState?.processingState;

                      final isLoading = processing == ProcessingState.loading ||
                          processing == ProcessingState.buffering;

                      return Column(
                        children: [
                          StreamBuilder<Duration>(
                            stream: _player.positionStream,
                            builder: (context, posSnap) {
                              final pos = posSnap.data ?? Duration.zero;
                              final dur = _player.duration ?? Duration.zero;

                              final max = dur.inMilliseconds == 0 ? 1.0 : dur.inMilliseconds.toDouble();
                              final value = pos.inMilliseconds.clamp(0, dur.inMilliseconds).toDouble();

                              return Column(
                                children: [
                                  Slider(
                                    value: value,
                                    max: max,
                                    onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_fmt(pos), style: Theme.of(context).textTheme.labelMedium),
                                      Text(_fmt(dur), style: Theme.of(context).textTheme.labelMedium),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: () async {
                                  final pos = _player.position;
                                  await _player.seek(pos - const Duration(seconds: 10));
                                },
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (playing) {
                                          _player.pause();
                                        } else {
                                          _player.play();
                                        }
                                      },
                                child: SizedBox(
                                  width: 88,
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(playing ? 'Pause' : 'Play'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: () async {
                                  final pos = _player.position;
                                  await _player.seek(pos + const Duration(seconds: 10));
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadIfNeeded(String path) async {
    if (_loadedPath == path) return;

    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Audio file not found.');
    }

    await _player.setFilePath(path);
    _loadedPath = path;
  }

  String _fmt(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');

    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${two(minutes)}:${two(seconds)}';
  }
}

class _Empty extends StatelessWidget {
  final String message;

  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

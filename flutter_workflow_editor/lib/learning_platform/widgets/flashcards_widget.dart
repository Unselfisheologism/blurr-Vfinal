import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document_item.dart';
import '../state/learning_platform_state.dart';

class FlashcardsWidget extends StatefulWidget {
  const FlashcardsWidget({super.key});

  @override
  State<FlashcardsWidget> createState() => _FlashcardsWidgetState();
}

class _FlashcardsWidgetState extends State<FlashcardsWidget> {
  final PageController _controller = PageController();
  final Set<String> _flipped = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<LearningPlatformState>().selected;

    if (doc == null) {
      return const _Empty(message: 'Select a document in Library.');
    }

    final cards = doc.flashcards;
    if (cards.isEmpty) {
      return const _Empty(message: 'No flashcards yet. Tap “Flashcards” to generate a deck.');
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${cards.length} cards',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () => setState(_flipped.clear),
                child: const Text('Reset flips'),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final isFlipped = _flipped.contains(card.id);

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _FlashcardView(
                  card: card,
                  isFlipped: isFlipped,
                  onFlip: () {
                    setState(() {
                      if (isFlipped) {
                        _flipped.remove(card.id);
                      } else {
                        _flipped.add(card.id);
                      }
                    });
                  },
                  positionLabel: '${index + 1}/${cards.length}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FlashcardView extends StatelessWidget {
  final Flashcard card;
  final bool isFlipped;
  final VoidCallback onFlip;
  final String positionLabel;

  const _FlashcardView({
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    required this.positionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onFlip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    positionLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 44, 18, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          final rotate = (1 - animation.value) * math.pi;
                          final tilt = (animation.value - 0.5) * 0.04;
                          return Transform(
                            transform: Matrix4.rotationY(rotate)..setEntry(3, 0, tilt),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                      );
                    },
                    child: Text(
                      isFlipped ? card.back : card.front,
                      key: ValueKey(isFlipped),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 12,
                right: 16,
                child: Text(
                  isFlipped ? 'Tap to show front' : 'Tap to reveal answer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

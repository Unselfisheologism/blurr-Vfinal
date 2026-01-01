import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document_item.dart';
import '../state/learning_platform_state.dart';

class ChatInterfaceWidget extends StatefulWidget {
  const ChatInterfaceWidget({super.key});

  @override
  State<ChatInterfaceWidget> createState() => _ChatInterfaceWidgetState();
}

class _ChatInterfaceWidgetState extends State<ChatInterfaceWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LearningPlatformState>();
    final doc = state.selected;

    if (doc == null) {
      return const _Empty(message: 'Select a document in Library.');
    }

    final messages = doc.chatHistory;

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const _Empty(
                  message: 'Ask a question about this document. Answers are scoped to the uploaded content.',
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.role == 'user';
                    return _Bubble(message: msg, isUser: isUser);
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(context),
                    decoration: const InputDecoration(
                      hintText: 'Ask about this document…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: state.isBusy ? null : () => _send(context),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _send(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    try {
      await context.read<LearningPlatformState>().sendChatMessage(text);
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _Bubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = isUser ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = isUser ? cs.onPrimaryContainer : cs.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
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

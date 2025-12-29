/// AI prompt panel for generating media (Jaaz CanvasMagicGenerator-inspired)
import 'package:flutter/material.dart';

class AIPromptPanel extends StatefulWidget {
  final Function(String prompt, String mediaType) onGenerate;
  final bool isGenerating;
  final bool isPro;

  const AIPromptPanel({
    super.key,
    required this.onGenerate,
    this.isGenerating = false,
    this.isPro = false,
  });

  @override
  State<AIPromptPanel> createState() => _AIPromptPanelState();
}

class _AIPromptPanelState extends State<AIPromptPanel> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedMediaType = 'image';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handleGenerate() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    widget.onGenerate(prompt, _selectedMediaType);
    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurradius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Magic header
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Magic Generator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const Spacer(),
                  if (!widget.isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Media type selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMediaTypeButton('image', Icons.image, 'Image'),
                    const SizedBox(width: 8),
                    _buildMediaTypeButton('video', Icons.videocam, 'Video', isPro: true),
                    const SizedBox(width: 8),
                    _buildMediaTypeButton('audio', Icons.audiotrack, 'Audio', isPro: true),
                    const SizedBox(width: 8),
                    _buildMediaTypeButton('text', Icons.text_fields, 'Text'),
                    const SizedBox(width: 8),
                    _buildMediaTypeButton('3d', Icons.view_in_ar, '3D Model', isPro: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Prompt input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: 'Describe what you want to create...',
                        prefixIcon: const Icon(Icons.lightbulb_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.purple.shade200),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleGenerate(),
                      enabled: !widget.isGenerating,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: widget.isGenerating ? null : _handleGenerate,
                    backgroundColor: Colors.purple,
                    child: widget.isGenerating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                ],
              ),

              // Quick prompts
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickPrompt('Sunset landscape'),
                    _buildQuickPrompt('Abstract art'),
                    _buildQuickPrompt('Product photo'),
                    _buildQuickPrompt('Tech background'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTypeButton(String type, IconData icon, String label, {bool isPro = false}) {
    final isSelected = _selectedMediaType == type;
    final isLocked = isPro && !widget.isPro;

    return Expanded(
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () {
                setState(() {
                  _selectedMediaType = type;
                });
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isSelected ? Colors.white : (isLocked ? Colors.grey : Colors.purple),
                  ),
                  if (isLocked)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : (isLocked ? Colors.grey : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompt(String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(prompt),
        avatar: const Icon(Icons.flash_on, size: 16),
        onPressed: () {
          _promptController.text = prompt;
        },
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.purple.shade200),
      ),
    );
  }
}

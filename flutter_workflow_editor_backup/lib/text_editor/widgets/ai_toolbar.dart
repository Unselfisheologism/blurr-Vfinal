import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../services/ai_assistant_service.dart';

/// Custom AI-powered toolbar for text editing operations
/// 
/// Provides quick access to AI operations like rewrite, summarize, expand, etc.
class AIToolbar extends StatelessWidget {
  final QuillController controller;
  final bool isProcessing;
  final bool isProUser;
  final Function({
    required String operation,
    String? instruction,
    Map<String, dynamic>? context,
  }) onAIOperation;
  final VoidCallback onShowProDialog;

  const AIToolbar({
    Key? key,
    required this.controller,
    required this.isProcessing,
    required this.isProUser,
    required this.onAIOperation,
    required this.onShowProDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'AI Tools:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            
            // Rewrite button
            _buildAIButton(
              context: context,
              icon: Icons.edit,
              label: 'Rewrite',
              onPressed: () => _showRewriteDialog(context),
            ),
            
            // Summarize button
            _buildAIButton(
              context: context,
              icon: Icons.summarize,
              label: 'Summarize',
              onPressed: () => _showSummarizeDialog(context),
            ),
            
            // Expand button
            _buildAIButton(
              context: context,
              icon: Icons.expand_more,
              label: 'Expand',
              onPressed: () {
                onAIOperation(
                  operation: AIAssistantService.operationExpand,
                  instruction: 'Expand on this text with more details',
                );
              },
            ),
            
            // Continue button
            _buildAIButton(
              context: context,
              icon: Icons.play_arrow,
              label: 'Continue',
              onPressed: () {
                onAIOperation(
                  operation: AIAssistantService.operationContinue,
                  instruction: 'Continue writing from here',
                );
              },
            ),
            
            // Fix Grammar button
            _buildAIButton(
              context: context,
              icon: Icons.check,
              label: 'Fix',
              onPressed: () {
                onAIOperation(
                  operation: AIAssistantService.operationGrammar,
                  instruction: 'Fix grammar and spelling',
                );
              },
            ),
            
            // Translate button
            _buildAIButton(
              context: context,
              icon: Icons.translate,
              label: 'Translate',
              onPressed: () => _showTranslateDialog(context),
            ),
            
            // Generate button (Pro)
            _buildAIButton(
              context: context,
              icon: Icons.auto_fix_high,
              label: 'Generate',
              isPro: true,
              onPressed: isProUser
                  ? () => _showGenerateDialog(context)
                  : onShowProDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPro = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: OutlinedButton.icon(
        onPressed: isProcessing ? null : onPressed,
        icon: Icon(icon, size: 16),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            if (isPro && !isProUser) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 12, color: Colors.amber),
            ],
          ],
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 32),
          side: BorderSide(
            color: isPro && !isProUser ? Colors.amber : Colors.blue.shade300,
          ),
          foregroundColor: isPro && !isProUser ? Colors.amber.shade700 : Colors.blue.shade700,
        ),
      ),
    );
  }

  void _showRewriteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rewrite Text'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a tone:'),
            const SizedBox(height: 16),
            _buildToneOption(
              context,
              'Professional',
              AIAssistantService.toneProfessional,
              Icons.business_center,
            ),
            _buildToneOption(
              context,
              'Casual',
              AIAssistantService.toneCasual,
              Icons.chat_bubble_outline,
            ),
            _buildToneOption(
              context,
              'Creative',
              AIAssistantService.toneCreative,
              Icons.palette,
            ),
            _buildToneOption(
              context,
              'Formal',
              AIAssistantService.toneFormal,
              Icons.gavel,
            ),
            _buildToneOption(
              context,
              'Friendly',
              AIAssistantService.toneFriendly,
              Icons.favorite,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildToneOption(
    BuildContext context,
    String label,
    String tone,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onAIOperation(
          operation: AIAssistantService.operationRewrite,
          instruction: 'Rewrite this text in a $tone tone',
          context: {'tone': tone},
        );
      },
    );
  }

  void _showSummarizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Summarize Text'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose summary length:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.short_text, color: Colors.blue),
              title: const Text('Brief'),
              subtitle: const Text('Short, concise summary'),
              onTap: () {
                Navigator.pop(context);
                onAIOperation(
                  operation: AIAssistantService.operationSummarize,
                  instruction: 'Provide a brief summary',
                  context: {'length': AIAssistantService.lengthBrief},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.subject, color: Colors.blue),
              title: const Text('Detailed'),
              subtitle: const Text('Comprehensive summary'),
              onTap: () {
                Navigator.pop(context);
                onAIOperation(
                  operation: AIAssistantService.operationSummarize,
                  instruction: 'Provide a detailed summary',
                  context: {'length': AIAssistantService.lengthDetailed},
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTranslateDialog(BuildContext context) {
    final languages = [
      {'name': 'Spanish', 'code': 'es'},
      {'name': 'French', 'code': 'fr'},
      {'name': 'German', 'code': 'de'},
      {'name': 'Italian', 'code': 'it'},
      {'name': 'Portuguese', 'code': 'pt'},
      {'name': 'Chinese', 'code': 'zh'},
      {'name': 'Japanese', 'code': 'ja'},
      {'name': 'Korean', 'code': 'ko'},
      {'name': 'Russian', 'code': 'ru'},
      {'name': 'Arabic', 'code': 'ar'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translate To'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              return ListTile(
                title: Text(lang['name']!),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  onAIOperation(
                    operation: AIAssistantService.operationTranslate,
                    instruction: 'Translate to ${lang['name']}',
                    context: {'targetLanguage': lang['code']!},
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showGenerateDialog(BuildContext context) {
    final promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_fix_high, color: Colors.amber),
            SizedBox(width: 8),
            Text('Generate Content'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Describe what you want to generate:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: promptController,
              decoration: const InputDecoration(
                labelText: 'Your prompt',
                hintText: 'e.g., Write an introduction about AI',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            if (!isProUser)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pro feature: Unlimited generations',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final prompt = promptController.text.trim();
              if (prompt.isNotEmpty) {
                Navigator.pop(context);
                onAIOperation(
                  operation: AIAssistantService.operationGenerate,
                  instruction: prompt,
                  context: {'prompt': prompt},
                );
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}

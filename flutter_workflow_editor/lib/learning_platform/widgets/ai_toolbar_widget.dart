import 'package:flutter/material.dart';
import '../models/document_item.dart';

/// AI Toolbar widget for Learning Platform
/// 
/// Provides quick access to AI-powered learning tools with Pro gating
/// and proper visual feedback for processing states.
class AIToolbarWidget extends StatelessWidget {
  final DocumentItem document;
  final bool isProUser;
  final Function(String) onOperationSelected;
  final bool isProcessing;

  const AIToolbarWidget({
    Key? key,
    required this.document,
    required this.isProUser,
    required this.onOperationSelected,
    required this.isProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Learning Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!isProUser)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // AI Operations Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildOperationCard(
                context,
                icon: Icons.summarize,
                title: 'Summarize',
                description: 'Generate document summary',
                operation: 'summarize',
                color: Colors.blue,
              ),
              
              _buildOperationCard(
                context,
                icon: Icons.quiz,
                title: 'Quiz',
                description: 'Create practice quiz',
                operation: 'quiz',
                color: Colors.green,
              ),
              
              _buildOperationCard(
                context,
                icon: Icons.flash_on,
                title: 'Flashcards',
                description: 'Generate study cards',
                operation: 'flashcards',
                color: Colors.orange,
              ),
              
              _buildOperationCard(
                context,
                icon: Icons.menu_book,
                title: 'Study Guide',
                description: 'Create detailed guide',
                operation: 'study_guide',
                color: Colors.purple,
                isPro: true,
              ),
              
              _buildOperationCard(
                context,
                icon: Icons.audio_file,
                title: 'Audio',
                description: 'Generate audio overview',
                operation: 'audio',
                color: Colors.red,
                isPro: true,
              ),
              
              _buildOperationCard(
                context,
                icon: Icons.lightbulb,
                title: 'Key Points',
                description: 'Extract main concepts',
                operation: 'key_points',
                color: Colors.teal,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Pro Upgrade Prompt
          if (!isProUser) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[50]!, Colors.amber[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.amber[700],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock advanced AI features: audio overviews, detailed study guides, unlimited documents, and priority processing.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showProUpgradeDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upgrade Now'),
                  ),
                ],
              ),
            ),
          ],
          
          // Processing Indicator
          if (isProcessing)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Processing with AI...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOperationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String operation,
    required Color color,
    bool isPro = false,
  }) {
    final bool isLocked = isPro && !isProUser;
    
    return GestureDetector(
      onTap: isLocked || isProcessing
          ? () => _handleLockedOperation(context, isPro)
          : () => _handleOperation(context, operation),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked ? Colors.grey[300]! : color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isLocked ? Colors.grey[400] : color,
                  size: 24,
                ),
                const Spacer(),
                if (isPro && !isProUser)
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.grey[400],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey[600] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isLocked ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOperation(BuildContext context, String operation) {
    Navigator.pop(context);
    onOperationSelected(operation);
  }

  void _handleLockedOperation(BuildContext context, bool isPro) {
    if (isPro && !isProUser) {
      Navigator.pop(context);
      _showProUpgradeDialog(context);
    }
  }

  void _showProUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: const Text(
          'This feature is available for Pro users only. '
          'Upgrade to unlock:\n\n'
          '• Audio study guides with natural voices\n'
          '• Detailed study guides and learning trails\n'
          '• Unlimited documents and storage\n'
          '• Priority AI processing\n'
          '• Advanced analytics and progress tracking\n'
          '• Export to all formats\n'
          '• Custom study schedules',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to Pro purchase screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }
}
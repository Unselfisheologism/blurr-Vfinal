/// AI-powered toolbar for spreadsheet operations
import 'package:flutter/material.dart';

class AIToolbar extends StatelessWidget {
  final VoidCallback onGenerateData;
  final VoidCallback onFillColumn;
  final VoidCallback onAnalyzeSelection;
  final VoidCallback onCreateChart;
  final VoidCallback onWriteFormula;
  final VoidCallback onSummarizeSheet;
  final bool hasSelection;
  final bool isProUser;

  const AIToolbar({
    super.key,
    required this.onGenerateData,
    required this.onFillColumn,
    required this.onAnalyzeSelection,
    required this.onCreateChart,
    required this.onWriteFormula,
    required this.onSummarizeSheet,
    this.hasSelection = false,
    this.isProUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurradius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.purple),
          const SizedBox(width: 8),
          const Text(
            'AI Assistant',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 16),
          
          // AI Actions
          _AIButton(
            icon: Icons.table_chart,
            label: 'Generate Data',
            onPressed: onGenerateData,
            isPro: !isProUser,
          ),
          _AIButton(
            icon: Icons.view_column,
            label: 'Fill Column',
            onPressed: hasSelection ? onFillColumn : null,
            isPro: !isProUser,
          ),
          _AIButton(
            icon: Icons.analytics,
            label: 'Analyze',
            onPressed: hasSelection ? onAnalyzeSelection : null,
            isPro: !isProUser,
          ),
          _AIButton(
            icon: Icons.bar_chart,
            label: 'Create Chart',
            onPressed: hasSelection ? onCreateChart : null,
            isPro: !isProUser,
          ),
          _AIButton(
            icon: Icons.functions,
            label: 'Write Formula',
            onPressed: hasSelection ? onWriteFormula : null,
            isPro: !isProUser,
          ),
          _AIButton(
            icon: Icons.summarize,
            label: 'Summarize',
            onPressed: onSummarizeSheet,
            isPro: !isProUser,
          ),
        ],
      ),
    );
  }
}

class _AIButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPro;

  const _AIButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Stack(
          children: [
            Icon(icon, size: 16),
            if (isPro)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.purple,
          side: BorderSide(color: Colors.purple.shade200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

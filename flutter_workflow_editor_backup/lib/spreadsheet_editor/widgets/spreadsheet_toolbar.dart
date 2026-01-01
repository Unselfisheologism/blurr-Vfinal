/// Toolbar for spreadsheet editor with formatting and AI actions
import 'package:flutter/material.dart';
import '../models/spreadsheet_cell.dart';

class SpreadsheetToolbar extends StatelessWidget {
  final VoidCallback onNew;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onAddRow;
  final VoidCallback onAddColumn;
  final VoidCallback onDeleteRow;
  final VoidCallback onDeleteColumn;
  final Function(CellFormat) onFormatApply;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool hasSelection;

  const SpreadsheetToolbar({
    super.key,
    required this.onNew,
    required this.onOpen,
    required this.onSave,
    required this.onExport,
    required this.onImport,
    required this.onAddRow,
    required this.onAddColumn,
    required this.onDeleteRow,
    required this.onDeleteColumn,
    required this.onFormatApply,
    required this.onUndo,
    required this.onRedo,
    this.hasSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          // File operations
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Spreadsheet',
            onPressed: onNew,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Open',
            onPressed: onOpen,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: onSave,
          ),
          const VerticalDivider(),

          // Row/Column operations
          IconButton(
            icon: const Icon(Icons.add_box),
            tooltip: 'Add Row',
            onPressed: onAddRow,
          ),
          IconButton(
            icon: const Icon(Icons.view_column),
            tooltip: 'Add Column',
            onPressed: onAddColumn,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Row',
            onPressed: hasSelection ? onDeleteRow : null,
          ),
          IconButton(
            icon: const Icon(Icons.view_week),
            tooltip: 'Delete Column',
            onPressed: hasSelection ? onDeleteColumn : null,
          ),
          const VerticalDivider(),

          // Formatting
          IconButton(
            icon: const Icon(Icons.format_bold),
            tooltip: 'Bold',
            onPressed: hasSelection
                ? () => onFormatApply(const CellFormat(bold: true))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.format_italic),
            tooltip: 'Italic',
            onPressed: hasSelection
                ? () => onFormatApply(const CellFormat(italic: true))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.format_underline),
            tooltip: 'Underline',
            onPressed: hasSelection
                ? () => onFormatApply(const CellFormat(underline: true))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.format_align_left),
            tooltip: 'Align Left',
            onPressed: hasSelection
                ? () => onFormatApply(const CellFormat(alignment: Alignment.centerLeft))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.format_align_center),
            tooltip: 'Align Center',
            onPressed: hasSelection
                ? () => onFormatApply(const CellFormat(alignment: Alignment.center))
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.format_align_right),
            tooltip: 'Align Right',
            onPressed: hasSelection
                ? () => onFormatApply(const CellFormat(alignment: Alignment.centerRight))
                : null,
          ),
          const VerticalDivider(),

          // Import/Export
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import Excel',
            onPressed: onImport,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export',
            onPressed: onExport,
          ),
          const VerticalDivider(),

          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: onUndo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: onRedo,
          ),

          const Spacer(),

          // Close button
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

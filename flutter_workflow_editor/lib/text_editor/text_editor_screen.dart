import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'models/document.dart';
import 'services/document_service.dart';
import 'services/ai_assistant_service.dart';
import 'services/export_service.dart';
import 'widgets/ai_toolbar.dart';
import 'widgets/document_list.dart';

/// Main screen for AI-Native Text Editor
/// 
/// Provides rich text editing with AI assistance, document management,
/// and export capabilities.
class TextEditorScreen extends StatefulWidget {
  final String? documentId;
  final bool startWithTemplate;

  const TextEditorScreen({
    Key? key,
    this.documentId,
    this.startWithTemplate = false,
  }) : super(key: key);

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  // Services
  final DocumentService _documentService = DocumentService();
  final AIAssistantService _aiService = AIAssistantService();
  final ExportService _exportService = ExportService();
  final ImagePicker _imagePicker = ImagePicker();

  // Quill editor controller
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Current document
  EditorDocument? _currentDocument;
  bool _isModified = false;
  bool _isSaving = false;
  bool _isProcessingAI = false;
  bool _isInitializing = false;
  String? _error;

  // UI state
  bool _showDocumentList = false;
  bool _isProUser = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitializing) return;
    
    setState(() {
      _isInitializing = true;
    });

    try {
      // Ensure document service is fully initialized
      await _documentService.initialize();
      
      // Check Pro status
      _isProUser = await _aiService.checkProAccess();

      if (widget.documentId != null) {
        // Load existing document
        await _loadDocument(widget.documentId!);
      } else if (widget.startWithTemplate) {
        // Show template picker
        _showTemplatePicker();
      } else {
        // Create new empty document
        _createNewDocument();
      }

      // Listen for document changes
      if (_controller != null) {
        _controller!.addListener(_onDocumentChanged);
      }
    } catch (e) {
      _error = 'Failed to initialize text editor: $e';
      print('TextEditor Init Error: $e');  // Log for debugging
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _createNewDocument({EditorDocument? template}) {
    _currentDocument = template != null
        ? EditorDocument(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: template.title.replaceAll('Template', 'Document'),
            content: List.from(template.content),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            tags: template.tags.where((tag) => tag != 'template').toList(),
          )
        : EditorDocument.empty();

    _controller = QuillController(
      document: Document.fromJson(_currentDocument!.content),
      selection: const TextSelection.collapsed(offset: 0),
    );

    _isModified = false;
    setState(() {}); // Force UI update to show the editor
  }

  Future<void> _loadDocument(String documentId) async {
    final document = await _documentService.loadDocument(documentId);
    
    if (document != null) {
      _currentDocument = document;
      _controller = QuillController(
        document: Document.fromJson(document.content),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _isModified = false;
      setState(() {});
    } else {
      _showError('Document not found');
      _createNewDocument();
    }
  }

  void _onDocumentChanged() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  Future<void> _saveDocument() async {
    if (_currentDocument == null || _controller == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedDocument = _currentDocument!.copyWithDelta(
        _controller!.document.toDelta(),
      );

      await _documentService.saveDocument(updatedDocument);

      _currentDocument = updatedDocument;
      _isModified = false;

      _showSnackBar('Document saved', success: true);
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _autoSave() async {
    if (_isModified && !_isSaving && _currentDocument != null) {
      await _saveDocument();
    }
  }

  void _showTemplatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Choose a Template',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: DocumentTemplates.templates.length,
                  itemBuilder: (context, index) {
                    final template = DocumentTemplates.templates[index];
                    final isLocked = template.requiresPro && !_isProUser;

                    return ListTile(
                      leading: Icon(
                        _getTemplateIcon(template.templateCategory ?? ''),
                        color: isLocked ? Colors.grey : Theme.of(context).primaryColor,
                      ),
                      title: Text(template.title),
                      subtitle: Text(
                        template.templateCategory ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      trailing: isLocked
                          ? const Icon(Icons.lock, color: Colors.grey)
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: isLocked
                          ? () => _showProUpgradeDialog()
                          : () {
                              Navigator.pop(context);
                              _createNewDocument(template: template);
                              setState(() {});
                            },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getTemplateIcon(String category) {
    switch (category) {
      case 'blog':
        return Icons.article;
      case 'email':
        return Icons.email;
      case 'essay':
        return Icons.school;
      case 'report':
        return Icons.assignment;
      case 'notes':
        return Icons.note;
      case 'creative':
        return Icons.auto_stories;
      default:
        return Icons.description;
    }
  }

  void _showProUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: const Text(
          'This template is only available for Pro users. '
          'Upgrade to unlock all templates and advanced AI features.',
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
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAIOperation({
    required String operation,
    String? instruction,
    Map<String, dynamic>? context,
  }) async {
    if (_controller == null) {
      _showError('Editor not ready');
      return;
    }

    // Get selected text
    final selection = _controller!.selection;
    if (!selection.isValid || selection.isCollapsed && operation != AIAssistantService.operationContinue) {
      _showError('Please select some text first');
      return;
    }

    final selectedText = selection.isCollapsed
        ? _controller!.document.toPlainText()
        : _controller!.document
            .toPlainText()
            .substring(selection.start, selection.end);

    if (selectedText.trim().isEmpty && operation != AIAssistantService.operationContinue) {
      _showError('Please select some text first');
      return;
    }

    // Check Pro access for long operations
    if (selectedText.length > 1000 && !_isProUser) {
      _showProUpgradeDialog();
      return;
    }

    setState(() {
      _isProcessingAI = true;
    });

    try {
      final result = await _aiService.processRequest(
        operation: operation,
        text: selectedText,
        instruction: instruction,
        additionalContext: context,
      );

      if (result.success) {
        // Replace selection with AI result
        _replaceSelection(result.text);
        _showSnackBar('AI operation completed', success: true);
      } else {
        _showError(result.error ?? 'AI operation failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isProcessingAI = false;
      });
    }
  }

  void _replaceSelection(String newText) {
    if (_controller == null) return;

    final selection = _controller!.selection;

    if (selection.isCollapsed) {
      // Insert at cursor
      _controller!.document.insert(selection.baseOffset, newText);
      _controller!.updateSelection(
        TextSelection.collapsed(offset: selection.baseOffset + newText.length),
        ChangeSource.local,
      );
    } else {
      // Replace selection
      _controller!.replaceText(
        selection.start,
        selection.end - selection.start,
        newText,
        TextSelection.collapsed(offset: selection.start + newText.length),
      );
    }

    _isModified = true;
  }

  void _showError(String message) {
    _showSnackBar(message, success: false);
  }

  /// Insert image from gallery or camera
  Future<void> _insertImage() async {
    if (_controller == null) {
      _showError('Editor not ready');
      return;
    }

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('From Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // Insert image into document
        final index = _controller!.selection.baseOffset;
        final length = _controller!.selection.extentOffset - index;

        // For now, insert as a simple image embed
        // In production, you'd want to handle image storage properly
        _controller!.document.insert(index, BlockEmbed.image(image.path));
        _controller!.updateSelection(
          TextSelection.collapsed(offset: index + 1),
          ChangeSource.local,
        );

        _isModified = true;
        setState(() {});

        _showSnackBar('Image inserted', success: true);
      }
    } catch (e) {
      _showError('Failed to insert image: $e');
    }
  }

  /// Insert video from gallery (Pro feature)
  Future<void> _insertVideo() async {
    if (_controller == null) {
      _showError('Editor not ready');
      return;
    }

    if (!_isProUser) {
      _showProUpgradeDialog();
      return;
    }

    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        // Insert video into document
        final index = _controller!.selection.baseOffset;

        // For now, insert as a simple video embed
        _controller!.document.insert(index, BlockEmbed.video(video.path));
        _controller!.updateSelection(
          TextSelection.collapsed(offset: index + 1),
          ChangeSource.local,
        );

        _isModified = true;
        setState(() {});

        _showSnackBar('Video inserted', success: true);
      }
    } catch (e) {
      _showError('Failed to insert video: $e');
    }
  }

  void _showSnackBar(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportDocument() async {
    if (_currentDocument == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Export Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Export as Plain Text'),
              subtitle: const Text('Simple text file (.txt)'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPlainText();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as Markdown'),
              subtitle: const Text('Markdown format (.md)'),
              onTap: () {
                Navigator.pop(context);
                _exportAsMarkdown();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Export as HTML'),
              subtitle: const Text('Web page (.html)'),
              onTap: () {
                Navigator.pop(context);
                _exportAsHTML();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: const Text('Portable Document Format'),
              trailing: !_isProUser ? const Icon(Icons.lock, size: 16, color: Colors.amber) : null,
              onTap: () {
                Navigator.pop(context);
                if (_isProUser) {
                  _exportAsPDF();
                } else {
                  _showProUpgradeDialog();
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share'),
              subtitle: const Text('Share via other apps'),
              onTap: () {
                Navigator.pop(context);
                _showShareOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.print, color: Colors.blue),
              title: const Text('Print'),
              subtitle: const Text('Print document'),
              trailing: !_isProUser ? const Icon(Icons.lock, size: 16, color: Colors.amber) : null,
              onTap: () {
                Navigator.pop(context);
                if (_isProUser) {
                  _printDocument();
                } else {
                  _showProUpgradeDialog();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsPlainText() async {
    if (_currentDocument == null || _controller == null) return;

    _showSnackBar('Exporting as plain text...', success: true);

    try {
      final result = await _exportService.exportAsPlainText(
        document: _currentDocument!,
        delta: _controller!.document.toDelta(),
      );

      if (result.success) {
        _showSnackBar('Exported to ${result.fileName}', success: true);
        // Optionally open the file or show a dialog with the path
      } else {
        _showError(result.error ?? 'Export failed');
      }
    } catch (e) {
      _showError('Failed to export: $e');
    }
  }

  Future<void> _exportAsMarkdown() async {
    if (_currentDocument == null || _controller == null) return;

    _showSnackBar('Exporting as Markdown...', success: true);

    try {
      final result = await _exportService.exportAsMarkdown(
        document: _currentDocument!,
        delta: _controller!.document.toDelta(),
      );

      if (result.success) {
        _showSnackBar('Exported to ${result.fileName}', success: true);
      } else {
        _showError(result.error ?? 'Export failed');
      }
    } catch (e) {
      _showError('Failed to export: $e');
    }
  }

  Future<void> _exportAsHTML() async {
    if (_currentDocument == null || _controller == null) return;

    _showSnackBar('Exporting as HTML...', success: true);

    try {
      final result = await _exportService.exportAsHTML(
        document: _currentDocument!,
        delta: _controller!.document.toDelta(),
      );

      if (result.success) {
        _showSnackBar('Exported to ${result.fileName}', success: true);
      } else {
        _showError(result.error ?? 'Export failed');
      }
    } catch (e) {
      _showError('Failed to export: $e');
    }
  }

  Future<void> _exportAsPDF() async {
    if (_currentDocument == null || _controller == null) return;

    _showSnackBar('Generating PDF...', success: true);

    try {
      final result = await _exportService.exportAsPDF(
        document: _currentDocument!,
        delta: _controller!.document.toDelta(),
      );

      if (result.success) {
        _showSnackBar('PDF generated: ${result.fileName}', success: true);
      } else {
        _showError(result.error ?? 'PDF generation failed');
      }
    } catch (e) {
      _showError('Failed to generate PDF: $e');
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Share As',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Plain Text'),
              onTap: () {
                Navigator.pop(context);
                _shareDocument(ShareFormat.plainText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Markdown'),
              onTap: () {
                Navigator.pop(context);
                _shareDocument(ShareFormat.markdown);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('HTML'),
              onTap: () {
                Navigator.pop(context);
                _shareDocument(ShareFormat.html);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              trailing: !_isProUser ? const Icon(Icons.lock, size: 16) : null,
              onTap: () {
                Navigator.pop(context);
                if (_isProUser) {
                  _shareDocument(ShareFormat.pdf);
                } else {
                  _showProUpgradeDialog();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareDocument(ShareFormat format) async {
    if (_currentDocument == null || _controller == null) return;

    _showSnackBar('Preparing to share...', success: true);

    try {
      final result = await _exportService.shareDocument(
        document: _currentDocument!,
        delta: _controller!.document.toDelta(),
        format: format,
      );

      if (!result.success) {
        _showError(result.error ?? 'Share failed');
      }
      // Success is indicated by the share sheet appearing
    } catch (e) {
      _showError('Failed to share: $e');
    }
  }

  Future<void> _printDocument() async {
    if (_currentDocument == null || _controller == null) return;

    _showSnackBar('Preparing to print...', success: true);

    try {
      await _exportService.printDocument(
        document: _currentDocument!,
        delta: _controller!.document.toDelta(),
      );
    } catch (e) {
      _showError('Failed to print: $e');
    }
  }

  @override
  void dispose() {
    _autoSave();
    _controller?.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || _currentDocument == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initialize,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isModified) {
          await _saveDocument();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () => _showRenameDialog(),
            child: Text(
              _currentDocument!.title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          actions: [
            if (_isModified)
              IconButton(
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveDocument,
                tooltip: 'Save',
              ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () {
                setState(() {
                  _showDocumentList = !_showDocumentList;
                });
              },
              tooltip: 'Documents',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'export':
                    _exportDocument();
                    break;
                  case 'template':
                    _showTemplatePicker();
                    break;
                  case 'new':
                    if (_isModified) {
                      _saveDocument().then((_) => _createNewDocument());
                    } else {
                      _createNewDocument();
                    }
                    setState(() {});
                    break;
                  case 'stats':
                    _showDocumentStats();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'new',
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('New Document'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'template',
                  child: Row(
                    children: [
                      Icon(Icons.description),
                      SizedBox(width: 8),
                      Text('Templates'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download),
                      SizedBox(width: 8),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'stats',
                  child: Row(
                    children: [
                      Icon(Icons.analytics),
                      SizedBox(width: 8),
                      Text('Statistics'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_isInitializing)
              const Center(child: CircularProgressIndicator())
            else if (_controller == null)
              const Center(child: Text('Error loading editor'))
            else
              Column(
                children: [
                  // Standard Quill Toolbar
                  QuillSimpleToolbar(
                    configurations: QuillSimpleToolbarConfigurations(
                      controller: _controller!,
                      multiRowsDisplay: false,
                      showAlignmentButtons: true,
                      showBackgroundColorButton: false,
                      showClearFormat: true,
                      showCodeBlock: true,
                      showColorButton: true,
                      showFontSize: true,
                      showHeaderStyle: true,
                      showIndent: true,
                      showInlineCode: true,
                      showLink: true,
                      showListBullets: true,
                      showListCheck: true,
                      showListNumbers: true,
                      showQuote: true,
                      showSearchButton: true,
                    showStrikeThrough: true,
                    showUnderLineButton: true,
                    // Custom embed buttons
                    embedButtons: [
                      // Image embed button
                      (controller, toolbarIconSize, iconTheme, dialogTheme) {
                        return IconButton(
                          icon: const Icon(Icons.image),
                          iconSize: toolbarIconSize,
                          tooltip: 'Insert Image',
                          onPressed: () => _insertImage(),
                        );
                      },
                      // Video embed button (Pro)
                      (controller, toolbarIconSize, iconTheme, dialogTheme) {
                        return IconButton(
                          icon: Icon(
                            Icons.videocam,
                            color: _isProUser ? null : Colors.grey,
                          ),
                          iconSize: toolbarIconSize,
                          tooltip: _isProUser ? 'Insert Video' : 'Insert Video (Pro)',
                          onPressed: _isProUser ? () => _insertVideo() : _showProUpgradeDialog,
                        );
                      },
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Custom AI Toolbar
                AIToolbar(
                  controller: _controller!,
                  isProcessing: _isProcessingAI,
                  isProUser: _isProUser,
                  onAIOperation: _handleAIOperation,
                  onShowProDialog: _showProUpgradeDialog,
                ),
                const Divider(height: 1),

                // Editor
                Expanded(
                  child: QuillEditor(
                    scrollController: _scrollController,
                    focusNode: _focusNode,
                    configurations: QuillEditorConfigurations(
                      controller: _controller!,
                      padding: const EdgeInsets.all(16),
                      autoFocus: false,
                      expands: true,
                      placeholder: 'Start writing...',
                      customStyles: DefaultStyles(
                        h1: DefaultTextBlockStyle(
                          const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          const VerticalSpacing(16, 8),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h2: DefaultTextBlockStyle(
                          const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          const VerticalSpacing(12, 8),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        paragraph: DefaultTextBlockStyle(
                          const TextStyle(fontSize: 16, height: 1.5),
                          const VerticalSpacing(8, 8),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                      embedBuilders: [
                        ...FlutterQuillEmbeds.editorBuilders(),
                      ],
                    ),
                  ),
                ),

                // Status bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_currentDocument!.getWordCount()} words',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_isModified)
                        Text(
                          'Modified',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      const Spacer(),
                      if (!_isProUser)
                        TextButton.icon(
                          onPressed: _showProUpgradeDialog,
                          icon: const Icon(Icons.star, size: 16),
                          label: const Text('Upgrade to Pro'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.amber[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Document list overlay
            if (_showDocumentList)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDocumentList = false;
                    });
                  },
                  child: Container(
                    color: Colors.black54,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {}, // Prevent tap-through
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          color: Colors.white,
                          child: DocumentListWidget(
                            documentService: _documentService,
                            currentDocumentId: _currentDocument!.id,
                            onDocumentSelected: (document) async {
                              if (_isModified) {
                                await _saveDocument();
                              }
                              await _loadDocument(document.id);
                              setState(() {
                                _showDocumentList = false;
                              });
                            },
                            onClose: () {
                              setState(() {
                                _showDocumentList = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // AI processing overlay
            if (_isProcessingAI)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing with AI...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _currentDocument!.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Document Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _currentDocument = _currentDocument!.copyWith(title: value.trim());
                _isModified = true;
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _currentDocument = _currentDocument!.copyWith(title: value);
                  _isModified = true;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDocumentStats() {
    final wordCount = _currentDocument!.getWordCount();
    final plainText = _currentDocument!.getPlainText();
    final charCount = plainText.length;
    final charCountNoSpaces = plainText.replaceAll(RegExp(r'\s'), '').length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow('Words', wordCount.toString()),
            _statRow('Characters', charCount.toString()),
            _statRow('Characters (no spaces)', charCountNoSpaces.toString()),
            _statRow('Created', _formatDate(_currentDocument!.createdAt)),
            _statRow('Modified', _formatDate(_currentDocument!.updatedAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

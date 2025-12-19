import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/document_item.dart';
import '../services/learning_platform_service.dart';
import '../services/learning_storage_service.dart';

/// Document upload and library management widget
/// 
/// Handles document selection, upload, and displays the document library
/// with search, filtering, and organization features.
class DocumentLibraryWidget extends StatefulWidget {
  final Function(DocumentItem) onDocumentSelected;
  final LearningPlatformService learningService;
  final LearningStorageService storageService;

  const DocumentLibraryWidget({
    Key? key,
    required this.onDocumentSelected,
    required this.learningService,
    required this.storageService,
  }) : super(key: key);

  @override
  State<DocumentLibraryWidget> createState() => _DocumentLibraryWidgetState();
}

class _DocumentLibraryWidgetState extends State<DocumentLibraryWidget> {
  List<DocumentItem> _documents = [];
  List<DocumentItem> _filteredDocuments = [];
  String _searchQuery = '';
  DocumentStatus? _filterStatus;
  bool _isLoading = true;
  String _sortBy = 'updated'; // updated, name, size, progress

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    
    try {
      final documents = widget.storageService.getAllDocuments();
      setState(() {
        _documents = documents;
        _filteredDocuments = _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load documents: $e');
    }
  }

  List<DocumentItem> _applyFilters() {
    var filtered = [..._documents];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = widget.storageService.searchDocuments(_searchQuery);
    }

    // Apply status filter
    if (_filterStatus != null) {
      filtered = filtered.where((doc) => doc.status == _filterStatus).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'size':
        filtered.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case 'progress':
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'updated':
      default:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return filtered;
  }

  Future<void> _uploadDocument() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showError('Storage permission is required to select files');
        return;
      }

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'md'],
        allowMultiple: false,
      );

      if (result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          await _processUploadedFile(
            file.path!,
            file.name,
            _getFileType(file.name),
          );
        }
      }
    } catch (e) {
      _showError('Failed to upload document: $e');
    }
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'docx';
      case 'txt':
        return 'text';
      case 'md':
        return 'markdown';
      default:
        return 'unknown';
    }
  }

  Future<void> _processUploadedFile(
    String filePath,
    String fileName,
    String fileType,
  ) async {
    // Create initial document item
    final document = DocumentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: fileName,
      filePath: filePath,
      content: '',
      fileType: fileType,
      fileSize: await _getFileSize(filePath),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: DocumentStatus.uploaded,
    );

    // Save to storage immediately
    await widget.storageService.saveDocument(document);

    // Process document content
    setState(() {
      _documents.insert(0, document);
      _filteredDocuments = _applyFilters();
    });

    // Process in background
    _processDocumentContent(document);
  }

  Future<int> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  Future<void> _processDocumentContent(DocumentItem document) async {
    try {
      // Update status to processing
      final updatedDoc = document.copyWith(status: DocumentStatus.processing);
      await widget.storageService.saveDocument(updatedDoc);
      
      // Process document
      final result = await widget.learningService.processDocument(
        filePath: document.filePath,
        fileName: document.name,
        fileType: document.fileType,
      );

      if (result.success && result.content != null) {
        final processedDoc = document.copyWith(
          content: result.content!,
          status: DocumentStatus.processed,
          updatedAt: DateTime.now(),
        );
        
        await widget.storageService.saveDocument(processedDoc);
        
        // Update UI
        setState(() {
          final index = _documents.indexWhere((doc) => doc.id == document.id);
          if (index != -1) {
            _documents[index] = processedDoc;
            _filteredDocuments = _applyFilters();
          }
        });
      } else {
        _showError('Failed to process document: ${result.error}');
        
        // Update status to error
        final errorDoc = document.copyWith(status: DocumentStatus.error);
        await widget.storageService.saveDocument(errorDoc);
        
        setState(() {
          final index = _documents.indexWhere((doc) => doc.id == document.id);
          if (index != -1) {
            _documents[index] = errorDoc;
            _filteredDocuments = _applyFilters();
          }
        });
      }
    } catch (e) {
      _showError('Document processing failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with upload button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                'Document Library',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _uploadDocument,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload'),
              ),
            ],
          ),
        ),

        // Search and filter bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search documents...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filteredDocuments = _applyFilters();
                  });
                },
              ),
              
              const SizedBox(height: 8),
              
              // Filter and sort controls
              Row(
                children: [
                  // Status filter
                  DropdownButton<DocumentStatus?>(
                    value: _filterStatus,
                    hint: const Text('All Status'),
                    onChanged: (status) {
                      setState(() {
                        _filterStatus = status;
                        _filteredDocuments = _applyFilters();
                      });
                    },
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Status')),
                      ...DocumentStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusLabel(status)),
                        );
                      }),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Sort dropdown
                  DropdownButton<String>(
                    value: _sortBy,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                          _filteredDocuments = _applyFilters();
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'updated', child: Text('Last Updated')),
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'size', child: Text('Size')),
                      DropdownMenuItem(value: 'progress', child: Text('Progress')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Documents list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDocuments.isEmpty
                  ? _buildEmptyState()
                  : _buildDocumentsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _documents.isEmpty
                ? 'No documents yet'
                : 'No documents match your filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _documents.isEmpty
                ? 'Upload your first document to get started'
                : 'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
          if (_documents.isEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _uploadDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredDocuments.length,
        itemBuilder: (context, index) {
          final document = _filteredDocuments[index];
          return _buildDocumentCard(document);
        },
      ),
    );
  }

  Widget _buildDocumentCard(DocumentItem document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildDocumentIcon(document.fileType),
        title: Text(
          document.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatFileSize(document.fileSize)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: document.progress,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 2),
            Text(_getStatusLabel(document.status)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, document),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Text('Open'),
            ),
            const PopupMenuItem(
              value: 'favorite',
              child: Text('Toggle Favorite'),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Text('Export'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () => widget.onDocumentSelected(document),
      ),
    );
  }

  Widget _buildDocumentIcon(String fileType) {
    IconData icon;
    Color color;

    switch (fileType) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'docx':
      case 'doc':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'text':
      case 'txt':
        icon = Icons.text_snippet;
        color = Colors.green;
        break;
      case 'markdown':
      case 'md':
        icon = Icons.code;
        color = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  String _getStatusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.uploaded:
        return 'Uploaded';
      case DocumentStatus.processing:
        return 'Processing...';
      case DocumentStatus.processed:
        return 'Ready';
      case DocumentStatus.generatingSummary:
        return 'Summarizing...';
      case DocumentStatus.generatingQuiz:
        return 'Generating Quiz...';
      case DocumentStatus.generatingAudio:
        return 'Generating Audio...';
      case DocumentStatus.error:
        return 'Error';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    final k = 1024;
    final sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes.toDouble() / (k * k)).floor();
    return '${(bytes / (k * k)).toStringAsFixed(1)} ${sizes[i]}';
  }

  void _handleMenuAction(String action, DocumentItem document) {
    switch (action) {
      case 'open':
        widget.onDocumentSelected(document);
        break;
      case 'favorite':
        _toggleFavorite(document);
        break;
      case 'export':
        _exportDocument(document);
        break;
      case 'delete':
        _deleteDocument(document);
        break;
    }
  }

  Future<void> _toggleFavorite(DocumentItem document) async {
    final updatedDocument = document.copyWith(
      isFavorite: !document.isFavorite,
      updatedAt: DateTime.now(),
    );
    
    await widget.storageService.saveDocument(updatedDocument);
    
    setState(() {
      final index = _documents.indexWhere((doc) => doc.id == document.id);
      if (index != -1) {
        _documents[index] = updatedDocument;
        _filteredDocuments = _applyFilters();
      }
    });
  }

  void _exportDocument(DocumentItem document) {
    // TODO: Implement export functionality
    _showError('Export feature coming soon!');
  }

  Future<void> _deleteDocument(DocumentItem document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.deleteDocument(document.id);
      
      setState(() {
        _documents.removeWhere((doc) => doc.id == document.id);
        _filteredDocuments = _applyFilters();
      });
    }
  }
}
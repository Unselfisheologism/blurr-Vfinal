import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/document_service.dart';

/// Widget for displaying and managing documents
class DocumentListWidget extends StatefulWidget {
  final DocumentService documentService;
  final String currentDocumentId;
  final Function(EditorDocument) onDocumentSelected;
  final VoidCallback onClose;

  const DocumentListWidget({
    Key? key,
    required this.documentService,
    required this.currentDocumentId,
    required this.onDocumentSelected,
    required this.onClose,
  }) : super(key: key);

  @override
  State<DocumentListWidget> createState() => _DocumentListWidgetState();
}

class _DocumentListWidgetState extends State<DocumentListWidget> {
  List<EditorDocument> _documents = [];
  List<EditorDocument> _filteredDocuments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedTab = 'all'; // 'all', 'recent', 'templates'

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docs = await widget.documentService.getAllDocuments();
      setState(() {
        _documents = docs;
        _filteredDocuments = docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading documents: $e')),
        );
      }
    }
  }

  void _filterDocuments(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDocuments = _documents;
      } else {
        _filteredDocuments = _documents.where((doc) {
          final titleMatch = doc.title.toLowerCase().contains(query.toLowerCase());
          final contentMatch = doc.getPlainText().toLowerCase().contains(query.toLowerCase());
          return titleMatch || contentMatch;
        }).toList();
      }
    });
  }

  Future<void> _deleteDocument(EditorDocument document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.documentService.deleteDocument(document.id);
        await _loadDocuments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting document: $e')),
          );
        }
      }
    }
  }

  Future<void> _duplicateDocument(EditorDocument document) async {
    try {
      await widget.documentService.duplicateDocument(document);
      await _loadDocuments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document duplicated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurradius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_open, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: _filterDocuments,
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              _buildTab('all', 'All', Icons.description),
              _buildTab('recent', 'Recent', Icons.history),
              _buildTab('templates', 'Templates', Icons.library_books),
            ],
          ),
        ),

        // Document list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDocuments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No documents yet'
                                : 'No documents found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Create your first document'
                                : 'Try a different search',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredDocuments.length,
                      itemBuilder: (context, index) {
                        final doc = _filteredDocuments[index];
                        final isCurrent = doc.id == widget.currentDocumentId;

                        return Container(
                          decoration: BoxDecoration(
                            color: isCurrent ? Colors.blue.shade50 : null,
                            border: Border(
                              left: BorderSide(
                                width: 4,
                                color: isCurrent ? Colors.blue : Colors.transparent,
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              doc.isTemplate ? Icons.library_books : Icons.description,
                              color: isCurrent ? Colors.blue : Colors.grey[600],
                            ),
                            title: Text(
                              doc.title,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(doc.updatedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${doc.getWordCount()} words',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'duplicate':
                                    _duplicateDocument(doc);
                                    break;
                                  case 'delete':
                                    if (!isCurrent) {
                                      _deleteDocument(doc);
                                    }
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.content_copy, size: 18),
                                      SizedBox(width: 8),
                                      Text('Duplicate'),
                                    ],
                                  ),
                                ),
                                if (!isCurrent)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            onTap: isCurrent
                                ? null
                                : () => widget.onDocumentSelected(doc),
                          ),
                        );
                      },
                    ),
        ),

        // Stats footer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_filteredDocuments.length} ${_filteredDocuments.length == 1 ? 'document' : 'documents'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String value, String label, IconData icon) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = value;
          });
          // TODO: Filter by tab
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

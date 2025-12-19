import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/document_item.dart';

/// Study content widget for displaying document content and study materials
/// 
/// Shows document content along with AI-generated summaries, key points,
/// and study guides in an organized, mobile-friendly layout.
class StudyContentWidget extends StatefulWidget {
  final DocumentItem document;
  final Function(String) onAIOperation;
  final bool isProcessing;

  const StudyContentWidget({
    Key? key,
    required this.document,
    required this.onAIOperation,
    required this.isProcessing,
  }) : super(key: key);

  @override
  State<StudyContentWidget> createState() => _StudyContentWidgetState();
}

class _StudyContentWidgetState extends State<StudyContentWidget>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _getTabCount(), vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    int count = 1; // Content tab always present
    if (widget.document.summary != null) count++;
    if (widget.document.keyPoints?.isNotEmpty == true) count++;
    if (widget.document.studyGuides?.isNotEmpty == true) count++;
    if (widget.document.notes?.isNotEmpty == true) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Document header
        _buildDocumentHeader(),
        
        // Tabs for different content types
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            isScrollable: true,
            tabs: _buildTabs(),
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.document.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, 
                  color: Colors.grey),
                onPressed: () {
                  // TODO: Toggle favorite
                },
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Document metadata
          Row(
            children: [
              _buildMetaChip(
                icon: Icons.insert_drive_file,
                text: widget.document.fileType.toUpperCase(),
              ),
              const SizedBox(width: 8),
              _buildMetaChip(
                icon: Icons.storage,
                text: _formatFileSize(widget.document.fileSize),
              ),
              const SizedBox(width: 8),
              _buildMetaChip(
                icon: Icons.schedule,
                text: _formatDate(widget.document.updatedAt),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          if (widget.document.progress > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: widget.document.progress,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Text(
                  'Study Progress: ${(widget.document.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabs() {
    final tabs = <Widget>[];
    
    // Content tab
    tabs.add(const Tab(
      icon: Icon(Icons.description),
      text: 'Content',
    ));
    
    // Summary tab
    if (widget.document.summary != null) {
      tabs.add(const Tab(
        icon: Icon(Icons.summarize),
        text: 'Summary',
      ));
    }
    
    // Key Points tab
    if (widget.document.keyPoints?.isNotEmpty == true) {
      tabs.add(const Tab(
        icon: Icon(Icons.lightbulb),
        text: 'Key Points',
      ));
    }
    
    // Study Guides tab
    if (widget.document.studyGuides?.isNotEmpty == true) {
      tabs.add(const Tab(
        icon: Icon(Icons.menu_book),
        text: 'Study Guides',
      ));
    }
    
    // Notes tab
    if (widget.document.notes?.isNotEmpty == true) {
      tabs.add(const Tab(
        icon: Icon(Icons.note),
        text: 'Notes',
      ));
    }
    
    return tabs;
  }

  List<Widget> _buildTabViews() {
    final views = <Widget>[];
    
    // Content view
    views.add(_buildContentView());
    
    // Summary view
    if (widget.document.summary != null) {
      views.add(_buildSummaryView());
    }
    
    // Key Points view
    if (widget.document.keyPoints?.isNotEmpty == true) {
      views.add(_buildKeyPointsView());
    }
    
    // Study Guides view
    if (widget.document.studyGuides?.isNotEmpty == true) {
      views.add(_buildStudyGuidesView());
    }
    
    // Notes view
    if (widget.document.notes?.isNotEmpty == true) {
      views.add(_buildNotesView());
    }
    
    return views;
  }

  Widget _buildContentView() {
    return Column(
      children: [
        // Content actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Document Content',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _copyContent,
                tooltip: 'Copy Content',
              ),
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: _selectAllContent,
                tooltip: 'Select All',
              ),
            ],
          ),
        ),
        
        // Content display
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                widget.document.content.isNotEmpty 
                    ? widget.document.content 
                    : 'No content available. The document may still be processing or content extraction failed.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'AI Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              widget.document.summary!,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.document.keyPoints!.length,
      itemBuilder: (context, index) {
        final point = widget.document.keyPoints![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(point),
          ),
        );
      },
    );
  }

  Widget _buildStudyGuidesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.document.studyGuides!.length,
      itemBuilder: (context, index) {
        final guide = widget.document.studyGuides![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              guide.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_getGuideTypeLabel(guide.type)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guide.content),
                    if (guide.keyTerms.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Key Terms:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: guide.keyTerms.map((term) {
                          return Chip(
                            label: Text(term),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.document.notes!.length,
      itemBuilder: (context, index) {
        final note = widget.document.notes![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(note.content),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Page: ${note.page}'),
                Text('Created: ${_formatDate(note.createdAt)}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteNote(note.id),
            ),
          ),
        );
      },
    );
  }

  void _copyContent() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.document.content));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content copied to clipboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to copy: $e')),
      );
    }
  }

  void _selectAllContent() {
    // This would need to be implemented with a text selection controller
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select all functionality coming soon')),
    );
  }

  void _deleteNote(String noteId) {
    // TODO: Implement note deletion
  }

  String _getGuideTypeLabel(String type) {
    switch (type) {
      case 'chapter':
        return 'Chapter';
      case 'topic':
        return 'Topic';
      case 'concept':
        return 'Concept';
      default:
        return 'Study Guide';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    final k = 1024;
    final sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes.toDouble() / (k * k)).floor();
    return '${(bytes / (k * k)).toStringAsFixed(1)} ${sizes[i]}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
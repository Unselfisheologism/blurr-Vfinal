/// Node palette widget
/// Shows available nodes that can be dragged onto canvas
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/node_definitions.dart';
import '../state/workflow_state.dart';
import '../state/app_state.dart';

class NodePalette extends StatefulWidget {
  const NodePalette({super.key});

  @override
  State<NodePalette> createState() => _NodePaletteState();
}

class _NodePaletteState extends State<NodePalette> {
  String _searchQuery = '';
  NodeCategory? _selectedCategory;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildNodeList()),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.widgets, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Node Palette',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search nodes...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All', null),
          ...NodeCategory.values.map((c) => _buildCategoryChip(_categoryName(c), c)),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(String label, NodeCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (s) => setState(() => _selectedCategory = s ? category : null),
        avatar: category != null ? Icon(_categoryIcon(category), size: 16) : null,
      ),
    );
  }
  
  Widget _buildNodeList() {
    var nodes = NodeDefinitions.all;
    
    if (_selectedCategory != null) {
      nodes = nodes.where((n) => n.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      nodes = nodes.where((n) =>
        n.displayName.toLowerCase().contains(_searchQuery) ||
        n.description.toLowerCase().contains(_searchQuery) ||
        n.tags.any((t) => t.toLowerCase().contains(_searchQuery))
      ).toList();
    }
    
    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('No nodes found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: nodes.length,
      itemBuilder: (context, index) => _buildNodeCard(nodes[index]),
    );
  }
  
  Widget _buildNodeCard(NodeDefinition node) {
    return Consumer2<WorkflowState, AppState>(
      builder: (context, workflowState, appState, _) {
        final isLocked = node.isPro && !appState.hasProSubscription;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: isLocked ? null : () => _onNodeTap(node),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: node.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(node.icon, color: node.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    node.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                if (node.isPro)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              node.description,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (node.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: node.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _onNodeTap(NodeDefinition node) {
    context.read<WorkflowState>().addNode(type: node.id, name: node.displayName, data: {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${node.displayName}'), duration: const Duration(seconds: 1)),
    );
  }
  
  String _categoryName(NodeCategory c) {
    const names = {
      NodeCategory.triggers: 'Triggers',
      NodeCategory.actions: 'Actions',
      NodeCategory.logic: 'Logic',
      NodeCategory.data: 'Data',
      NodeCategory.integration: 'Integration',
      NodeCategory.system: 'System',
      NodeCategory.ai: 'AI',
      NodeCategory.errorHandling: 'Error',
    };
    return names[c]!;
  }
  
  IconData _categoryIcon(NodeCategory c) {
    const icons = {
      NodeCategory.triggers: Icons.play_circle,
      NodeCategory.actions: Icons.flash_on,
      NodeCategory.logic: Icons.device_hub,
      NodeCategory.data: Icons.storage,
      NodeCategory.integration: Icons.extension,
      NodeCategory.system: Icons.phone_android,
      NodeCategory.ai: Icons.psychology,
      NodeCategory.errorHandling: Icons.error_outline,
    };
    return icons[c]!;
  }
}

/// Layer sidebar with reorderable list (Jaaz-inspired)
import 'package:flutter/material.dart';
import '../models/media_layer_node.dart';

class LayerSidebar extends StatelessWidget {
  final List<MediaLayerNode> layers;
  final Set<String> selectedLayerIds;
  final Function(String layerId) onLayerTap;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String layerId) onDelete;
  final Function(String layerId) onDuplicate;
  final Function(String layerId) onToggleVisibility;
  final Function(String layerId) onToggleLock;

  const LayerSidebar({
    super.key,
    required this.layers,
    required this.selectedLayerIds,
    required this.onLayerTap,
    required this.onReorder,
    required this.onDelete,
    required this.onDuplicate,
    required this.onToggleVisibility,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            twentadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Layers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${layers.length}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Layer list
          Expanded(
            child: layers.isEmpty
                ? _buildEmptyState()
                : ReorderableListView.builder(
                    itemCount: layers.length,
                    onReorder: onReorder,
                    itemBuilder: (context, index) {
                      final layer = layers[index];
                      final isSelected = selectedLayerIds.contains(layer.id);

                      return _LayerItem(
                        key: ValueKey(layer.id),
                        layer: layer,
                        isSelected: isSelected,
                        onTap: () => onLayerTap(layer.id),
                        onDelete: () => onDelete(layer.id),
                        onDuplicate: () => onDuplicate(layer.id),
                        onToggleVisibility: () => onToggleVisibility(layer.id),
                        onToggleLock: () => onToggleLock(layer.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No layers yet',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add layers using AI prompts',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerItem extends StatelessWidget {
  final MediaLayerNode layer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleVisibility;
  final VoidCallback onToggleLock;

  const _LayerItem({
    super.key,
    required this.layer,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.onToggleVisibility,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: _buildLayerIcon(),
        title: Text(
          layer.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          layer.type.name.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visibility toggle
            IconButton(
              icon: Icon(
                layer.visible ? Icons.visibility : Icons.visibility_off,
                size: 18,
              ),
              onPressed: onToggleVisibility,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            // Lock toggle
            IconButton(
              icon: Icon(
                layer.locked ? Icons.lock : Icons.lock_open,
                size: 18,
              ),
              onPressed: onToggleLock,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            // More options
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                switch (value) {
                  case 'duplicate':
                    onDuplicate();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 18),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
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
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLayerIcon() {
    IconData icon;
    Color color;

    switch (layer.type) {
      case MediaLayerType.image:
        icon = Icons.image;
        color = Colors.blue;
        break;
      case MediaLayerType.video:
        icon = Icons.videocam;
        color = Colors.purple;
        break;
      case MediaLayerType.audio:
        icon = Icons.audiotrack;
        color = Colors.orange;
        break;
      case MediaLayerType.text:
        icon = Icons.text_fields;
        color = Colors.green;
        break;
      case MediaLayerType.shape:
        icon = Icons.category;
        color = Colors.teal;
        break;
      case MediaLayerType.group:
        icon = Icons.folder;
        color = Colors.amber;
        break;
      case MediaLayerType.model3d:
        icon = Icons.view_in_ar;
        color = Colors.indigo;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

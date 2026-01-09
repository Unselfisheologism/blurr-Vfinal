/// Workflow canvas using vyuh_node_flow
/// Replaces broken fl_nodes implementation with production-ready vyuh_node_flow
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';
import '../state/workflow_state.dart';
import '../state/node_flow_controller.dart';
import '../state/provider_mobx_adapter.dart';
import '../models/node_definitions.dart';
import '../models/workflow_node_data.dart';

/// Main workflow canvas using vyuh_node_flow
/// Provides both manual user editing and agent-controlled operations
class FlWorkflowCanvas extends StatefulWidget {
  const FlWorkflowCanvas({Key? key}) : super(key: key);
  
  @override
  State<FlWorkflowCanvas> createState() => _FlWorkflowCanvasState();
}

class _FlWorkflowCanvasState extends State<FlWorkflowCanvas> {
  late WorkflowNodeFlowController _nodeFlowController;
  late ProviderMobXAdapter _adapter;
  late WorkflowState _workflowState;
  
  // UI state
  bool _showMinimap = true;
  bool _showGrid = true;
  bool _isDarkTheme = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _nodeFlowController = WorkflowNodeFlowController();
    _workflowState = context.read<WorkflowState>();
    _adapter = ProviderMobXAdapter(_workflowState, _nodeFlowController);
    
    // Set initial theme
    _nodeFlowController.setTheme(_isDarkTheme ? NodeFlowTheme.dark : NodeFlowTheme.light);
    
    // Enable features
    _nodeFlowController.setMinimapEnabled(_showMinimap);
  }
  
  @override
  void dispose() {
    _nodeFlowController.dispose();
    _adapter.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        return Scaffold(
          backgroundColor: _isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white,
          body: Column(
            children: [
              // Top toolbar
              _buildToolbar(),
              
              // Main editor area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: _buildNodeFlowEditor(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Build top toolbar
  Widget _buildToolbar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isDarkTheme ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(
            color: _isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Node palette toggle
          IconButton(
            icon: const Icon(Icons.extension_outlined),
            tooltip: 'Node Palette',
            onPressed: _showNodePalette,
          ),
          
          const SizedBox(width: 8),
          
          // Execute workflow
          IconButton(
            icon: Icon(
              _workflowState.isExecuting ? Icons.stop : Icons.play_arrow,
              color: _workflowState.isExecuting ? Colors.red : Colors.green,
            ),
            tooltip: _workflowState.isExecuting ? 'Stop Workflow' : 'Execute Workflow',
            onPressed: _workflowState.isExecuting 
                ? _workflowState.stopExecution 
                : _executeWorkflow,
          ),
          
          const SizedBox(width: 8),
          
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Zoom to Fit',
            onPressed: _nodeFlowController.zoomToFit,
          ),
          
          const SizedBox(width: 16),
          
          // Divider
          Container(
            width: 1,
            height: 24,
            color: _isDarkTheme ? Colors.grey[700] : Colors.grey[400],
          ),
          
          const SizedBox(width: 16),
          
          // View options
          IconButton(
            icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
            tooltip: _showGrid ? 'Hide Grid' : 'Show Grid',
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
              // Note: Grid control would need to be passed to NodeFlowEditor
            },
          ),
          
          IconButton(
            icon: Icon(_showMinimap ? Icons.map : Icons.map_outlined),
            tooltip: _showMinimap ? 'Hide Minimap' : 'Show Minimap',
            onPressed: () {
              setState(() {
                _showMinimap = !_showMinimap;
              });
              _nodeFlowController.setMinimapEnabled(_showMinimap);
            },
          ),
          
          const SizedBox(width: 16),
          
          // Theme toggle
          IconButton(
            icon: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            tooltip: _isDarkTheme ? 'Light Theme' : 'Dark Theme',
            onPressed: _toggleTheme,
          ),
          
          const Spacer(),
          
          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _workflowState.canUndo ? _workflowState.undo : null,
          ),
          
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: _workflowState.canRedo ? _workflowState.redo : null,
          ),
          
          const SizedBox(width: 8),
          
          // Save
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Workflow',
            onPressed: _saveWorkflow,
          ),
        ],
      ),
    );
  }
  
  /// Build the main NodeFlowEditor
  Widget _buildNodeFlowEditor() {
    return NodeFlowEditor<WorkflowNodeData>(
      controller: _nodeFlowController.controller,
      theme: _isDarkTheme ? NodeFlowTheme.dark : NodeFlowTheme.light,
      nodeBuilder: (context, node) => _buildNodeWidget(node),
    );
  }
  
  /// Build individual node widget
  Widget _buildNodeWidget(BuildContext context, Node<WorkflowNodeData> node) {
    final definition = NodeDefinitions.getByNodeType(node.type);
    final color = definition?.color ?? Colors.grey;
    
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDarkTheme ? const Color(0xFF3D3D3D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node header
          Row(
            children: [
              Icon(
                definition?.icon ?? Icons.help_outline,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.data.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDarkTheme ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Node data preview
          if (node.data.data.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isDarkTheme ? const Color(0xFF4D4D4D) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formatNodeData(node.data.data),
                style: TextStyle(
                  fontSize: 11,
                  color: _isDarkTheme ? Colors.grey[300] : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
  
  /// Format node data for display
  String _formatNodeData(Map<String, dynamic> data) {
    if (data.isEmpty) return 'No data';
    
    final entries = data.entries.take(2).map((e) => '${e.key}: ${e.value}');
    final display = entries.join(', ');
    
    if (data.length > 2) {
      return '$display...';
    }
    
    return display;
  }
  
  /// Show node palette
  void _showNodePalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _isDarkTheme ? const Color(0xFF2D2D2D) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildNodePalette(),
    );
  }
  
  /// Build node palette
  Widget _buildNodePalette() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add Nodes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isDarkTheme ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Category tabs
          _buildCategoryTabs(),
          
          const SizedBox(height: 20),
          
          // Node grid
          Expanded(
            child: _buildNodeGrid(),
          ),
        ],
      ),
    );
  }
  
  /// Build category tabs
  Widget _buildCategoryTabs() {
    final categories = NodeCategory.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getCategoryDisplayName(category)),
              selected: false,
              onSelected: (selected) {
                // Filter by category
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// Build node grid
  Widget _buildNodeGrid() {
    final nodes = NodeDefinitions.all;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return _buildNodePaletteItem(node);
      },
    );
  }
  
  /// Build individual node palette item
  Widget _buildNodePaletteItem(NodeDefinition node) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _addNodeToCanvas(node),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                node.icon,
                size: 32,
                color: node.color,
              ),
              const SizedBox(height: 8),
              Text(
                node.displayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                node.category.name,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Add node to canvas
  void _addNodeToCanvas(NodeDefinition definition) {
    Navigator.of(context).pop(); // Close palette
    
    // Generate unique ID
    final nodeId = 'node_${DateTime.now().millisecondsSinceEpoch}';
    
    // Add node using adapter
    _adapter.addNodeFromAgent(
      type: definition.id,
      name: definition.displayName,
      data: {},
      position: const Offset(200, 200), // Default position
    );
  }
  
  /// Execute workflow
  Future<void> _executeWorkflow() async {
    try {
      await _workflowState.executeWorkflowFromAgent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workflow execution started')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Execution failed: $e')),
        );
      }
    }
  }
  
  /// Save workflow
  Future<void> _saveWorkflow() async {
    try {
      await _workflowState.saveWorkflow();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workflow saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }
  
  /// Toggle theme
  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    _nodeFlowController.setTheme(_isDarkTheme ? NodeFlowTheme.dark : NodeFlowTheme.light);
  }
  
  /// Get category display name
  String _getCategoryDisplayName(NodeCategory category) {
    switch (category) {
      case NodeCategory.triggers:
        return 'Triggers';
      case NodeCategory.actions:
        return 'Actions';
      case NodeCategory.logic:
        return 'Logic';
      case NodeCategory.data:
        return 'Data';
      case NodeCategory.integration:
        return 'Integration';
      case NodeCategory.system:
        return 'System';
      case NodeCategory.ai:
        return 'AI';
      case NodeCategory.errorHandling:
        return 'Error Handling';
    }
  }
}
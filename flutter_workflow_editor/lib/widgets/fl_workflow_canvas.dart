/// FL Nodes workflow canvas with vertical layout
/// Mobile-optimized canvas integrating fl_nodes engine
library;

import 'package:flutter/material.dart';
import 'package:fl_nodes_workspace/fl_nodes.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../core/vertical_layout_adapter.dart';
import '../models/node_definitions.dart';

/// Main workflow canvas using FL Nodes - CORRECTED API
class FlWorkflowCanvas extends StatefulWidget {
  const FlWorkflowCanvas({Key? key}) : super(key: key);
  
  @override
  State<FlWorkflowCanvas> createState() => _FlWorkflowCanvasState();
}

class _FlWorkflowCanvasState extends State<FlWorkflowCanvas> {
  // CORRECT: Use FlNodeEditorController instead of NodesCanvas
  late final FlNodeEditorController _controller;
  late VerticalLayoutAdapter _layoutAdapter;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize layout adapter
    _layoutAdapter = VerticalLayoutAdapter();
    
    // CORRECT: Initialize FlNodeEditorController
    _controller = FlNodeEditorController(
      // Optional: Add project saver/loader if needed
      projectSaver: (jsonData) async {
        // Save workflow to platform bridge
        final workflowState = context.read<WorkflowState>();
        await workflowState.saveWorkflow();
        return true;
      },
      projectLoader: (isSaved) async {
        // Load workflow from platform bridge
        return null; // Return JSON data or null
      },
      projectCreator: (isSaved) async {
        // Create new workflow
        return true;
      },
    );
    
    // Register all node prototypes
    _registerNodePrototypes();
    
    // Setup listeners
    _setupListeners();
  }
  
  /// Register all node prototypes with the controller
  void _registerNodePrototypes() {
    final definitions = NodeDefinitions.all;
    
    for (final def in definitions) {
      // CORRECT: Use controller.registerNodePrototype()
      _controller.registerNodePrototype(
        _createNodePrototype(def),
      );
    }
  }
  
  /// Create a node prototype from definition
  NodePrototype _createNodePrototype(NodeDefinition definition) {
    return NodePrototype(
      idName: definition.id,
      displayName: definition.displayName,
      description: definition.description,
      
      // CORRECT: Use single 'ports' array, not separate lists
      ports: _createPorts(definition),
      
      // Optional: Custom styling
      styleBuilder: (state) => FlNodeStyle(
        decoration: BoxDecoration(
          color: definition.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: definition.color,
            width: 2,
          ),
        ),
        headerStyleBuilder: (state) => FlNodeHeaderStyle(
          decoration: BoxDecoration(
            color: definition.color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
      
      // Execution logic - handled by execution engine
      onExecute: (ports, fields, state, flowTo, passData) async {
        // This will be called by fl_nodes runner
        // For now, delegate to our execution engine
        final workflowState = context.read<WorkflowState>();
        // Execution handled externally
      },
    );
  }
  
  /// Create ports array for node (CORRECTED)
  List<dynamic> _createPorts(NodeDefinition definition) {
    final ports = <dynamic>[];
    
    // Control input ports (for non-trigger nodes)
    if (definition.category != NodeCategory.triggers) {
      ports.add(ControlInputPortPrototype(
        idName: 'exec',
        displayName: 'Exec',
      ));
    }
    
    // Control output ports based on node type
    switch (definition.id) {
      case 'if_else':
        ports.addAll([
          ControlOutputPortPrototype(idName: 'true', displayName: 'True'),
          ControlOutputPortPrototype(idName: 'false', displayName: 'False'),
        ]);
        break;
      
      case 'switch':
        ports.addAll([
          ControlOutputPortPrototype(idName: 'case1', displayName: 'Case 1'),
          ControlOutputPortPrototype(idName: 'case2', displayName: 'Case 2'),
          ControlOutputPortPrototype(idName: 'case3', displayName: 'Case 3'),
          ControlOutputPortPrototype(idName: 'default', displayName: 'Default'),
        ]);
        break;
      
      case 'loop':
        ports.addAll([
          ControlOutputPortPrototype(idName: 'loopBody', displayName: 'Loop Body'),
          ControlOutputPortPrototype(idName: 'completed', displayName: 'Completed'),
        ]);
        break;
      
      case 'error_handler':
        ports.addAll([
          ControlOutputPortPrototype(idName: 'success', displayName: 'Success'),
          ControlOutputPortPrototype(idName: 'error', displayName: 'Error'),
        ]);
        break;
      
      default:
        ports.add(ControlOutputPortPrototype(
          idName: 'out',
          displayName: 'Out',
        ));
    }
    
    // Data input ports (simplified - add specific ones per node type)
    if (definition.id == 'unified_shell') {
      ports.addAll([
        DataInputPortPrototype(
          idName: 'code',
          displayName: 'Code',
          dataType: String,
        ),
        DataInputPortPrototype(
          idName: 'inputs',
          displayName: 'Inputs',
          dataType: Map,
        ),
      ]);
    }
    
    if (definition.id == 'http_request') {
      ports.addAll([
        DataInputPortPrototype(
          idName: 'url',
          displayName: 'URL',
          dataType: String,
        ),
        DataInputPortPrototype(
          idName: 'method',
          displayName: 'Method',
          dataType: String,
        ),
      ]);
    }
    
    if (definition.id == 'loop') {
      ports.add(DataInputPortPrototype(
        idName: 'list',
        displayName: 'List',
        dataType: dynamic,
      ));
    }
    
    // Data output ports
    ports.add(DataOutputPortPrototype(
      idName: 'result',
      displayName: 'Result',
      dataType: dynamic,
    ));
    
    if (definition.id == 'loop') {
      ports.addAll([
        DataOutputPortPrototype(
          idName: 'listElem',
          displayName: 'Element',
          dataType: dynamic,
        ),
        DataOutputPortPrototype(
          idName: 'listIdx',
          displayName: 'Index',
          dataType: int,
        ),
      ]);
    }
    
    return ports;
  }
  
  /// Setup listeners for controller events
  void _setupListeners() {
    // Listen to project changes
    _controller.addListener(() {
      // Sync with workflow state if needed
      setState(() {});
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // CORRECT: Use FlNodeEditorWidget
              Expanded(
                child: FlNodeEditorWidget(
                  controller: _controller,
                  expandToParent: true,
                  
                  // Style configuration
                  style: FlNodeEditorStyle(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                    ),
                    gridStyle: FlGridStyle(
                      gridSpacingX: 20.0,
                      gridSpacingY: 20.0,
                      lineColor: Colors.grey.withOpacity(0.1),
                      showGrid: true,
                    ),
                  ),
                  
                  // Overlay widgets (toolbar, minimap, etc.)
                  overlay: () {
                    return [
                      // Execute button overlay
                      FlOverlayData(
                        top: 16,
                        right: 16,
                        child: _buildControlButtons(),
                      ),
                      
                      // Minimap overlay
                      FlOverlayData(
                        bottom: 16,
                        left: 16,
                        child: _buildMinimap(),
                      ),
                      
                      // Zoom indicator
                      FlOverlayData(
                        top: 16,
                        left: 16,
                        child: _buildZoomIndicator(),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Build control buttons overlay
  Widget _buildControlButtons() {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Execute graph button
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.green),
            tooltip: 'Execute Workflow',
            onPressed: () async {
              // Execute using fl_nodes runner
              await _controller.runner.executeGraph();
              
              // Also trigger our custom execution engine
              final workflowState = context.read<WorkflowState>();
              await workflowState.executeWorkflow();
            },
          ),
          
          // Auto-arrange button
          IconButton(
            icon: const Icon(Icons.vertical_distribute),
            tooltip: 'Auto Arrange',
            onPressed: _autoArrangeVertically,
          ),
          
          // Fit to screen
          IconButton(
            icon: const Icon(Icons.fit_screen),
            tooltip: 'Fit to Screen',
            onPressed: () {
              // Zoom to fit all nodes
              // Note: fl_nodes may not have this directly
            },
          ),
        ],
      ),
    );
  }
  
  /// Build minimap overlay
  Widget _buildMinimap() {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: const Center(
        child: Text(
          'Minimap',
          style: TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ),
    );
  }
  
  /// Build zoom indicator
  Widget _buildZoomIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '100%',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Auto-arrange nodes vertically
  void _autoArrangeVertically() {
    // Get all nodes from controller
    final nodes = _controller.project.nodes.values.toList();
    
    if (nodes.isEmpty) return;
    
    // Find root nodes (no incoming connections)
    final hasIncoming = <String>{};
    for (final link in _controller.project.links.values) {
      hasIncoming.add(link.targetNodeId);
    }
    
    final roots = nodes.where((n) => !hasIncoming.contains(n.id)).toList();
    
    // Position nodes in vertical levels
    final levels = <int, List<dynamic>>{};
    final visited = <String>{};
    
    void assignLevel(dynamic node, int level) {
      if (visited.contains(node.id)) return;
      visited.add(node.id);
      
      levels.putIfAbsent(level, () => []).add(node);
      
      // Find children
      final childLinks = _controller.project.links.values
          .where((link) => link.sourceNodeId == node.id);
      
      for (final link in childLinks) {
        final childNode = _controller.project.nodes[link.targetNodeId];
        if (childNode != null) {
          assignLevel(childNode, level + 1);
        }
      }
    }
    
    // Assign levels
    for (final root in roots) {
      assignLevel(root, 0);
    }
    
    // Position nodes
    for (final entry in levels.entries) {
      final level = entry.key;
      final nodesAtLevel = entry.value;
      
      for (var i = 0; i < nodesAtLevel.length; i++) {
        final node = nodesAtLevel[i];
        node.position = Offset(
          i * 300.0, // Horizontal spacing
          level * 150.0 + 100.0, // Vertical spacing with top margin
        );
      }
    }
    
    setState(() {});
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

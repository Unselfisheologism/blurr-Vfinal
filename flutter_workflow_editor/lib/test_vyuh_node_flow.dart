// Vyuh Node Flow Spike Test Implementation
// This file contains a comprehensive test of vyuh_node_flow for AI workflow editor
library;

import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'state/workflow_state.dart';
import 'models/workflow.dart';

/// Test widget to evaluate vyuh_node_flow capabilities
class VyuhNodeFlowTestWidget extends StatefulWidget {
  const VyuhNodeFlowTestWidget({super.key});

  @override
  State<VyuhNodeFlowTestWidget> createState() => _VyuhNodeFlowTestWidgetState();
}

class _VyuhNodeFlowTestWidgetState extends State<VyuhNodeFlowTestWidget> {
  late final NodeFlowController<WorkflowNodeData> controller;
  final Uuid _uuid = const Uuid();
  WorkflowState? _workflowState;

  @override
  void initState() {
    super.initState();
    
    // Initialize the controller
    controller = NodeFlowController<WorkflowNodeData>(
      config: NodeFlowConfig(
        theme: NodeFlowTheme.light,
        gridStyle: GridStyle.dots,
        connectionStyle: ConnectionStyles.smoothstep,
      ),
    );
    
    // Add test nodes
    _addTestNodes();
    _addTestConnections();
  }

  /// Add various test nodes to evaluate node creation capabilities
  void _addTestNodes() {
    // 1. Manual Trigger Node
    controller.addNode(
      Node<WorkflowNodeData>(
        id: _uuid.v4(),
        type: 'trigger',
        position: const Offset(100, 100),
        data: WorkflowNodeData(
          name: 'Manual Trigger',
          description: 'Starts workflow manually',
          nodeType: 'manual_trigger',
        ),
        outputPorts: const [
          Port(id: 'out', name: 'Output'),
        ],
      ),
    );

    // 2. Action Node
    controller.addNode(
      Node<WorkflowNodeData>(
        id: _uuid.v4(),
        type: 'action',
        position: const Offset(100, 300),
        data: WorkflowNodeData(
          name: 'Send Message',
          description: 'Sends a message to user',
          nodeType: 'send_message',
        ),
        inputPorts: const [
          Port(id: 'in', name: 'Input'),
        ],
        outputPorts: const [
          Port(id: 'out', name: 'Output'),
        ],
      ),
    );

    // 3. Condition Node
    controller.addNode(
      Node<WorkflowNodeData>(
        id: _uuid.v4(),
        type: 'condition',
        position: const Offset(400, 200),
        data: WorkflowNodeData(
          name: 'If Condition',
          description: 'Conditional branching',
          nodeType: 'if_else',
        ),
        inputPorts: const [
          Port(id: 'in', name: 'Input'),
        ],
        outputPorts: const [
          Port(id: 'true', name: 'True'),
          Port(id: 'false', name: 'False'),
        ],
      ),
    );

    // 4. HTTP Request Node
    controller.addNode(
      Node<WorkflowNodeData>(
        id: _uuid.v4(),
        type: 'http',
        position: const Offset(400, 400),
        data: WorkflowNodeData(
          name: 'HTTP Request',
          description: 'Makes HTTP requests',
          nodeType: 'http_request',
        ),
        inputPorts: const [
          Port(id: 'in', name: 'Input'),
        ],
        outputPorts: const [
          Port(id: 'out', name: 'Output'),
        ],
      ),
    );

    // 5. Output Node
    controller.addNode(
      Node<WorkflowNodeData>(
        id: _uuid.v4(),
        type: 'output',
        position: const Offset(700, 300),
        data: WorkflowNodeData(
          name: 'Workflow Output',
          description: 'Final output of workflow',
          nodeType: 'output',
        ),
        inputPorts: const [
          Port(id: 'in', name: 'Input'),
        ],
      ),
    );
  }

  /// Add test connections to evaluate connection capabilities
  void _addTestConnections() {
    final nodes = controller.nodes;
    if (nodes.length >= 5) {
      // Connect trigger to action
      controller.createConnection(
        nodes[0].id,
        'out',
        nodes[1].id,
        'in',
      );

      // Connect action to condition
      controller.createConnection(
        nodes[1].id,
        'out',
        nodes[2].id,
        'in',
      );

      // Connect condition true to HTTP request
      controller.createConnection(
        nodes[2].id,
        'true',
        nodes[3].id,
        'in',
      );

      // Connect HTTP request to output
      controller.createConnection(
        nodes[3].id,
        'out',
        nodes[4].id,
        'in',
      );
    }
  }

  /// Test programmatic control (Agent Integration)
  void _testProgrammaticControl() {
    // Test adding a node programmatically
    final newNodeId = _uuid.v4();
    controller.addNode(
      Node<WorkflowNodeData>(
        id: newNodeId,
        type: 'test',
        position: const Offset(200, 500),
        data: WorkflowNodeData(
          name: 'Programmatic Node',
          description: 'Added via code',
          nodeType: 'test_node',
        ),
      ),
    );

    // Test removing a node programmatically
    if (controller.nodes.length > 1) {
      final nodeToRemove = controller.nodes[0];
      controller.removeNode(nodeToRemove.id);
    }

    // Test updating node data
    if (controller.nodes.isNotEmpty) {
      final nodeToUpdate = controller.nodes[0];
      final updatedData = nodeToUpdate.data.copyWith(
        name: 'Updated Node',
      );
      controller.updateNodeData(nodeToUpdate.id, updatedData);
    }
  }

  /// Test serialization
  Future<void> _testSerialization() async {
    try {
      // Export to JSON
      final jsonData = controller.toJson();
      debugPrint('Serialization test - JSON export successful');
      debugPrint('JSON data: ${jsonData.toString().substring(0, 200)}...');

      // Import from JSON
      final newController = NodeFlowController<WorkflowNodeData>();
      await newController.fromJson(jsonData);
      debugPrint('Serialization test - JSON import successful');
      
    } catch (e) {
      debugPrint('Serialization test failed: $e');
    }
  }

  /// Test state management integration
  void _testStateManagementIntegration() {
    // This would be called when workflow state changes
    if (_workflowState?.currentWorkflow != null) {
      _syncFromWorkflowState();
    }
  }

  /// Sync from workflow state to vyuh_node_flow controller
  void _syncFromWorkflowState() {
    if (_workflowState?.currentWorkflow == null) return;
    
    // Clear existing nodes
    for (final node in controller.nodes) {
      controller.removeNode(node.id);
    }
    
    // Add nodes from workflow state
    for (final workflowNode in _workflowState!.currentWorkflow!.nodes) {
      controller.addNode(
        Node<WorkflowNodeData>(
          id: workflowNode.id,
          type: workflowNode.type,
          position: Offset(workflowNode.x, workflowNode.y),
          data: WorkflowNodeData(
            name: workflowNode.name,
            description: workflowNode.data['description'] ?? '',
            nodeType: workflowNode.type,
          ),
          // Add ports based on node type
          inputPorts: _getInputPortsForNodeType(workflowNode.type),
          outputPorts: _getOutputPortsForNodeType(workflowNode.type),
        ),
      );
    }
    
    // Add connections from workflow state
    for (final connection in _workflowState!.currentWorkflow!.connections) {
      controller.createConnection(
        connection.sourceNodeId,
        connection.sourcePortId,
        connection.targetNodeId,
        connection.targetPortId,
      );
    }
  }

  /// Get input ports for a node type
  List<Port> _getInputPortsForNodeType(String nodeType) {
    switch (nodeType) {
      case 'manual_trigger':
        return [];
      case 'if_else':
        return [const Port(id: 'in', name: 'Input')];
      case 'http_request':
        return [const Port(id: 'in', name: 'Input')];
      default:
        return [const Port(id: 'in', name: 'Input')];
    }
  }

  /// Get output ports for a node type
  List<Port> _getOutputPortsForNodeType(String nodeType) {
    switch (nodeType) {
      case 'manual_trigger':
        return [const Port(id: 'out', name: 'Output')];
      case 'if_else':
        return [
          const Port(id: 'true', name: 'True'),
          const Port(id: 'false', name: 'False'),
        ];
      case 'http_request':
        return [const Port(id: 'out', name: 'Output')];
      case 'output':
        return [];
      default:
        return [const Port(id: 'out', name: 'Output')];
    }
  }

  /// Test performance with many nodes
  void _testPerformance() {
    // Add 20+ nodes for performance testing
    for (var i = 0; i < 20; i++) {
      controller.addNode(
        Node<WorkflowNodeData>(
          id: _uuid.v4(),
          type: 'test',
          position: Offset(100.0 + (i * 50), 600.0 + ((i % 5) * 100)),
          data: WorkflowNodeData(
            name: 'Test Node $i',
            description: 'Performance test node',
            nodeType: 'test',
          ),
        ),
      );
    }
    
    // Connect some nodes to test connection performance
    final nodes = controller.nodes;
    for (var i = 0; i < nodes.length - 1; i++) {
      if (i % 2 == 0 && i + 1 < nodes.length) {
        controller.createConnection(
          nodes[i].id,
          'out',
          nodes[i + 1].id,
          'in',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        // Ensure we're listening to workflow state changes
        if (_workflowState != workflowState) {
          _workflowState?.removeListener(_testStateManagementIntegration);
          _workflowState = workflowState;
          _workflowState!.addListener(_testStateManagementIntegration);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Vyuh Node Flow Spike Test'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Test Programmatic Control',
                onPressed: _testProgrammaticControl,
              ),
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Test Serialization',
                onPressed: _testSerialization,
              ),
              IconButton(
                icon: const Icon(Icons.speed),
                tooltip: 'Test Performance',
                onPressed: _testPerformance,
              ),
              IconButton(
                icon: const Icon(Icons.sync),
                tooltip: 'Sync from Workflow State',
                onPressed: _syncFromWorkflowState,
              ),
            ],
          ),
          body: Column(
            children: [
              // Test info panel
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue.withOpacity(0.1),
                child: const Text(
                  'Vyuh Node Flow Spike Test - Evaluating capabilities for AI Workflow Editor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              
              // Node flow editor
              Expanded(
                child: NodeFlowEditor<WorkflowNodeData>(
                  controller: controller,
                  nodeBuilder: (context, node) => _buildNodeWidget(node),
                  theme: NodeFlowTheme.light,
                ),
              ),
              
              // Stats panel
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Nodes: ${controller.nodes.length}'),
                    Text('Connections: ${controller.connections.length}'),
                    Text('Zoom: ${controller.viewport.zoomLevel.toStringAsFixed(2)}x'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build node widget with custom styling
  Widget _buildNodeWidget(Node<WorkflowNodeData> node) {
    // Determine color based on node type
    Color nodeColor;
    switch (node.type) {
      case 'trigger':
        nodeColor = Colors.green;
        break;
      case 'action':
        nodeColor = Colors.blue;
        break;
      case 'condition':
        nodeColor = Colors.orange;
        break;
      case 'http':
        nodeColor = Colors.purple;
        break;
      case 'output':
        nodeColor = Colors.red;
        break;
      default:
        nodeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: nodeColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: nodeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Text(
              node.data.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Node description
          Text(
            node.data.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          
          // Node type
          Text(
            node.data.nodeType,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Node ID (small)
          Text(
            'ID: ${node.id.substring(0, 8)}...',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for workflow nodes
class WorkflowNodeData {
  final String name;
  final String description;
  final String nodeType;

  const WorkflowNodeData({
    required this.name,
    required this.description,
    required this.nodeType,
  });

  WorkflowNodeData copyWith({
    String? name,
    String? description,
    String? nodeType,
  }) {
    return WorkflowNodeData(
      name: name ?? this.name,
      description: description ?? this.description,
      nodeType: nodeType ?? this.nodeType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'nodeType': nodeType,
    };
  }

  factory WorkflowNodeData.fromJson(Map<String, dynamic> json) {
    return WorkflowNodeData(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      nodeType: json['nodeType'] ?? '',
    );
  }
}
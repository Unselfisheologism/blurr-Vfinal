// Vyuh Node Flow Spike Test Implementation
// Kept as a lightweight compilation-safe playground for vyuh_node_flow APIs.
library;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

import 'models/workflow_node_data.dart';

class VyuhNodeFlowTestWidget extends StatefulWidget {
  const VyuhNodeFlowTestWidget({super.key});

  @override
  State<VyuhNodeFlowTestWidget> createState() => _VyuhNodeFlowTestWidgetState();
}

class _VyuhNodeFlowTestWidgetState extends State<VyuhNodeFlowTestWidget> {
  late final NodeFlowController<WorkflowNodeData, dynamic> _controller;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    _controller = NodeFlowController<WorkflowNodeData, dynamic>(
      config: NodeFlowConfig(showAttribution: false),
    );

    _addTestNodes();
    _addTestConnections();
  }

  void _addTestNodes() {
    _controller.addNode(
      Node<WorkflowNodeData>(
        id: _uuid.v4(),
        type: 'manual_trigger',
        position: const Offset(100, 100),
        data: const WorkflowNodeData(
          name: 'Manual Trigger',
          description: 'Starts workflow manually',
          nodeType: 'manual_trigger',
        ),
        outputPorts: [
          Port(
            id: 'out',
            name: 'Output',
            type: PortType.output,
            position: PortPosition.right,
          ),
        ],
      ),
    );

    _controller.addNode(
      Node<WorkflowNodeData>(
        id: _uuid.v4(),
        type: 'http_request',
        position: const Offset(350, 120),
        data: const WorkflowNodeData(
          name: 'HTTP Request',
          description: 'Makes an HTTP request',
          nodeType: 'http_request',
        ),
        inputPorts: [
          Port(
            id: 'in',
            name: 'Input',
            type: PortType.input,
            position: PortPosition.left,
          ),
        ],
        outputPorts: [
          Port(
            id: 'out',
            name: 'Output',
            type: PortType.output,
            position: PortPosition.right,
          ),
        ],
      ),
    );
  }

  void _addTestConnections() {
    final nodes = _controller.nodes;
    if (nodes.length < 2) return;

    _controller.createConnection(
      nodes[0].id,
      'out',
      nodes[1].id,
      'in',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vyuh Node Flow Test')),
      body: NodeFlowEditor<WorkflowNodeData, dynamic>(
        controller: _controller,
        theme: NodeFlowTheme.light,
        nodeBuilder: (context, node) {
          return Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.data.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  node.data.description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

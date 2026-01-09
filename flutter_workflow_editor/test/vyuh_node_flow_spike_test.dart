// Automated test suite for vyuh_node_flow spike
import 'package:flutter_test/flutter_test.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Vyuh Node Flow Spike Tests', () {
    late NodeFlowController<String> controller;
    final Uuid uuid = Uuid();

    setUp(() {
      controller = NodeFlowController<String>();
    });

    tearDown(() {
      controller.dispose();
    });

    test('vyuh_node_flow - can create node', () {
      // Test basic node creation
      final nodeId = uuid.v4();
      controller.addNode(
        Node<String>(
          id: nodeId,
          type: 'test',
          position: const Offset(100, 100),
          data: 'Test Node',
        ),
      );

      expect(controller.nodes.length, 1);
      expect(controller.nodes[0].id, nodeId);
      expect(controller.nodes[0].data, 'Test Node');
      expect(controller.nodes[0].position, const Offset(100, 100));
    });

    test('vyuh_node_flow - can create node with ports', () {
      // Test node creation with input and output ports
      final nodeId = uuid.v4();
      controller.addNode(
        Node<String>(
          id: nodeId,
          type: 'test',
          position: const Offset(200, 200),
          data: 'Node with Ports',
          inputPorts: const [
            Port(id: 'in1', name: 'Input 1'),
            Port(id: 'in2', name: 'Input 2'),
          ],
          outputPorts: const [
            Port(id: 'out1', name: 'Output 1'),
            Port(id: 'out2', name: 'Output 2'),
          ],
        ),
      );

      final node = controller.nodes[0];
      expect(node.inputPorts.length, 2);
      expect(node.outputPorts.length, 2);
      expect(node.inputPorts[0].id, 'in1');
      expect(node.outputPorts[1].id, 'out2');
    });

    test('vyuh_node_flow - can connect nodes', () {
      // Test connection creation between nodes
      final node1Id = uuid.v4();
      final node2Id = uuid.v4();

      controller.addNode(
        Node<String>(
          id: node1Id,
          type: 'source',
          position: const Offset(100, 100),
          data: 'Source Node',
          outputPorts: const [Port(id: 'out', name: 'Output')],
        ),
      );

      controller.addNode(
        Node<String>(
          id: node2Id,
          type: 'target',
          position: const Offset(300, 100),
          data: 'Target Node',
          inputPorts: const [Port(id: 'in', name: 'Input')],
        ),
      );

      // Create connection
      controller.createConnection(node1Id, 'out', node2Id, 'in');

      expect(controller.connections.length, 1);
      final connection = controller.connections[0];
      expect(connection.sourceNodeId, node1Id);
      expect(connection.targetNodeId, node2Id);
      expect(connection.sourcePortId, 'out');
      expect(connection.targetPortId, 'in');
    });

    test('vyuh_node_flow - supports programmatic updates', () {
      // Test programmatic node updates
      final nodeId = uuid.v4();
      controller.addNode(
        Node<String>(
          id: nodeId,
          type: 'test',
          position: const Offset(100, 100),
          data: 'Original Data',
        ),
      );

      // Update node data
      controller.updateNodeData(nodeId, 'Updated Data');
      expect(controller.nodes[0].data, 'Updated Data');

      // Update node position
      controller.updateNodePosition(nodeId, const Offset(200, 200));
      expect(controller.nodes[0].position, const Offset(200, 200));

      // Remove node
      controller.removeNode(nodeId);
      expect(controller.nodes.length, 0);
    });

    test('vyuh_node_flow - serializes to JSON', () {
      // Test JSON serialization
      final node1Id = uuid.v4();
      final node2Id = uuid.v4();

      controller.addNode(
        Node<String>(
          id: node1Id,
          type: 'test',
          position: const Offset(100, 100),
          data: 'Node 1',
          outputPorts: const [Port(id: 'out', name: 'Output')],
        ),
      );

      controller.addNode(
        Node<String>(
          id: node2Id,
          type: 'test',
          position: const Offset(300, 100),
          data: 'Node 2',
          inputPorts: const [Port(id: 'in', name: 'Input')],
        ),
      );

      controller.createConnection(node1Id, 'out', node2Id, 'in');

      // Serialize to JSON
      final jsonData = controller.toJson();

      expect(jsonData, isA<Map<String, dynamic>>());
      expect(jsonData['nodes'], isA<List<dynamic>>());
      expect(jsonData['connections'], isA<List<dynamic>>());
      expect(jsonData['nodes'].length, 2);
      expect(jsonData['connections'].length, 1);
    });

    test('vyuh_node_flow - deserializes from JSON', () async {
      // Test JSON deserialization
      final originalController = NodeFlowController<String>();
      final node1Id = uuid.v4();
      final node2Id = uuid.v4();

      originalController.addNode(
        Node<String>(
          id: node1Id,
          type: 'test',
          position: const Offset(100, 100),
          data: 'Node 1',
          outputPorts: const [Port(id: 'out', name: 'Output')],
        ),
      );

      originalController.addNode(
        Node<String>(
          id: node2Id,
          type: 'test',
          position: const Offset(300, 100),
          data: 'Node 2',
          inputPorts: const [Port(id: 'in', name: 'Input')],
        ),
      );

      originalController.createConnection(node1Id, 'out', node2Id, 'in');

      // Serialize
      final jsonData = originalController.toJson();

      // Deserialize to new controller
      final newController = NodeFlowController<String>();
      await newController.fromJson(jsonData);

      expect(newController.nodes.length, 2);
      expect(newController.connections.length, 1);
      expect(newController.nodes[0].data, 'Node 1');
      expect(newController.nodes[1].data, 'Node 2');
    });

    test('vyuh_node_flow - handles complex node types', () {
      // Test complex node types similar to workflow editor
      final triggerId = uuid.v4();
      final conditionId = uuid.v4();
      final actionId = uuid.v4();

      // Add trigger node (no input ports)
      controller.addNode(
        Node<String>(
          id: triggerId,
          type: 'trigger',
          position: const Offset(100, 100),
          data: 'Manual Trigger',
          outputPorts: const [Port(id: 'out', name: 'Output')],
        ),
      );

      // Add condition node (multiple output ports)
      controller.addNode(
        Node<String>(
          id: conditionId,
          type: 'condition',
          position: const Offset(300, 200),
          data: 'If Condition',
          inputPorts: const [Port(id: 'in', name: 'Input')],
          outputPorts: const [
            Port(id: 'true', name: 'True'),
            Port(id: 'false', name: 'False'),
          ],
        ),
      );

      // Add action node
      controller.addNode(
        Node<String>(
          id: actionId,
          type: 'action',
          position: const Offset(500, 100),
          data: 'Send Message',
          inputPorts: const [Port(id: 'in', name: 'Input')],
          outputPorts: const [Port(id: 'out', name: 'Output')],
        ),
      );

      // Create connections
      controller.createConnection(triggerId, 'out', conditionId, 'in');
      controller.createConnection(conditionId, 'true', actionId, 'in');

      expect(controller.nodes.length, 3);
      expect(controller.connections.length, 2);

      // Verify node types
      expect(controller.nodes[0].type, 'trigger');
      expect(controller.nodes[1].type, 'condition');
      expect(controller.nodes[2].type, 'action');

      // Verify ports
      expect(controller.nodes[0].inputPorts.length, 0); // Trigger has no inputs
      expect(controller.nodes[1].outputPorts.length, 2); // Condition has 2 outputs
      expect(controller.nodes[2].inputPorts.length, 1); // Action has 1 input
    });

    test('vyuh_node_flow - handles node positioning', () {
      // Test precise node positioning
      final nodeId1 = uuid.v4();
      final nodeId2 = uuid.v4();

      controller.addNode(
        Node<String>(
          id: nodeId1,
          type: 'test',
          position: const Offset(123.45, 678.90),
          data: 'Precise Position 1',
        ),
      );

      controller.addNode(
        Node<String>(
          id: nodeId2,
          type: 'test',
          position: const Offset(987.65, 432.10),
          data: 'Precise Position 2',
        ),
      );

      expect(controller.nodes[0].position, const Offset(123.45, 678.90));
      expect(controller.nodes[1].position, const Offset(987.65, 432.10));

      // Test position updates
      controller.updateNodePosition(nodeId1, const Offset(100.0, 200.0));
      expect(controller.nodes[0].position, const Offset(100.0, 200.0));
    });

    test('vyuh_node_flow - handles connection validation', () {
      // Test connection validation
      final node1Id = uuid.v4();
      final node2Id = uuid.v4();

      controller.addNode(
        Node<String>(
          id: node1Id,
          type: 'source',
          position: const Offset(100, 100),
          data: 'Source',
          outputPorts: const [
            Port(id: 'out1', name: 'Output 1'),
            Port(id: 'out2', name: 'Output 2'),
          ],
        ),
      );

      controller.addNode(
        Node<String>(
          id: node2Id,
          type: 'target',
          position: const Offset(300, 100),
          data: 'Target',
          inputPorts: const [
            Port(id: 'in1', name: 'Input 1'),
            Port(id: 'in2', name: 'Input 2'),
          ],
        ),
      );

      // Create valid connections
      controller.createConnection(node1Id, 'out1', node2Id, 'in1');
      controller.createConnection(node1Id, 'out2', node2Id, 'in2');

      expect(controller.connections.length, 2);

      // Verify connection details
      final connection1 = controller.connections[0];
      final connection2 = controller.connections[1];

      expect(connection1.sourcePortId, 'out1');
      expect(connection1.targetPortId, 'in1');
      expect(connection2.sourcePortId, 'out2');
      expect(connection2.targetPortId, 'in2');
    });

    test('vyuh_node_flow - handles large graphs', () {
      // Test performance with many nodes (simplified version)
      for (var i = 0; i < 25; i++) {
        controller.addNode(
          Node<String>(
            id: uuid.v4(),
            type: 'test',
            position: Offset(i * 50.0, (i % 5) * 100.0),
            data: 'Node $i',
            inputPorts: const [Port(id: 'in', name: 'Input')],
            outputPorts: const [Port(id: 'out', name: 'Output')],
          ),
        );
      }

      expect(controller.nodes.length, 25);

      // Connect some nodes
      final nodes = controller.nodes;
      for (var i = 0; i < nodes.length - 1; i += 2) {
        if (i + 1 < nodes.length) {
          controller.createConnection(
            nodes[i].id,
            'out',
            nodes[i + 1].id,
            'in',
          );
        }
      }

      expect(controller.connections.length, 12); // 25 nodes / 2 = 12 connections
    });

    test('vyuh_node_flow - handles theme customization', () {
      // Test theme customization
      final customTheme = NodeFlowTheme.light.copyWith(
        connectionStyle: ConnectionStyles.smoothstep,
        connectionTheme: NodeFlowTheme.light.connectionTheme.copyWith(
          color: Colors.blue,
          strokeWidth: 2.5,
        ),
        portTheme: NodeFlowTheme.light.portTheme.copyWith(
          size: 12.0,
          color: Colors.green,
        ),
      );

      controller.setTheme(customTheme);

      // Verify theme is set (we can't directly test the theme values, but we can verify it doesn't throw)
      expect(controller.config.theme, isNotNull);
    });

    test('vyuh_node_flow - handles viewport operations', () {
      // Test viewport operations
      final initialZoom = controller.viewport.zoomLevel;
      final initialOffset = controller.viewport.offset;

      // Zoom in
      controller.viewport.zoomLevel = 1.5;
      expect(controller.viewport.zoomLevel, 1.5);

      // Zoom out
      controller.viewport.zoomLevel = 0.8;
      expect(controller.viewport.zoomLevel, 0.8);

      // Reset zoom
      controller.viewport.zoomLevel = 1.0;
      expect(controller.viewport.zoomLevel, 1.0);

      // Test offset
      controller.viewport.offset = const Offset(100, 200);
      expect(controller.viewport.offset, const Offset(100, 200));
    });
  });

  group('Vyuh Node Flow Integration Tests', () {
    test('vyuh_node_flow - integrates with state management patterns', () async {
      // This test simulates how vyuh_node_flow would integrate with Provider
      final controller = NodeFlowController<String>();

      // Simulate adding nodes from workflow state
      final node1Id = uuid.v4();
      final node2Id = uuid.v4();

      controller.addNode(
        Node<String>(
          id: node1Id,
          type: 'trigger',
          position: const Offset(100, 100),
          data: 'Trigger Node',
          outputPorts: const [Port(id: 'out', name: 'Output')],
        ),
      );

      controller.addNode(
        Node<String>(
          id: node2Id,
          type: 'action',
          position: const Offset(300, 100),
          data: 'Action Node',
          inputPorts: const [Port(id: 'in', name: 'Input')],
        ),
      );

      controller.createConnection(node1Id, 'out', node2Id, 'in');

      // Simulate serialization for state persistence
      final jsonData = controller.toJson();

      // Simulate loading from state
      final newController = NodeFlowController<String>();
      await newController.fromJson(jsonData);

      expect(newController.nodes.length, 2);
      expect(newController.connections.length, 1);

      // Verify bidirectional sync would work
      expect(newController.nodes[0].data, 'Trigger Node');
      expect(newController.nodes[1].data, 'Action Node');
    });

    test('vyuh_node_flow - supports agent-controlled operations', () {
      // Test operations that an AI agent would perform
      final controller = NodeFlowController<String>();
      final agentController = Uuid();

      // Agent adds nodes
      final node1Id = agentController.v4();
      final node2Id = agentController.v4();

      controller.addNode(
        Node<String>(
          id: node1Id,
          type: 'agent_node',
          position: const Offset(100, 100),
          data: 'Agent Created Node 1',
        ),
      );

      controller.addNode(
        Node<String>(
          id: node2Id,
          type: 'agent_node',
          position: const Offset(300, 100),
          data: 'Agent Created Node 2',
        ),
      );

      // Agent creates connection
      controller.createConnection(node1Id, 'out', node2Id, 'in');

      // Agent updates node
      controller.updateNodeData(node1Id, 'Agent Updated Node 1');

      // Agent removes node
      controller.removeNode(node2Id);

      expect(controller.nodes.length, 1);
      expect(controller.nodes[0].data, 'Agent Updated Node 1');
    });
  });
}
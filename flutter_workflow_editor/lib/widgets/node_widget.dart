/// Individual node widget
library;

import 'package:flutter/material.dart';
import '../models/workflow_node.dart';

class NodeWidget extends StatelessWidget {
  final WorkflowNode node;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnd;
  final Function(String portId) onPortDragStart;
  final Function(Offset offset) onPortDragUpdate;
  final VoidCallback onPortDragEnd;

  const NodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onPortDragStart,
    required this.onPortDragUpdate,
    required this.onPortDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanStart: onDragStart,
      onPanUpdate: onDragUpdate,
      onPanEnd: (_) => onDragEnd(),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: _getNodeColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              twentadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getHeaderColor(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  if (node.icon != null) ...[
                    Icon(_getNodeIcon(), size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      node.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (node.disabled)
                    const Icon(Icons.block, size: 16, color: Colors.white70),
                ],
              ),
            ),

            // Body
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Node type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getHeaderColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getNodeTypeLabel(),
                      style: TextStyle(
                        fontSize: 11,
                        color: _getHeaderColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Execution status
                  if (node.executionState != NodeExecutionState.idle) ...[
                    const SizedBox(height: 8),
                    _buildExecutionStatus(),
                  ],

                  // Notes preview
                  if (node.notes != null && node.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      node.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Input ports (top)
            if (node.inputs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: node.inputs.map((port) => _buildPort(
                    context,
                    port,
                    isInput: true,
                  )).toList(),
                ),
              ),

            // Output ports (bottom)
            if (node.outputs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: node.outputs.map((port) => _buildPort(
                    context,
                    port,
                    isInput: false,
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPort(BuildContext context, NodePort port, {required bool isInput}) {
    return GestureDetector(
      onPanStart: (details) => onPortDragStart(port.id),
      onPanUpdate: (details) => onPortDragUpdate(details.globalPosition),
      onPanEnd: (_) => onPortDragEnd(),
      child: Tooltip(
        message: port.name,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getPortColor(port),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildExecutionStatus() {
    IconData icon;
    Color color;
    String text;

    switch (node.executionState) {
      case NodeExecutionState.running:
        icon = Icons.play_circle;
        color = Colors.blue;
        text = 'Running...';
        break;
      case NodeExecutionState.success:
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Success';
        break;
      case NodeExecutionState.error:
        icon = Icons.error;
        color = Colors.red;
        text = 'Error';
        break;
      case NodeExecutionState.waiting:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        text = 'Waiting';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getNodeColor(BuildContext context) {
    if (node.disabled) {
      return Colors.grey.shade200;
    }
    return Theme.of(context).cardColor;
  }

  Color _getHeaderColor(BuildContext context) {
    if (node.color != null) {
      return Color(int.parse(node.color!.replaceFirst('#', '0xFF')));
    }

    switch (node.type) {
      case NodeType.trigger:
      case NodeType.schedule:
      case NodeType.webhook:
      case NodeType.manual:
        return Colors.green;
      case NodeType.composioAction:
        return Colors.purple;
      case NodeType.mcpAction:
        return Colors.indigo;
      case NodeType.googleWorkspaceAction:
        return Colors.red;
      case NodeType.httpRequest:
        return Colors.blue;
      case NodeType.code:
        return Colors.orange;
      case NodeType.condition:
      case NodeType.ifElse:
      case NodeType.switch_:
        return Colors.amber;
      case NodeType.loop:
        return Colors.cyan;
      case NodeType.errorHandler:
      case NodeType.errorTrigger:
        return Colors.red;
      case NodeType.aiAssist:
      case NodeType.llmCall:
        return Colors.pink;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getNodeIcon() {
    switch (node.type) {
      case NodeType.trigger:
      case NodeType.manual:
        return Icons.play_arrow;
      case NodeType.schedule:
        return Icons.schedule;
      case NodeType.webhook:
        return Icons.webhook;
      case NodeType.composioAction:
        return Icons.extension;
      case NodeType.mcpAction:
        return Icons.computer;
      case NodeType.googleWorkspaceAction:
        return Icons.apps;
      case NodeType.httpRequest:
        return Icons.http;
      case NodeType.code:
        return Icons.code;
      case NodeType.condition:
      case NodeType.ifElse:
        return Icons.call_split;
      case NodeType.switch_:
        return Icons.switch_left;
      case NodeType.loop:
        return Icons.loop;
      case NodeType.setVariable:
        return Icons.edit;
      case NodeType.getVariable:
        return Icons.data_object;
      case NodeType.errorHandler:
        return Icons.error_outline;
      case NodeType.aiAssist:
        return Icons.auto_awesome;
      default:
        return Icons.widgets;
    }
  }

  String _getNodeTypeLabel() {
    switch (node.type) {
      case NodeType.trigger:
        return 'Trigger';
      case NodeType.schedule:
        return 'Schedule';
      case NodeType.webhook:
        return 'Webhook';
      case NodeType.manual:
        return 'Manual';
      case NodeType.composioAction:
        return 'Composio';
      case NodeType.mcpAction:
        return 'MCP';
      case NodeType.googleWorkspaceAction:
        return 'Google Workspace';
      case NodeType.httpRequest:
        return 'HTTP';
      case NodeType.code:
        return 'Code';
      case NodeType.condition:
        return 'Condition';
      case NodeType.ifElse:
        return 'If/Else';
      case NodeType.switch_:
        return 'Switch';
      case NodeType.loop:
        return 'Loop';
      case NodeType.setVariable:
        return 'Set Variable';
      case NodeType.getVariable:
        return 'Get Variable';
      case NodeType.function_:
        return 'Function';
      case NodeType.errorHandler:
        return 'Error Handler';
      case NodeType.aiAssist:
        return 'AI Assist';
      default:
        return 'Node';
    }
  }

  Color _getPortColor(NodePort port) {
    switch (port.type) {
      case PortType.input:
        return Colors.blue;
      case PortType.output:
        return Colors.green;
      case PortType.error:
        return Colors.red;
    }
  }
}

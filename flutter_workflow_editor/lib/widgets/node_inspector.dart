/// Node inspector for editing node properties
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../models/workflow_node.dart';
import '../models/node_definitions.dart';

class NodeInspector extends StatelessWidget {
  const NodeInspector({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Consumer<WorkflowState>(
        builder: (context, state, _) {
          final selectedNode = state.selectedNode;
          
          if (selectedNode == null) {
            return _buildEmptyState();
          }
          
          return Column(
            children: [
              _buildHeader(selectedNode),
              Expanded(
                child: _buildProperties(context, selectedNode),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Select a node to edit', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
  
  Widget _buildHeader(WorkflowNode node) {
    final definition = NodeDefinitions.getById(node.type);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Row(
        children: [
          if (definition != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: definition.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(definition.icon, color: definition.color),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  definition?.displayName ?? node.type,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProperties(BuildContext context, WorkflowNode node) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTextField(
          label: 'Node Name',
          value: node.name,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'name': value});
          },
        ),
        const SizedBox(height: 16),
        
        // Node-specific properties
        ..._buildNodeSpecificProperties(context, node),
        
        const SizedBox(height: 16),
        _buildSection('Advanced', [
          _buildTextField(
            label: 'Node ID',
            value: node.id,
            readOnly: true,
          ),
          _buildTextField(
            label: 'Type',
            value: node.type,
            readOnly: true,
          ),
        ]),
      ],
    );
  }
  
  List<Widget> _buildNodeSpecificProperties(BuildContext context, WorkflowNode node) {
    switch (node.type) {
      case 'unified_shell':
        return _buildUnifiedShellProperties(context, node);
      case 'http_request':
        return _buildHttpRequestProperties(context, node);
      case 'if_else':
        return _buildIfElseProperties(context, node);
      case 'set_variable':
        return _buildSetVariableProperties(context, node);
      case 'schedule_trigger':
        return _buildScheduleTriggerProperties(context, node);
      case 'webhook_trigger':
        return _buildWebhookTriggerProperties(context, node);
      case 'get_variable':
        return _buildGetVariableProperties(context, node);
      case 'ui_automation':
        return _buildUiAutomationProperties(context, node);
      case 'phone_control':
        return _buildPhoneControlProperties(context, node);
      case 'error_handler':
        return _buildErrorHandlerProperties(context, node);
      default:
        return [_buildGenericProperties(context, node)];
    }
  }
  
  List<Widget> _buildUnifiedShellProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Code Execution', [
        _buildDropdown(
          label: 'Language',
          value: node.data['language'] ?? 'auto',
          items: ['auto', 'python', 'javascript'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'language': value});
          },
        ),
        _buildTextField(
          label: 'Timeout (seconds)',
          value: (node.data['timeout'] ?? 30).toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(
              node.id,
              {'timeout': int.tryParse(value) ?? 30},
            );
          },
        ),
        _buildMultilineTextField(
          label: 'Code',
          value: node.data['code'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'code': value});
          },
          maxLines: 10,
        ),
      ]),
    ];
  }
  
  List<Widget> _buildHttpRequestProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('HTTP Request', [
        _buildTextField(
          label: 'URL',
          value: node.data['url'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'url': value});
          },
        ),
        _buildDropdown(
          label: 'Method',
          value: node.data['method'] ?? 'GET',
          items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'method': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Headers (JSON)',
          value: node.data['headers']?.toString() ?? '{}',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'headers': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Body',
          value: node.data['body']?.toString() ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'body': value});
          },
        ),
      ]),
    ];
  }
  
  List<Widget> _buildIfElseProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Condition', [
        _buildTextField(
          label: 'Expression',
          value: node.data['expression'] ?? 'value > 0',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'expression': value});
          },
        ),
      ]),
    ];
  }
  
  List<Widget> _buildSetVariableProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Variable', [
        _buildTextField(
          label: 'Variable Name',
          value: node.data['key'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'key': value});
          },
        ),
        _buildDropdown(
          label: 'Scope',
          value: node.data['scope'] ?? 'local',
          items: ['local', 'global'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'scope': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Value',
          value: node.data['value']?.toString() ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'value': value});
          },
        ),
      ]),
    ];
  }
  
  List<Widget> _buildScheduleTriggerProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Schedule', [
        _buildTextField(
          label: 'Cron Expression',
          value: node.data['cron'] ?? '0 0 * * *',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'cron': value});
          },
        ),
        _buildSwitch(
          label: 'Enabled',
          value: node.data['enabled'] ?? true,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'enabled': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildWebhookTriggerProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Webhook Configuration', [
        _buildTextField(
          label: 'Webhook URL',
          value: node.data['webhookUrl'] ?? 'Not generated',
          readOnly: true,
        ),
        _buildDropdown(
          label: 'Method',
          value: node.data['method'] ?? 'POST',
          items: ['GET', 'POST', 'PUT', 'DELETE'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'method': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildGetVariableProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Variable', [
        _buildTextField(
          label: 'Variable Name',
          value: node.data['key'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'key': value});
          },
        ),
        _buildTextField(
          label: 'Default Value',
          value: node.data['default']?.toString() ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'default': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildUiAutomationProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('UI Automation', [
        _buildDropdown(
          label: 'Action Type',
          value: node.data['action'] ?? 'click',
          items: ['click', 'type', 'scroll', 'wait', 'swipe', 'tap'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'action': value});
          },
        ),
        _buildTextField(
          label: 'Element Selector',
          value: node.data['selector'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'selector': value});
          },
        ),
        _buildTextField(
          label: 'Action Value',
          value: node.data['value']?.toString() ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'value': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildPhoneControlProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Phone Control', [
        _buildDropdown(
          label: 'Control Type',
          value: node.data['feature'] ?? 'call',
          items: ['call', 'sms', 'vibrate', 'volume', 'wifi', 'bluetooth', 'location'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'feature': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Parameters (JSON)',
          value: node.data['params']?.toString() ?? '{}',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'params': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildErrorHandlerProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Error Handling', [
        _buildDropdown(
          label: 'Error Type',
          value: node.data['errorType'] ?? 'all',
          items: ['all', 'network', 'timeout', 'validation', 'custom'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'errorType': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Recovery Action',
          value: node.data['recoveryAction']?.toString() ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'recoveryAction': value});
          },
        ),
      ]),
    ];
  }

  Widget _buildGenericProperties(BuildContext context, WorkflowNode node) {
    return _buildSection('Properties', [
      Text('No specific properties for this node type', style: TextStyle(color: Colors.grey[600])),
    ]);
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildTextField({
    required String label,
    required String value,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        readOnly: readOnly,
        keyboardType: keyboardType,
      ),
    );
  }
  
  Widget _buildMultilineTextField({
    required String label,
    required String value,
    ValueChanged<String>? onChanged,
    int maxLines = 5,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        onChanged: onChanged,
        maxLines: maxLines,
      ),
    );
  }
  
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Node inspector for editing node properties
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../models/workflow_node.dart';
import '../models/node_definitions.dart';
import '../services/mcp_server_manager.dart';
import '../models/mcp_server.dart';

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
      case 'manual_trigger':
        return _buildManualTriggerProperties(context, node);
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
      case 'loop':
        return _buildLoopProperties(context, node);
      case 'output':
        return _buildOutputProperties(context, node);
      case 'ai_assist':
        return _buildAiAssistProperties(context, node);
      case 'llm_call':
        return _buildLlmCallProperties(context, node);
      case 'switch':
        return _buildSwitchProperties(context, node);
      case 'merge':
        return _buildMergeProperties(context, node);
      case 'retry':
        return _buildRetryProperties(context, node);
      case 'function':
        return _buildFunctionProperties(context, node);
      case 'transform_data':
        return _buildTransformDataProperties(context, node);
      case 'notification':
        return _buildNotificationProperties(context, node);
      case 'composio_action':
        return _buildComposioActionProperties(context, node);
      case 'mcp_action':
        return _buildMcpActionProperties(context, node);
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

  List<Widget> _buildManualTriggerProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Trigger Information', [
        const Text('This node starts the workflow manually when triggered from the dashboard or via API.',
          style: TextStyle(fontSize: 14),
        ),
      ]),
    ];
  }

  List<Widget> _buildLoopProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Loop Configuration', [
        _buildTextField(
          label: 'Collection Variable',
          value: node.data['collection'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'collection': value});
          },
        ),
        _buildTextField(
          label: 'Item Variable Name',
          value: node.data['itemVariable'] ?? 'item',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'itemVariable': value});
          },
        ),
        _buildDropdown(
          label: 'Iterate Over',
          value: node.data['type'] ?? 'array',
          items: ['array', 'object'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'type': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildOutputProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Output Settings', [
        _buildDropdown(
          label: 'Output Format',
          value: node.data['format'] ?? 'json',
          items: ['json', 'text', 'structured'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'format': value});
          },
        ),
        _buildTextField(
          label: 'Label',
          value: node.data['label'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'label': value});
          },
        ),
        _buildSwitch(
          label: 'Include Metadata',
          value: node.data['includeMetadata'] ?? false,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'includeMetadata': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildAiAssistProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('AI Assistant', [
        _buildTextField(
          label: 'Task Description',
          value: node.data['task'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'task': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Context',
          value: node.data['context'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'context': value});
          },
        ),
        _buildDropdown(
          label: 'Model Selection',
          value: node.data['model'] ?? 'gpt-4',
          items: ['gpt-4', 'gpt-3.5-turbo', 'claude-3-opus', 'claude-3-sonnet', 'llama-3'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'model': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildLlmCallProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('LLM Configuration', [
        _buildMultilineTextField(
          label: 'Prompt',
          value: node.data['prompt'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'prompt': value});
          },
        ),
        _buildDropdown(
          label: 'Model',
          value: node.data['model'] ?? 'gpt-4',
          items: ['gpt-4', 'gpt-3.5-turbo', 'claude-3-opus', 'claude-3-sonnet'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'model': value});
          },
        ),
        _buildTextField(
          label: 'Temperature (0-2)',
          value: (node.data['temperature'] ?? 0.7).toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(
              node.id,
              {'temperature': double.tryParse(value) ?? 0.7},
            );
          },
        ),
        _buildTextField(
          label: 'Max Tokens',
          value: (node.data['maxTokens'] ?? 1000).toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(
              node.id,
              {'maxTokens': int.tryParse(value) ?? 1000},
            );
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildSwitchProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Switch Logic', [
        _buildTextField(
          label: 'Expression',
          value: node.data['expression'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'expression': value});
          },
        ),
        _buildTextField(
          label: 'Number of Cases',
          value: (node.data['caseCount'] ?? 3).toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(
              node.id,
              {'caseCount': int.tryParse(value) ?? 3},
            );
          },
        ),
        _buildMultilineTextField(
          label: 'Case Values (JSON List)',
          value: node.data['caseValues']?.toString() ?? '[]',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'caseValues': value});
          },
          maxLines: 5,
        ),
      ]),
    ];
  }

  List<Widget> _buildMergeProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Merge Configuration', [
        _buildDropdown(
          label: 'Merge Strategy',
          value: node.data['strategy'] ?? 'first-success',
          items: ['first-success', 'all', 'any', 'sequential'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'strategy': value});
          },
        ),
        _buildSwitch(
          label: 'Wait For All',
          value: node.data['waitForAll'] ?? true,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'waitForAll': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildRetryProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Retry Policy', [
        _buildTextField(
          label: 'Max Attempts',
          value: (node.data['maxAttempts'] ?? 3).toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(
              node.id,
              {'maxAttempts': int.tryParse(value) ?? 3},
            );
          },
        ),
        _buildDropdown(
          label: 'Backoff Strategy',
          value: node.data['backoffStrategy'] ?? 'none',
          items: ['none', 'linear', 'exponential'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'backoffStrategy': value});
          },
        ),
        _buildTextField(
          label: 'Backoff Delay (ms)',
          value: (node.data['backoffDelay'] ?? 1000).toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(
              node.id,
              {'backoffDelay': int.tryParse(value) ?? 1000},
            );
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildFunctionProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Function Details', [
        _buildTextField(
          label: 'Function Name',
          value: node.data['functionName'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'functionName': value});
          },
        ),
        _buildDropdown(
          label: 'Language',
          value: node.data['language'] ?? 'python',
          items: ['python', 'javascript', 'typescript', 'go', 'rust'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'language': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Parameters (JSON)',
          value: node.data['parameters']?.toString() ?? '{}',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'parameters': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildTransformDataProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Transformation', [
        _buildDropdown(
          label: 'Transform Type',
          value: node.data['transformType'] ?? 'map',
          items: ['map', 'filter', 'reduce', 'flatten', 'group'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'transformType': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Mapping Rules (JSON)',
          value: node.data['mappingRules']?.toString() ?? '{}',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'mappingRules': value});
          },
        ),
        _buildDropdown(
          label: 'Input Format',
          value: node.data['inputFormat'] ?? 'json',
          items: ['json', 'csv', 'xml'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'inputFormat': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildNotificationProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Notification Settings', [
        _buildDropdown(
          label: 'Notification Type',
          value: node.data['type'] ?? 'email',
          items: ['email', 'sms', 'push', 'slack', 'webhook'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'type': value});
          },
        ),
        _buildTextField(
          label: 'Title',
          value: node.data['title'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'title': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Message',
          value: node.data['message'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'message': value});
          },
        ),
        _buildTextField(
          label: 'Recipients / Channel',
          value: node.data['recipients'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'recipients': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildComposioActionProperties(BuildContext context, WorkflowNode node) {
    return [
      _buildSection('Composio Action', [
        _buildDropdown(
          label: 'Tool Selection',
          value: node.data['tool'] ?? 'github',
          items: ['github', 'slack', 'google-calendar', 'notion', 'jira'],
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'tool': value});
          },
        ),
        _buildTextField(
          label: 'Action Type',
          value: node.data['actionType'] ?? '',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'actionType': value});
          },
        ),
        _buildMultilineTextField(
          label: 'Parameters (JSON)',
          value: node.data['parameters']?.toString() ?? '{}',
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'parameters': value});
          },
        ),
      ]),
    ];
  }

  List<Widget> _buildMcpActionProperties(BuildContext context, WorkflowNode node) {
    final mcpManager = MCPServerManager.instance;
    final servers = mcpManager.servers;

    String selectedServer = node.data['serverName'] ?? '';
    String selectedTool = node.data['toolName'] ?? '';
    String argumentsJson = node.data['arguments']?.toString() ?? '{}';
    int timeout = node.data['timeout'] ?? 30;

    MCPServerConnection? getSelectedServer() {
      if (selectedServer.isEmpty) return null;
      return mcpManager.getServer(selectedServer);
    }

    List<String> getToolNames() {
      final server = getSelectedServer();
      if (server == null) return [];
      return server.tools.map((t) => t.name).toList();
    }

    String? getToolDescription() {
      final server = getSelectedServer();
      if (server == null) return null;
      final tool = server.tools.firstWhere(
        (t) => t.name == selectedTool,
        orElse: () => McpTool(name: '', inputSchema: {}),
      );
      return tool.description;
    }

    List<Widget> properties = [
      _buildSection('MCP Action', [
        // Server selector
        DropdownButtonFormField<String>(
          value: selectedServer.isEmpty ? null : selectedServer,
          decoration: InputDecoration(
            labelText: 'Server',
            hintText: 'Select MCP Server',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.cloud),
          ),
          items: servers.map((server) {
            return DropdownMenuItem(
              value: server.name,
              child: Row(
                children: [
                  Icon(
                    server.connected ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: server.connected ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text(server.name),
                  if (server.connected)
                    Text(
                      ' (${server.tools.length} tools)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<WorkflowState>().updateNodeData(
                node.id,
                {'serverName': value, 'toolName': ''}, // Reset tool when server changes
              );
            }
          },
        ),
        SizedBox(height: 12),

        // Tool selector
        DropdownButtonFormField<String>(
          value: selectedTool.isEmpty ? null : selectedTool,
          decoration: InputDecoration(
            labelText: 'Tool',
            hintText: 'Select Tool',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.build),
          ),
          items: getToolNames().map((toolName) {
            return DropdownMenuItem(
              value: toolName,
              child: Text(toolName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<WorkflowState>().updateNodeData(
                node.id,
                {'toolName': value},
              );
            }
          },
          enabled: selectedServer.isNotEmpty,
        ),
        SizedBox(height: 8),

        // Tool description
        if (getToolDescription() != null)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      getToolDescription()!,
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Arguments
        _buildMultilineTextField(
          label: 'Arguments (JSON)',
          value: argumentsJson,
          maxLines: 8,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(node.id, {'arguments': value});
          },
        ),

        // Timeout
        _buildTextField(
          label: 'Timeout (seconds)',
          value: timeout.toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<WorkflowState>().updateNodeData(
              node.id,
              {'timeout': int.tryParse(value) ?? 30},
            );
          },
        ),

        // Test button
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: selectedServer.isNotEmpty && selectedTool.isNotEmpty
              ? () async {
                  try {
                    final result = await mcpManager.executeToolAction(
                      serverName: selectedServer,
                      toolName: selectedTool,
                      arguments: _parseJson(argumentsJson),
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['success'] == true
                                ? 'Tool executed successfully'
                                : 'Tool execution failed',
                          ),
                          backgroundColor:
                              result['success'] == true ? Colors.green : Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              : null,
          icon: Icon(Icons.play_arrow),
          label: Text('Test Tool'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ]),
    ];

    return properties;
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
    } catch (e) {
      return {};
    }
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

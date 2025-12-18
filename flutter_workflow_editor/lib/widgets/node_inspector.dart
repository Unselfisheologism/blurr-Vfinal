/// Node inspector panel for editing node properties
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../state/app_state.dart';
import '../models/workflow_node.dart';
import '../models/google_workspace_tool.dart';

class NodeInspector extends StatelessWidget {
  const NodeInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowState>(
      builder: (context, workflowState, child) {
        final selectedNode = workflowState.selectedNode;

        if (selectedNode == null) {
          return _buildEmptyState(context);
        }

        return _buildInspectorContent(context, selectedNode, workflowState);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a node to edit',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorContent(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Node Properties',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => workflowState.selectNode(null),
                tooltip: 'Close',
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic info
                _buildSection(
                  'Basic Information',
                  [
                    _buildTextField(
                      label: 'Name',
                      value: node.name,
                      onChanged: (value) {
                        workflowState.updateNodeParameters(
                          node.id,
                          {'_name': value},
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Notes',
                      value: node.notes ?? '',
                      maxLines: 3,
                      onChanged: (value) {
                        workflowState.updateNodeParameters(
                          node.id,
                          {'_notes': value},
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSwitch(
                      label: 'Disabled',
                      value: node.disabled,
                      onChanged: (value) {
                        workflowState.updateNodeParameters(
                          node.id,
                          {'_disabled': value},
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Node-specific parameters
                _buildSection(
                  'Parameters',
                  _buildNodeParameters(context, node, workflowState),
                ),

                const SizedBox(height: 24),

                // Execution results
                if (node.executionResult != null) ...[
                  _buildSection(
                    'Execution Results',
                    [
                      _buildJsonViewer(node.executionResult),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Error details
                if (node.executionError != null) ...[
                  _buildSection(
                    'Error',
                    [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                node.executionError!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Actions
                _buildActions(context, node, workflowState),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  List<Widget> _buildNodeParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    final appState = context.read<AppState>();

    switch (node.type) {
      case NodeType.composioAction:
        return _buildComposioParameters(context, node, workflowState, appState);
      case NodeType.mcpAction:
        return _buildMcpParameters(context, node, workflowState, appState);
      case NodeType.googleWorkspaceAction:
        return _buildGoogleWorkspaceParameters(context, node, workflowState, appState);
      case NodeType.httpRequest:
        return _buildHttpParameters(context, node, workflowState);
      case NodeType.code:
        return _buildCodeParameters(context, node, workflowState);
      case NodeType.schedule:
        return _buildScheduleParameters(context, node, workflowState);
      case NodeType.webhook:
        return _buildWebhookParameters(context, node, workflowState);
      case NodeType.ifElse:
      case NodeType.condition:
        return _buildConditionParameters(context, node, workflowState);
      case NodeType.setVariable:
      case NodeType.getVariable:
        return _buildVariableParameters(context, node, workflowState);
      case NodeType.loop:
        return _buildLoopParameters(context, node, workflowState);
      default:
        return [
          Text(
            'No parameters available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ];
    }
  }

  List<Widget> _buildComposioParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
    AppState appState,
  ) {
    final tools = appState.composioTools;

    return [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Tool',
          border: OutlineInputBorder(),
        ),
        value: node.parameters['tool'] as String?,
        items: tools.map((tool) {
          return DropdownMenuItem(
            value: tool.id,
            child: Text(tool.name),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            workflowState.updateNodeParameters(node.id, {'tool': value});
          }
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Action',
        value: node.parameters['action']?.toString() ?? '',
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'action': value});
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Parameters (JSON)',
        value: node.parameters['parameters']?.toString() ?? '{}',
        maxLines: 5,
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'parameters': value});
        },
      ),
    ];
  }

  List<Widget> _buildMcpParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
    AppState appState,
  ) {
    final servers = appState.mcpServers;

    return [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Server',
          border: OutlineInputBorder(),
        ),
        value: node.parameters['server'] as String?,
        items: servers.map((server) {
          return DropdownMenuItem(
            value: server.id,
            child: Text(server.name),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            workflowState.updateNodeParameters(node.id, {'server': value});
          }
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Method',
        value: node.parameters['method']?.toString() ?? '',
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'method': value});
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Params (JSON)',
        value: node.parameters['params']?.toString() ?? '{}',
        maxLines: 5,
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'params': value});
        },
      ),
    ];
  }

  List<Widget> _buildGoogleWorkspaceParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
    AppState appState,
  ) {
    final tools = appState.googleWorkspaceTools;
    final isAuthenticated = appState.googleAuthenticated;

    // Show authentication warning if not authenticated
    if (!isAuthenticated) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Not Authenticated',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'You need to sign in to Google to use Google Workspace tools.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await appState.authenticateGoogleWorkspace();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully authenticated with Google!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Authentication failed. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // Show tool selection when authenticated
    return [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Service',
          border: OutlineInputBorder(),
        ),
        value: node.parameters['service'] as String?,
        items: tools.map((tool) {
          return DropdownMenuItem(
            value: tool.id,
            child: Row(
              children: [
                Icon(_getServiceIcon(tool.service), size: 20),
                const SizedBox(width: 8),
                Text(tool.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            workflowState.updateNodeParameters(node.id, {'service': value});
            // Clear action when service changes
            workflowState.updateNodeParameters(node.id, {'action': null});
          }
        },
      ),
      const SizedBox(height: 12),
      if (node.parameters['service'] != null) ...[
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Action',
            border: OutlineInputBorder(),
          ),
          value: node.parameters['action'] as String?,
          items: _getActionsForService(tools, node.parameters['service'] as String)
              .map((action) {
            return DropdownMenuItem(
              value: action.name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.displayName),
                  if (action.description != null)
                    Text(
                      action.description!,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              workflowState.updateNodeParameters(node.id, {'action': value});
            }
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Parameters (JSON)',
          value: node.parameters['parameters']?.toString() ?? '{}',
          maxLines: 8,
          onChanged: (value) {
            workflowState.updateNodeParameters(node.id, {'parameters': value});
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Example: {"to": "user@example.com", "subject": "Hello"}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    ];
  }

  IconData _getServiceIcon(GoogleWorkspaceService service) {
    switch (service) {
      case GoogleWorkspaceService.gmail:
        return Icons.email;
      case GoogleWorkspaceService.calendar:
        return Icons.calendar_today;
      case GoogleWorkspaceService.drive:
        return Icons.folder;
    }
  }

  List<GoogleWorkspaceAction> _getActionsForService(
    List<GoogleWorkspaceTool> tools,
    String serviceId,
  ) {
    final tool = tools.firstWhere(
      (t) => t.id == serviceId,
      orElse: () => tools.first,
    );
    return tool.actions;
  }

  List<Widget> _buildHttpParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Method',
          border: OutlineInputBorder(),
        ),
        value: node.parameters['method'] as String? ?? 'GET',
        items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'].map((method) {
          return DropdownMenuItem(value: method, child: Text(method));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            workflowState.updateNodeParameters(node.id, {'method': value});
          }
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'URL',
        value: node.parameters['url']?.toString() ?? '',
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'url': value});
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Headers (JSON)',
        value: node.parameters['headers']?.toString() ?? '{}',
        maxLines: 3,
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'headers': value});
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Body',
        value: node.parameters['body']?.toString() ?? '',
        maxLines: 5,
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'body': value});
        },
      ),
    ];
  }

  List<Widget> _buildCodeParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Language',
          border: OutlineInputBorder(),
        ),
        value: node.parameters['language'] as String? ?? 'javascript',
        items: ['javascript', 'python'].map((lang) {
          return DropdownMenuItem(value: lang, child: Text(lang));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            workflowState.updateNodeParameters(node.id, {'language': value});
          }
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Code',
        value: node.parameters['code']?.toString() ?? '',
        maxLines: 10,
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'code': value});
        },
      ),
    ];
  }

  List<Widget> _buildScheduleParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return [
      _buildTextField(
        label: 'Cron Expression',
        value: node.parameters['cron']?.toString() ?? '0 0 * * *',
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'cron': value});
        },
      ),
      const SizedBox(height: 8),
      Text(
        'Examples:\n'
        '• 0 0 * * * = Daily at midnight\n'
        '• 0 */6 * * * = Every 6 hours\n'
        '• 0 9 * * 1 = Mondays at 9 AM',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    ];
  }

  List<Widget> _buildWebhookParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Webhook URL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              'https://api.yourapp.com/webhooks/${node.id}',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Secret Key',
        value: node.parameters['secret']?.toString() ?? '',
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'secret': value});
        },
      ),
    ];
  }

  List<Widget> _buildConditionParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return [
      _buildTextField(
        label: 'Condition',
        value: node.parameters['condition']?.toString() ?? '',
        maxLines: 3,
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'condition': value});
        },
      ),
      const SizedBox(height: 8),
      Text(
        'Use {{ variable }} syntax:\n'
        '• {{ node.output }} > 10\n'
        '• {{ variable }} == "value"\n'
        '• {{ item.status }} == "active"',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    ];
  }

  List<Widget> _buildVariableParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return [
      _buildTextField(
        label: 'Variable Name',
        value: node.parameters['name']?.toString() ?? '',
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'name': value});
        },
      ),
      if (node.type == NodeType.setVariable) ...[
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Value',
          value: node.parameters['value']?.toString() ?? '',
          onChanged: (value) {
            workflowState.updateNodeParameters(node.id, {'value': value});
          },
        ),
      ],
    ];
  }

  List<Widget> _buildLoopParameters(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return [
      _buildTextField(
        label: 'Items (array or {{ expression }})',
        value: node.parameters['items']?.toString() ?? '',
        maxLines: 3,
        onChanged: (value) {
          workflowState.updateNodeParameters(node.id, {'items': value});
        },
      ),
      const SizedBox(height: 8),
      Text(
        'Loop over items. Use {{ item }} and {{ index }} inside loop.',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    ];
  }

  Widget _buildJsonViewer(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SelectableText(
        _prettyPrintJson(data),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }

  String _prettyPrintJson(dynamic data) {
    // Simple JSON formatting
    if (data == null) return 'null';
    if (data is String) return '"$data"';
    if (data is num || data is bool) return data.toString();
    if (data is Map) {
      final entries = data.entries.map((e) => '  "${e.key}": ${_prettyPrintJson(e.value)}');
      return '{\n${entries.join(',\n')}\n}';
    }
    if (data is List) {
      final items = data.map(_prettyPrintJson);
      return '[\n  ${items.join(',\n  ')}\n]';
    }
    return data.toString();
  }

  Widget _buildActions(
    BuildContext context,
    WorkflowNode node,
    WorkflowState workflowState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            workflowState.removeNode(node.id);
          },
          icon: const Icon(Icons.delete),
          label: const Text('Delete Node'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Duplicate node
          },
          icon: const Icon(Icons.copy),
          label: const Text('Duplicate Node'),
        ),
      ],
    );
  }
}

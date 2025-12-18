/// Node palette sidebar for dragging nodes onto canvas
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/workflow_state.dart';
import '../state/app_state.dart';
import '../models/workflow_node.dart';
import 'package:uuid/uuid.dart';

class NodePalette extends StatefulWidget {
  const NodePalette({super.key});

  @override
  State<NodePalette> createState() => _NodePaletteState();
}

class _NodePaletteState extends State<NodePalette> {
  final Uuid _uuid = const Uuid();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search nodes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Category tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _buildCategoryTabs(),
            ),
          ),

          const Divider(height: 1),

          // Node list
          Expanded(
            child: _buildNodeList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryTabs() {
    final categories = [
      'All',
      'Triggers',
      'Actions',
      'System',
      'Logic',
      'Data',
      'AI',
    ];

    return categories.map((category) {
      final isSelected = _selectedCategory == category;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedCategory = category);
          },
        ),
      );
    }).toList();
  }

  Widget _buildNodeList() {
    return Consumer2<WorkflowState, AppState>(
      builder: (context, workflowState, appState, child) {
        final nodes = _getAvailableNodeTypes(appState);
        final filtered = _filterNodes(nodes);

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No nodes found',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildNodeItem(
              context,
              filtered[index],
              appState,
            );
          },
        );
      },
    );
  }

  Widget _buildNodeItem(
    BuildContext context,
    NodeTemplate template,
    AppState appState,
  ) {
    final isProFeature = template.requiresPro && !appState.isPro;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isProFeature
            ? () => _showProUpgrade(context, template.name)
            : () => _addNode(context, template),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: template.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  template.icon,
                  color: template.color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isProFeature)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const Icon(Icons.add_circle_outline),
            ],
          ),
        ),
      ),
    );
  }

  void _addNode(BuildContext context, NodeTemplate template) {
    final workflowState = context.read<WorkflowState>();
    
    // Create new node
    final node = WorkflowNode(
      id: _uuid.v4(),
      name: template.name,
      type: template.type,
      parameters: template.defaultParameters,
      inputs: template.inputs,
      outputs: template.outputs,
      icon: template.icon.codePoint.toString(),
      color: '#${template.color.value.toRadixString(16).substring(2)}',
      x: 400, // Center of canvas
      y: 200,
    );

    workflowState.addNode(node);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template.name} added'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProUpgrade(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pro Feature'),
        content: Text('$feature requires a Pro subscription.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to Pro upgrade screen
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  List<NodeTemplate> _getAvailableNodeTypes(AppState appState) {
    return [
      // Triggers
      NodeTemplate(
        type: NodeType.manual,
        name: 'Manual Trigger',
        description: 'Start workflow manually',
        category: 'Triggers',
        icon: Icons.play_arrow,
        color: Colors.green,
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.schedule,
        name: 'Schedule',
        description: 'Run on a schedule (cron)',
        category: 'Triggers',
        icon: Icons.schedule,
        color: Colors.green,
        requiresPro: true,
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.webhook,
        name: 'Webhook',
        description: 'Trigger via HTTP webhook',
        category: 'Triggers',
        icon: Icons.webhook,
        color: Colors.green,
        requiresPro: true,
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),

      // Actions
      NodeTemplate(
        type: NodeType.composioAction,
        name: 'Composio Action',
        description: 'Execute Composio integration',
        category: 'Actions',
        icon: Icons.extension,
        color: Colors.purple,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.mcpAction,
        name: 'MCP Action',
        description: 'Execute MCP server request',
        category: 'Actions',
        icon: Icons.computer,
        color: Colors.indigo,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.googleWorkspaceAction,
        name: 'Google Workspace',
        description: 'Gmail, Calendar, Drive actions',
        category: 'Actions',
        icon: Icons.apps,
        color: Colors.red,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.httpRequest,
        name: 'HTTP Request',
        description: 'Make HTTP API call',
        category: 'Actions',
        icon: Icons.http,
        color: Colors.blue,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.code,
        name: 'Code',
        description: 'Run custom JavaScript/Python',
        category: 'Actions',
        icon: Icons.code,
        color: Colors.orange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),

      // System-level Tools (Blurr's unique capabilities)
      NodeTemplate(
        type: NodeType.uiAutomationAction,
        name: 'Tap Element',
        description: 'Tap UI element by text or coordinates',
        category: 'System',
        icon: Icons.touch_app,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_tap'},
      ),
      NodeTemplate(
        type: NodeType.uiAutomationAction,
        name: 'Type Text',
        description: 'Type text into focused input field',
        category: 'System',
        icon: Icons.keyboard,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_type'},
      ),
      NodeTemplate(
        type: NodeType.uiAutomationAction,
        name: 'Swipe',
        description: 'Perform swipe gesture',
        category: 'System',
        icon: Icons.swipe,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_swipe'},
      ),
      NodeTemplate(
        type: NodeType.uiAutomationAction,
        name: 'Scroll',
        description: 'Scroll up or down',
        category: 'System',
        icon: Icons.unfold_more,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_scroll'},
      ),
      NodeTemplate(
        type: NodeType.uiAutomationAction,
        name: 'Press Back',
        description: 'Press back button',
        category: 'System',
        icon: Icons.arrow_back,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_back'},
      ),
      NodeTemplate(
        type: NodeType.uiAutomationAction,
        name: 'Press Home',
        description: 'Go to home screen',
        category: 'System',
        icon: Icons.home,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_home'},
      ),
      NodeTemplate(
        type: NodeType.uiAutomationAction,
        name: 'Open Notifications',
        description: 'Open notification shade',
        category: 'System',
        icon: Icons.notifications,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_open_notifications'},
      ),
      NodeTemplate(
        type: NodeType.phoneControlAction,
        name: 'Open App',
        description: 'Open app by package name',
        category: 'System',
        icon: Icons.open_in_new,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_open_app'},
      ),
      NodeTemplate(
        type: NodeType.accessibilityAction,
        name: 'Get Screen Hierarchy',
        description: 'Get current UI structure as XML',
        category: 'System',
        icon: Icons.account_tree,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_get_hierarchy'},
      ),
      NodeTemplate(
        type: NodeType.phoneControlAction,
        name: 'Take Screenshot',
        description: 'Capture screenshot',
        category: 'System',
        icon: Icons.screenshot,
        color: Colors.deepOrange,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'ui_screenshot'},
      ),
      NodeTemplate(
        type: NodeType.notificationAction,
        name: 'Get All Notifications',
        description: 'Retrieve all active notifications',
        category: 'System',
        icon: Icons.notification_important,
        color: Colors.brown,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'notif_get_all'},
      ),
      NodeTemplate(
        type: NodeType.notificationAction,
        name: 'Get App Notifications',
        description: 'Get notifications from specific app',
        category: 'System',
        icon: Icons.notifications_active,
        color: Colors.brown,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'notif_get_by_app'},
      ),
      NodeTemplate(
        type: NodeType.systemToolAction,
        name: 'Get Current Activity',
        description: 'Get foreground app package name',
        category: 'System',
        icon: Icons.phone_android,
        color: Colors.teal.shade700,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'system_get_activity'},
      ),
      NodeTemplate(
        type: NodeType.systemToolAction,
        name: 'Open Settings',
        description: 'Open Android Settings',
        category: 'System',
        icon: Icons.settings,
        color: Colors.teal.shade700,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
        defaultParameters: {'toolId': 'system_open_settings'},
      ),

      // Logic
      NodeTemplate(
        type: NodeType.ifElse,
        name: 'If/Else',
        description: 'Conditional branching',
        category: 'Logic',
        icon: Icons.call_split,
        color: Colors.amber,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [
          NodePort(id: 'true', name: 'True', type: PortType.output),
          NodePort(id: 'false', name: 'False', type: PortType.output),
        ],
      ),
      NodeTemplate(
        type: NodeType.switch_,
        name: 'Switch',
        description: 'Route based on value',
        category: 'Logic',
        icon: Icons.switch_left,
        color: Colors.amber,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.loop,
        name: 'Loop',
        description: 'Iterate over items',
        category: 'Logic',
        icon: Icons.loop,
        color: Colors.cyan,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.merge,
        name: 'Merge',
        description: 'Combine multiple inputs',
        category: 'Logic',
        icon: Icons.merge,
        color: Colors.teal,
        inputs: [
          NodePort(id: 'input1', name: 'Input 1', type: PortType.input),
          NodePort(id: 'input2', name: 'Input 2', type: PortType.input),
        ],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),

      // Data
      NodeTemplate(
        type: NodeType.setVariable,
        name: 'Set Variable',
        description: 'Store data in variable',
        category: 'Data',
        icon: Icons.edit,
        color: Colors.blueGrey,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.getVariable,
        name: 'Get Variable',
        description: 'Retrieve stored variable',
        category: 'Data',
        icon: Icons.data_object,
        color: Colors.blueGrey,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.function_,
        name: 'Function',
        description: 'Transform data',
        category: 'Data',
        icon: Icons.functions,
        color: Colors.deepPurple,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),

      // AI
      NodeTemplate(
        type: NodeType.aiAssist,
        name: 'AI Assistant',
        description: 'AI-powered node generation',
        category: 'AI',
        icon: Icons.auto_awesome,
        color: Colors.pink,
        requiresPro: true,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
      NodeTemplate(
        type: NodeType.llmCall,
        name: 'LLM Call',
        description: 'Call language model API',
        category: 'AI',
        icon: Icons.psychology,
        color: Colors.pink,
        inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),

      // Error handling
      NodeTemplate(
        type: NodeType.errorHandler,
        name: 'Error Handler',
        description: 'Handle workflow errors',
        category: 'Logic',
        icon: Icons.error_outline,
        color: Colors.red,
        inputs: [NodePort(id: 'error', name: 'Error', type: PortType.error)],
        outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
      ),
    ];
  }

  List<NodeTemplate> _filterNodes(List<NodeTemplate> nodes) {
    var filtered = nodes;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((n) => n.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((n) =>
        n.name.toLowerCase().contains(query) ||
        n.description.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

class NodeTemplate {
  final NodeType type;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final List<NodePort> inputs;
  final List<NodePort> outputs;
  final Map<String, dynamic> defaultParameters;
  final bool requiresPro;

  NodeTemplate({
    required this.type,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.inputs = const [],
    this.outputs = const [],
    this.defaultParameters = const {},
    this.requiresPro = false,
  });
}

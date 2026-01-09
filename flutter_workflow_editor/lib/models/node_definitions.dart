/// Comprehensive node type definitions for workflow editor
/// Defines all available node types with their configurations
library;

import 'package:flutter/material.dart';

/// Node category for organization in palette
enum NodeCategory {
  triggers,
  actions,
  logic,
  data,
  integration,
  system,
  ai,
  errorHandling,
}

/// Extended node type information
class NodeDefinition {
  final String id;
  final String displayName;
  final String description;
  final NodeCategory category;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final bool isPro;
  
  const NodeDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.tags = const [],
    this.isPro = false,
  });
}

/// All available node definitions
class NodeDefinitions {
  // Trigger nodes
  static const manualTrigger = NodeDefinition(
    id: 'manual_trigger',
    displayName: 'Manual Trigger',
    description: 'Start workflow manually',
    category: NodeCategory.triggers,
    icon: Icons.play_circle_outline,
    color: Color(0xFF4CAF50),
    tags: ['trigger', 'start'],
  );
  
  static const scheduleTrigger = NodeDefinition(
    id: 'schedule_trigger',
    displayName: 'Schedule',
    description: 'Trigger workflow on a schedule (cron)',
    category: NodeCategory.triggers,
    icon: Icons.schedule,
    color: Color(0xFF2196F3),
    tags: ['trigger', 'schedule', 'cron', 'time'],
    isPro: true,
  );
  
  static const webhookTrigger = NodeDefinition(
    id: 'webhook_trigger',
    displayName: 'Webhook',
    description: 'Trigger via HTTP webhook',
    category: NodeCategory.triggers,
    icon: Icons.webhook,
    color: Color(0xFF9C27B0),
    tags: ['trigger', 'webhook', 'http', 'api'],
    isPro: true,
  );
  
  // Action nodes
  static const unifiedShellNode = NodeDefinition(
    id: 'unified_shell',
    displayName: 'Run Code',
    description: 'Execute Python or JavaScript code',
    category: NodeCategory.actions,
    icon: Icons.code,
    color: Color(0xFFFF9800),
    tags: ['code', 'python', 'javascript', 'execution'],
  );
  
  static const httpRequestNode = NodeDefinition(
    id: 'http_request',
    displayName: 'HTTP Request',
    description: 'Make HTTP/REST API calls',
    category: NodeCategory.actions,
    icon: Icons.http,
    color: Color(0xFF00BCD4),
    tags: ['http', 'api', 'rest', 'request'],
  );
  
  // Integration nodes
  static const composioActionNode = NodeDefinition(
    id: 'composio_action',
    displayName: 'Composio Action',
    description: 'Call connected Composio tools',
    category: NodeCategory.integration,
    icon: Icons.extension,
    color: Color(0xFF673AB7),
    tags: ['composio', 'integration', 'tools'],
  );
  
  static const mcpActionNode = NodeDefinition(
    id: 'mcp_action',
    displayName: 'MCP Server',
    description: 'Call MCP server tools',
    category: NodeCategory.integration,
    icon: Icons.integration_instructions,
    color: Color(0xFF3F51B5),
    tags: ['mcp', 'integration', 'server'],
  );
  
  // Logic nodes
  static const ifElseNode = NodeDefinition(
    id: 'if_else',
    displayName: 'IF/ELSE',
    description: 'Conditional branching',
    category: NodeCategory.logic,
    icon: Icons.call_split,
    color: Color(0xFFFF5722),
    tags: ['logic', 'condition', 'branch', 'if'],
  );

  static const switchNode = NodeDefinition(
    id: 'switch',
    displayName: 'Switch',
    description: 'Multiple condition branches',
    category: NodeCategory.logic,
    icon: Icons.alt_route,
    color: Color(0xFFE91E63),
    tags: ['logic', 'switch', 'branch', 'multiple'],
  );

  // Output node
  static const outputNode = NodeDefinition(
    id: 'output',
    displayName: 'Output',
    description: 'Display or capture results',
    category: NodeCategory.data,
    icon: Icons.outbox_outlined,
    color: Color(0xFF607D8B),
    tags: ['output', 'result', 'display'],
  );
  
  static const loopNode = NodeDefinition(
    id: 'loop',
    displayName: 'Loop',
    description: 'Iterate over items',
    category: NodeCategory.logic,
    icon: Icons.loop,
    color: Color(0xFF9E9E9E),
    tags: ['logic', 'loop', 'iterate', 'repeat'],
  );
  
  static const mergeNode = NodeDefinition(
    id: 'merge',
    displayName: 'Merge',
    description: 'Merge multiple execution paths',
    category: NodeCategory.logic,
    icon: Icons.merge,
    color: Color(0xFF607D8B),
    tags: ['logic', 'merge', 'combine'],
  );
  
  // Data nodes
  static const setVariableNode = NodeDefinition(
    id: 'set_variable',
    displayName: 'Set Variable',
    description: 'Store data in workflow variable',
    category: NodeCategory.data,
    icon: Icons.save_alt,
    color: Color(0xFF8BC34A),
    tags: ['data', 'variable', 'store', 'set'],
  );
  
  static const getVariableNode = NodeDefinition(
    id: 'get_variable',
    displayName: 'Get Variable',
    description: 'Retrieve stored variable',
    category: NodeCategory.data,
    icon: Icons.file_download,
    color: Color(0xFFCDDC39),
    tags: ['data', 'variable', 'retrieve', 'get'],
  );
  
  static const transformDataNode = NodeDefinition(
    id: 'transform_data',
    displayName: 'Transform Data',
    description: 'Map and transform data',
    category: NodeCategory.data,
    icon: Icons.transform,
    color: Color(0xFFFFC107),
    tags: ['data', 'transform', 'map', 'convert'],
  );
  
  static const functionNode = NodeDefinition(
    id: 'function',
    displayName: 'Function',
    description: 'Execute custom function/expression',
    category: NodeCategory.data,
    icon: Icons.functions,
    color: Color(0xFFFFEB3B),
    tags: ['data', 'function', 'expression', 'calculate'],
  );
  
  // System nodes (Blurr-specific)
  static const phoneControlNode = NodeDefinition(
    id: 'phone_control',
    displayName: 'Phone Control',
    description: 'Control phone functions (call, SMS, etc.)',
    category: NodeCategory.system,
    icon: Icons.phone_android,
    color: Color(0xFF00BCD4),
    tags: ['system', 'phone', 'control', 'android'],
  );
  
  static const notificationNode = NodeDefinition(
    id: 'notification',
    displayName: 'Notification',
    description: 'Send system notification',
    category: NodeCategory.system,
    icon: Icons.notifications,
    color: Color(0xFF03A9F4),
    tags: ['system', 'notification', 'alert'],
  );
  
  static const uiAutomationNode = NodeDefinition(
    id: 'ui_automation',
    displayName: 'UI Automation',
    description: 'Automate UI interactions',
    category: NodeCategory.system,
    icon: Icons.touch_app,
    color: Color(0xFF2196F3),
    tags: ['system', 'ui', 'automation', 'accessibility'],
  );
  
  // AI nodes
  static const aiAssistNode = NodeDefinition(
    id: 'ai_assist',
    displayName: 'AI Assistant',
    description: 'Call the ultra-generalist AI agent',
    category: NodeCategory.ai,
    icon: Icons.psychology,
    color: Color(0xFF9C27B0),
    tags: ['ai', 'agent', 'assistant', 'llm'],
  );
  
  static const llmCallNode = NodeDefinition(
    id: 'llm_call',
    displayName: 'LLM Call',
    description: 'Direct LLM API call with custom prompt',
    category: NodeCategory.ai,
    icon: Icons.chat_bubble_outline,
    color: Color(0xFF673AB7),
    tags: ['ai', 'llm', 'prompt', 'api'],
  );
  
  // Error handling
  static const errorHandlerNode = NodeDefinition(
    id: 'error_handler',
    displayName: 'Error Handler',
    description: 'Catch and handle errors',
    category: NodeCategory.errorHandling,
    icon: Icons.error_outline,
    color: Color(0xFFF44336),
    tags: ['error', 'handler', 'catch', 'exception'],
  );
  
  static const retryNode = NodeDefinition(
    id: 'retry',
    displayName: 'Retry',
    description: 'Retry failed operations',
    category: NodeCategory.errorHandling,
    icon: Icons.refresh,
    color: Color(0xFFFF5722),
    tags: ['error', 'retry', 'repeat', 'fallback'],
  );
  
  /// Core node definitions used in the MVP palette.
  static List<NodeDefinition> get core => [
    manualTrigger,
    unifiedShellNode,
    ifElseNode,
    loopNode,
    outputNode,
  ];

  /// Get all node definitions
  static List<NodeDefinition> get all => [
    manualTrigger,
    scheduleTrigger,
    webhookTrigger,
    unifiedShellNode,
    httpRequestNode,
    composioActionNode,
    mcpActionNode,
    ifElseNode,
    switchNode,
    loopNode,
    outputNode,
    mergeNode,
    setVariableNode,
    getVariableNode,
    transformDataNode,
    functionNode,
    phoneControlNode,
    notificationNode,
    uiAutomationNode,
    aiAssistNode,
    llmCallNode,
    errorHandlerNode,
    retryNode,
  ];
  
  /// Get nodes by category
  static List<NodeDefinition> getByCategory(NodeCategory category) {
    return all.where((node) => node.category == category).toList();
  }
  
  /// Get node definition by ID
  static NodeDefinition? getById(String id) {
    try {
      return all.firstWhere((node) => node.id == id);
    } catch (e) {
      return null;
    }
  }
}

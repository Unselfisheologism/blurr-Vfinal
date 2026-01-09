/// Comprehensive node type definitions for vyuh_node_flow integration
/// Defines all available node types with their metadata for vyuh_node_flow
library;

import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

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

/// Extended node type information with vyuh_node_flow metadata
class NodeDefinition {
  final String id;
  final String displayName;
  final String description;
  final NodeCategory category;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final bool isPro;
  
  // vyuh_node_flow specific metadata
  final List<Port> inputPorts;
  final List<Port> outputPorts;
  final NodeFlowNodeTheme? nodeTheme;
  
  const NodeDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.tags = const [],
    this.isPro = false,
    this.inputPorts = const [],
    this.outputPorts = const [],
    this.nodeTheme,
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
    inputPorts: [],
    outputPorts: [
      Port(id: 'exec', name: 'Execute'),
    ],
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
    inputPorts: [],
    outputPorts: [
      Port(id: 'exec', name: 'Execute'),
    ],
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
    inputPorts: [],
    outputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'data', name: 'Data'),
    ],
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
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'code', name: 'Code'),
      Port(id: 'inputs', name: 'Inputs'),
    ],
    outputPorts: [
      Port(id: 'result', name: 'Result'),
    ],
  );
  
  static const httpRequestNode = NodeDefinition(
    id: 'http_request',
    displayName: 'HTTP Request',
    description: 'Make HTTP/REST API calls',
    category: NodeCategory.actions,
    icon: Icons.http,
    color: Color(0xFF00BCD4),
    tags: ['http', 'api', 'rest', 'request'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'url', name: 'URL'),
      Port(id: 'method', name: 'Method'),
      Port(id: 'headers', name: 'Headers'),
      Port(id: 'body', name: 'Body'),
    ],
    outputPorts: [
      Port(id: 'response', name: 'Response'),
      Port(id: 'statusCode', name: 'Status'),
    ],
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
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'action', name: 'Action'),
      Port(id: 'parameters', name: 'Parameters'),
    ],
    outputPorts: [
      Port(id: 'result', name: 'Result'),
    ],
  );
  
  static const mcpActionNode = NodeDefinition(
    id: 'mcp_action',
    displayName: 'MCP Server',
    description: 'Call MCP server tools',
    category: NodeCategory.integration,
    icon: Icons.integration_instructions,
    color: Color(0xFF3F51B5),
    tags: ['mcp', 'integration', 'server'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'tool', name: 'Tool'),
      Port(id: 'parameters', name: 'Parameters'),
    ],
    outputPorts: [
      Port(id: 'result', name: 'Result'),
    ],
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
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'condition', name: 'Condition'),
    ],
    outputPorts: [
      Port(id: 'true', name: 'True'),
      Port(id: 'false', name: 'False'),
    ],
  );
  
  static const switchNode = NodeDefinition(
    id: 'switch',
    displayName: 'Switch',
    description: 'Multiple condition branches',
    category: NodeCategory.logic,
    icon: Icons.alt_route,
    color: Color(0xFFE91E63),
    tags: ['logic', 'switch', 'branch', 'multiple'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'value', name: 'Value'),
    ],
    outputPorts: [
      Port(id: 'case1', name: 'Case 1'),
      Port(id: 'case2', name: 'Case 2'),
      Port(id: 'case3', name: 'Case 3'),
      Port(id: 'default', name: 'Default'),
    ],
  );
  
  static const loopNode = NodeDefinition(
    id: 'loop',
    displayName: 'Loop',
    description: 'Iterate over items',
    category: NodeCategory.logic,
    icon: Icons.loop,
    color: Color(0xFF9E9E9E),
    tags: ['logic', 'loop', 'iterate', 'repeat'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'list', name: 'List'),
    ],
    outputPorts: [
      Port(id: 'loopBody', name: 'Loop Body'),
      Port(id: 'completed', name: 'Completed'),
      Port(id: 'element', name: 'Element'),
      Port(id: 'index', name: 'Index'),
    ],
  );
  
  static const mergeNode = NodeDefinition(
    id: 'merge',
    displayName: 'Merge',
    description: 'Merge multiple execution paths',
    category: NodeCategory.logic,
    icon: Icons.merge,
    color: Color(0xFF607D8B),
    tags: ['logic', 'merge', 'combine'],
    inputPorts: [
      Port(id: 'exec1', name: 'Execute 1'),
      Port(id: 'exec2', name: 'Execute 2'),
    ],
    outputPorts: [
      Port(id: 'exec', name: 'Execute'),
    ],
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
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'value', name: 'Value'),
      Port(id: 'variableName', name: 'Variable Name'),
    ],
    outputPorts: [
      Port(id: 'exec', name: 'Execute'),
    ],
  );
  
  static const getVariableNode = NodeDefinition(
    id: 'get_variable',
    displayName: 'Get Variable',
    description: 'Retrieve stored variable',
    category: NodeCategory.data,
    icon: Icons.file_download,
    color: Color(0xFFCDDC39),
    tags: ['data', 'variable', 'retrieve', 'get'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'variableName', name: 'Variable Name'),
    ],
    outputPorts: [
      Port(id: 'value', name: 'Value'),
    ],
  );
  
  static const transformDataNode = NodeDefinition(
    id: 'transform_data',
    displayName: 'Transform Data',
    description: 'Map and transform data',
    category: NodeCategory.data,
    icon: Icons.transform,
    color: Color(0xFFFFC107),
    tags: ['data', 'transform', 'map', 'convert'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'input', name: 'Input'),
      Port(id: 'mapping', name: 'Mapping'),
    ],
    outputPorts: [
      Port(id: 'output', name: 'Output'),
    ],
  );
  
  static const functionNode = NodeDefinition(
    id: 'function',
    displayName: 'Function',
    description: 'Execute custom function/expression',
    category: NodeCategory.data,
    icon: Icons.functions,
    color: Color(0xFFFFEB3B),
    tags: ['data', 'function', 'expression', 'calculate'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'expression', name: 'Expression'),
      Port(id: 'variables', name: 'Variables'),
    ],
    outputPorts: [
      Port(id: 'result', name: 'Result'),
    ],
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
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'action', name: 'Action'),
      Port(id: 'parameters', name: 'Parameters'),
    ],
    outputPorts: [
      Port(id: 'result', name: 'Result'),
    ],
  );
  
  static const notificationNode = NodeDefinition(
    id: 'notification',
    displayName: 'Notification',
    description: 'Send system notification',
    category: NodeCategory.system,
    icon: Icons.notifications,
    color: Color(0xFF03A9F4),
    tags: ['system', 'notification', 'alert'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'title', name: 'Title'),
      Port(id: 'message', name: 'Message'),
      Port(id: 'priority', name: 'Priority'),
    ],
    outputPorts: [
      Port(id: 'sent', name: 'Sent'),
    ],
  );
  
  static const uiAutomationNode = NodeDefinition(
    id: 'ui_automation',
    displayName: 'UI Automation',
    description: 'Automate UI interactions',
    category: NodeCategory.system,
    icon: Icons.touch_app,
    color: Color(0xFF2196F3),
    tags: ['system', 'ui', 'automation', 'accessibility'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'target', name: 'Target'),
      Port(id: 'action', name: 'Action'),
      Port(id: 'parameters', name: 'Parameters'),
    ],
    outputPorts: [
      Port(id: 'result', name: 'Result'),
    ],
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
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'prompt', name: 'Prompt'),
      Port(id: 'context', name: 'Context'),
    ],
    outputPorts: [
      Port(id: 'response', name: 'Response'),
    ],
  );
  
  static const llmCallNode = NodeDefinition(
    id: 'llm_call',
    displayName: 'LLM Call',
    description: 'Direct LLM API call with custom prompt',
    category: NodeCategory.ai,
    icon: Icons.chat_bubble_outline,
    color: Color(0xFF673AB7),
    tags: ['ai', 'llm', 'prompt', 'api'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'prompt', name: 'Prompt'),
      Port(id: 'model', name: 'Model'),
      Port(id: 'parameters', name: 'Parameters'),
    ],
    outputPorts: [
      Port(id: 'response', name: 'Response'),
    ],
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
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
    ],
    outputPorts: [
      Port(id: 'success', name: 'Success'),
      Port(id: 'error', name: 'Error'),
    ],
  );
  
  static const retryNode = NodeDefinition(
    id: 'retry',
    displayName: 'Retry',
    description: 'Retry failed operations',
    category: NodeCategory.errorHandling,
    icon: Icons.refresh,
    color: Color(0xFFFF5722),
    tags: ['error', 'retry', 'repeat', 'fallback'],
    inputPorts: [
      Port(id: 'exec', name: 'Execute'),
      Port(id: 'maxAttempts', name: 'Max Attempts'),
      Port(id: 'delay', name: 'Delay'),
    ],
    outputPorts: [
      Port(id: 'success', name: 'Success'),
      Port(id: 'failed', name: 'Failed'),
    ],
  );
  
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
  
  /// Get node definition by node type
  static NodeDefinition? getByNodeType(String nodeType) {
    return getById(nodeType);
  }
}

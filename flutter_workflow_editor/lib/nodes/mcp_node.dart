/// MCP (Model Context Protocol) server integration node - CORRECTED API
/// Dynamically loads and calls user-connected MCP servers
library;

import 'package:fl_nodes_workspace/fl_nodes.dart';
import 'package:flutter/material.dart';

/// MCP action node prototype - CORRECTED
class MCPNodePrototype {
  static NodePrototype create() {
    return NodePrototype(
      idName: 'mcp_action',
      displayName: 'MCP Server',
      description: 'Call tools from connected MCP servers',
      
      // CORRECTED: Single ports array
      ports: [
        // Control ports
        ControlInputPortPrototype(
          idName: 'exec',
          displayName: 'Execute',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.white,
          ),
        ),
        ControlOutputPortPrototype(
          idName: 'success',
          displayName: 'Success',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.green,
          ),
        ),
        ControlOutputPortPrototype(
          idName: 'error',
          displayName: 'Error',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.red,
          ),
        ),
        
        // Data ports
        DataInputPortPrototype(
          idName: 'server',
          displayName: 'Server',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.indigo,
          ),
        ),
        DataInputPortPrototype(
          idName: 'tool',
          displayName: 'Tool',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.indigo,
          ),
        ),
        DataInputPortPrototype(
          idName: 'parameters',
          displayName: 'Parameters',
          dataType: Map,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.blue,
          ),
        ),
        DataOutputPortPrototype(
          idName: 'result',
          displayName: 'Result',
          dataType: dynamic,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.orange,
          ),
        ),
        DataOutputPortPrototype(
          idName: 'error',
          displayName: 'Error',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.red,
          ),
        ),
      ],
      
      // CORRECTED: Proper onExecute
      onExecute: (ports, fields, state, flowTo, passData) async {
        final String? serverId = ports['server'] as String? ?? fields['server'] as String?;
        final String? toolId = ports['tool'] as String? ?? fields['tool'] as String?;
        final Map<String, dynamic> parameters = 
            ports['parameters'] as Map<String, dynamic>? ?? 
            fields['parameters'] as Map<String, dynamic>? ?? {};
        
        if (serverId == null || toolId == null) {
          passData({('error', 'Server or tool not selected')});
          await flowTo({'error'});
          return;
        }
        
        try {
          // Actual execution would call platform bridge
          // For now, simulate success
          final result = {
            'success': true,
            'data': 'MCP tool executed',
          };
          
          passData({('result', result)});
          await flowTo({'success'});
        } catch (e) {
          passData({('error', e.toString())});
          await flowTo({'error'});
        }
      },
      
      // Custom styling
      styleBuilder: (state) => FlNodeStyle(
        decoration: BoxDecoration(
          color: const Color(0xFF3F51B5).withOpacity(state.isSelected ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3F51B5),
            width: state.isSelected ? 3 : 2,
          ),
        ),
        headerStyleBuilder: (state) => FlNodeHeaderStyle(
          decoration: BoxDecoration(
            color: const Color(0xFF3F51B5),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              bottomLeft: Radius.circular(state.isCollapsed ? 10 : 0),
              bottomRight: Radius.circular(state.isCollapsed ? 10 : 0),
            ),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          icon: const Icon(
            Icons.integration_instructions,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

/// Model for MCP server
class MCPServer {
  final String id;
  final String name;
  final String description;
  final List<MCPTool> tools;
  final bool connected;
  final String status;
  
  const MCPServer({
    required this.id,
    required this.name,
    required this.description,
    required this.tools,
    required this.connected,
    this.status = 'ready',
  });
  
  factory MCPServer.fromJson(Map<String, dynamic> json) {
    return MCPServer(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      tools: (json['tools'] as List?)
          ?.map((t) => MCPTool.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      connected: json['connected'] as bool? ?? false,
      status: json['status'] as String? ?? 'ready',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'tools': tools.map((t) => t.toJson()).toList(),
    'connected': connected,
    'status': status,
  };
}

/// Model for MCP tool
class MCPTool {
  final String id;
  final String name;
  final String description;
  final Map<String, MCPParameter> parameters;
  final MCPToolSchema? schema;
  
  const MCPTool({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
    this.schema,
  });
  
  factory MCPTool.fromJson(Map<String, dynamic> json) {
    final params = <String, MCPParameter>{};
    if (json['parameters'] != null) {
      (json['parameters'] as Map<String, dynamic>).forEach((key, value) {
        params[key] = MCPParameter.fromJson(value as Map<String, dynamic>);
      });
    }
    
    return MCPTool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      parameters: params,
      schema: json['schema'] != null 
          ? MCPToolSchema.fromJson(json['schema'] as Map<String, dynamic>)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'parameters': parameters.map((k, v) => MapEntry(k, v.toJson())),
    'schema': schema?.toJson(),
  };
}

/// Model for MCP parameter
class MCPParameter {
  final String name;
  final String type;
  final String? description;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumValues;
  
  const MCPParameter({
    required this.name,
    required this.type,
    this.description,
    this.required = false,
    this.defaultValue,
    this.enumValues,
  });
  
  factory MCPParameter.fromJson(Map<String, dynamic> json) {
    return MCPParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
      defaultValue: json['default'],
      enumValues: (json['enum'] as List?)?.cast<String>(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'description': description,
    'required': required,
    'default': defaultValue,
    'enum': enumValues,
  };
}

/// Model for MCP tool schema
class MCPToolSchema {
  final String type;
  final Map<String, dynamic> properties;
  final List<String> required;
  
  const MCPToolSchema({
    required this.type,
    required this.properties,
    required this.required,
  });
  
  factory MCPToolSchema.fromJson(Map<String, dynamic> json) {
    return MCPToolSchema(
      type: json['type'] as String? ?? 'object',
      properties: json['properties'] as Map<String, dynamic>? ?? {},
      required: (json['required'] as List?)?.cast<String>() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'properties': properties,
    'required': required,
  };
}

/// Widget for selecting MCP server and tool
class MCPServerSelectorWidget extends StatefulWidget {
  final List<MCPServer> availableServers;
  final String? selectedServerId;
  final String? selectedToolId;
  final ValueChanged<String> onServerSelected;
  final ValueChanged<String> onToolSelected;
  
  const MCPServerSelectorWidget({
    Key? key,
    required this.availableServers,
    this.selectedServerId,
    this.selectedToolId,
    required this.onServerSelected,
    required this.onToolSelected,
  }) : super(key: key);
  
  @override
  State<MCPServerSelectorWidget> createState() => _MCPServerSelectorWidgetState();
}

class _MCPServerSelectorWidgetState extends State<MCPServerSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedServer = widget.availableServers
        .where((s) => s.id == widget.selectedServerId)
        .firstOrNull;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: widget.selectedServerId,
          hint: const Text('Select MCP Server'),
          isExpanded: true,
          items: widget.availableServers.map((server) {
            return DropdownMenuItem(
              value: server.id,
              child: Row(
                children: [
                  Icon(
                    server.connected ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: server.connected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(server.name)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onServerSelected(value);
            }
          },
        ),
        
        const SizedBox(height: 8),
        
        if (selectedServer != null) ...[
          DropdownButton<String>(
            value: widget.selectedToolId,
            hint: const Text('Select Tool'),
            isExpanded: true,
            items: selectedServer.tools.map((tool) {
              return DropdownMenuItem(
                value: tool.id,
                child: Text(tool.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onToolSelected(value);
              }
            },
          ),
        ],
      ],
    );
  }
}

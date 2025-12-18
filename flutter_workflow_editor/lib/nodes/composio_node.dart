/// Composio integration node - CORRECTED FL NODES API
/// Dynamically loads and executes user-connected Composio tools
library;

import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';

/// Composio action node prototype - CORRECTED
class ComposioNodePrototype {
  static NodePrototype create() {
    return NodePrototype(
      idName: 'composio_action',
      displayName: 'Composio Action',
      description: 'Execute actions from connected Composio integrations',
      
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
          idName: 'tool',
          displayName: 'Tool',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.purple,
          ),
        ),
        DataInputPortPrototype(
          idName: 'action',
          displayName: 'Action',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.purple,
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
        final String? toolId = ports['tool'] as String? ?? fields['tool'] as String?;
        final String? actionId = ports['action'] as String? ?? fields['action'] as String?;
        final Map<String, dynamic> parameters = 
            ports['parameters'] as Map<String, dynamic>? ?? 
            fields['parameters'] as Map<String, dynamic>? ?? {};
        
        if (toolId == null || actionId == null) {
          passData({('error', 'Tool or action not selected')});
          await flowTo({'error'});
          return;
        }
        
        try {
          // Actual execution would call platform bridge
          // For now, simulate success
          final result = {
            'success': true,
            'data': 'Composio action executed',
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
          color: const Color(0xFF673AB7).withOpacity(state.isSelected ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF673AB7),
            width: state.isSelected ? 3 : 2,
          ),
        ),
        headerStyleBuilder: (state) => FlNodeHeaderStyle(
          decoration: BoxDecoration(
            color: const Color(0xFF673AB7),
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
            Icons.extension,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

/// Model for Composio tool
class ComposioTool {
  final String id;
  final String name;
  final String description;
  final List<ComposioAction> actions;
  final bool connected;
  
  const ComposioTool({
    required this.id,
    required this.name,
    required this.description,
    required this.actions,
    required this.connected,
  });
  
  factory ComposioTool.fromJson(Map<String, dynamic> json) {
    return ComposioTool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      actions: (json['actions'] as List?)
          ?.map((a) => ComposioAction.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
      connected: json['connected'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'actions': actions.map((a) => a.toJson()).toList(),
    'connected': connected,
  };
}

/// Model for Composio action
class ComposioAction {
  final String id;
  final String name;
  final String description;
  final Map<String, ComposioParameter> parameters;
  
  const ComposioAction({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
  });
  
  factory ComposioAction.fromJson(Map<String, dynamic> json) {
    final params = <String, ComposioParameter>{};
    if (json['parameters'] != null) {
      (json['parameters'] as Map<String, dynamic>).forEach((key, value) {
        params[key] = ComposioParameter.fromJson(value as Map<String, dynamic>);
      });
    }
    
    return ComposioAction(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      parameters: params,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'parameters': parameters.map((k, v) => MapEntry(k, v.toJson())),
  };
}

/// Model for Composio parameter
class ComposioParameter {
  final String name;
  final String type;
  final String? description;
  final bool required;
  final dynamic defaultValue;
  
  const ComposioParameter({
    required this.name,
    required this.type,
    this.description,
    this.required = false,
    this.defaultValue,
  });
  
  factory ComposioParameter.fromJson(Map<String, dynamic> json) {
    return ComposioParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
      defaultValue: json['default'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'description': description,
    'required': required,
    'default': defaultValue,
  };
}

/// Widget for selecting Composio tool and action
class ComposioToolSelectorWidget extends StatefulWidget {
  final List<ComposioTool> availableTools;
  final String? selectedToolId;
  final String? selectedActionId;
  final ValueChanged<String> onToolSelected;
  final ValueChanged<String> onActionSelected;
  
  const ComposioToolSelectorWidget({
    Key? key,
    required this.availableTools,
    this.selectedToolId,
    this.selectedActionId,
    required this.onToolSelected,
    required this.onActionSelected,
  }) : super(key: key);
  
  @override
  State<ComposioToolSelectorWidget> createState() => _ComposioToolSelectorWidgetState();
}

class _ComposioToolSelectorWidgetState extends State<ComposioToolSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedTool = widget.availableTools
        .where((t) => t.id == widget.selectedToolId)
        .firstOrNull;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: widget.selectedToolId,
          hint: const Text('Select Tool'),
          isExpanded: true,
          items: widget.availableTools.map((tool) {
            return DropdownMenuItem(
              value: tool.id,
              child: Row(
                children: [
                  Icon(
                    tool.connected ? Icons.check_circle : Icons.error_outline,
                    size: 16,
                    color: tool.connected ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tool.name)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onToolSelected(value);
            }
          },
        ),
        
        const SizedBox(height: 8),
        
        if (selectedTool != null) ...[
          DropdownButton<String>(
            value: widget.selectedActionId,
            hint: const Text('Select Action'),
            isExpanded: true,
            items: selectedTool.actions.map((action) {
              return DropdownMenuItem(
                value: action.id,
                child: Text(action.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onActionSelected(value);
              }
            },
          ),
        ],
      ],
    );
  }
}

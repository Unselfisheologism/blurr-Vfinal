/// FL Nodes prototypes for workflow nodes - CORRECTED API
/// Converts our node definitions into fl_nodes compatible prototypes
library;

import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';
import 'node_definitions.dart';

/// Factory for creating fl_nodes prototypes from our definitions
/// CORRECTED: Uses proper fl_nodes API structure
class FlNodePrototypeFactory {
  /// Create a node prototype from a node definition
  /// CORRECTED: Uses 'ports' array instead of separate port lists
  static NodePrototype createPrototype(NodeDefinition definition) {
    return NodePrototype(
      idName: definition.id,
      displayName: definition.displayName,
      description: definition.description,
      
      // CORRECTED: Use single 'ports' array
      ports: _createPorts(definition),
      
      // Optional: Custom styling with state-responsive builders
      styleBuilder: (state) => FlNodeStyle(
        decoration: BoxDecoration(
          color: definition.color.withOpacity(state.isSelected ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: definition.color,
            width: state.isSelected ? 3 : 2,
          ),
          boxShadow: state.isSelected
              ? [
                  BoxShadow(
                    color: definition.color.withOpacity(0.5),
                    twentadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        headerStyleBuilder: (state) => FlNodeHeaderStyle(
          decoration: BoxDecoration(
            color: definition.color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              // Adjust bottom radius based on collapse state
              bottomLeft: Radius.circular(state.isCollapsed ? 10 : 0),
              bottomRight: Radius.circular(state.isCollapsed ? 10 : 0),
            ),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          icon: Icon(
            state.isCollapsed ? Icons.expand_more : Icons.expand_less,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      
      // Execution logic - will be handled by execution engine
      onExecute: (ports, fields, state, flowTo, passData) async {
        // Placeholder - actual execution in WorkflowExecutionEngine
        // The fl_nodes runner will call this during executeGraph()
        
        // For demonstration: log execution
        debugPrint('Node ${definition.id} executed');
        
        // Example of using flowTo and passData:
        // await flowTo({'out'}); // Trigger output port
        // passData({('result', someValue)}); // Pass data to output port
      },
    );
  }
  
  /// Create ports array for node (CORRECTED API)
  /// According to fl_nodes docs, all ports go in a single array
  static List<dynamic> _createPorts(NodeDefinition definition) {
    final ports = <dynamic>[];
    
    // CONTROL INPUT PORTS
    // Most nodes have control input except triggers
    if (definition.category != NodeCategory.triggers) {
      ports.add(ControlInputPortPrototype(
        idName: 'exec',
        displayName: 'Exec',
        style: FlPortStyle(
          shape: FlPortShape.triangle,
          color: Colors.white,
          linkStyleBuilder: (state) => const FlLinkStyle(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue],
            ),
            lineWidth: 2.0,
            drawMode: FlLinkDrawMode.solid,
            curveType: FlLinkCurveType.bezier,
          ),
        ),
      ));
    }
    
    // CONTROL OUTPUT PORTS
    // Vary by node type
    switch (definition.id) {
      case 'if_else':
        ports.addAll([
          ControlOutputPortPrototype(
            idName: 'true',
            displayName: 'True',
            style: _controlOutputPortStyle(Colors.green),
          ),
          ControlOutputPortPrototype(
            idName: 'false',
            displayName: 'False',
            style: _controlOutputPortStyle(Colors.red),
          ),
        ]);
        break;
      
      case 'switch':
        ports.addAll([
          ControlOutputPortPrototype(
            idName: 'case1',
            displayName: 'Case 1',
            style: _controlOutputPortStyle(Colors.blue),
          ),
          ControlOutputPortPrototype(
            idName: 'case2',
            displayName: 'Case 2',
            style: _controlOutputPortStyle(Colors.orange),
          ),
          ControlOutputPortPrototype(
            idName: 'case3',
            displayName: 'Case 3',
            style: _controlOutputPortStyle(Colors.purple),
          ),
          ControlOutputPortPrototype(
            idName: 'default',
            displayName: 'Default',
            style: _controlOutputPortStyle(Colors.grey),
          ),
        ]);
        break;
      
      case 'loop':
        ports.addAll([
          ControlOutputPortPrototype(
            idName: 'loopBody',
            displayName: 'Loop Body',
            style: _controlOutputPortStyle(Colors.cyan),
          ),
          ControlOutputPortPrototype(
            idName: 'completed',
            displayName: 'Completed',
            style: _controlOutputPortStyle(Colors.green),
          ),
        ]);
        break;
      
      case 'error_handler':
        ports.addAll([
          ControlOutputPortPrototype(
            idName: 'success',
            displayName: 'Success',
            style: _controlOutputPortStyle(Colors.green),
          ),
          ControlOutputPortPrototype(
            idName: 'error',
            displayName: 'Error',
            style: _controlOutputPortStyle(Colors.red),
          ),
        ]);
        break;
      
      default:
        // Standard single output
        ports.add(ControlOutputPortPrototype(
          idName: 'out',
          displayName: 'Out',
          style: _controlOutputPortStyle(Colors.white),
        ));
    }
    
    // DATA INPUT PORTS
    // Add based on node type
    ports.addAll(_createDataInputPorts(definition));
    
    // DATA OUTPUT PORTS
    // Standard result output for all nodes
    ports.add(DataOutputPortPrototype(
      idName: 'result',
      displayName: 'Result',
      dataType: dynamic,
      style: _dataOutputPortStyle(Colors.orange),
    ));
    
    // Add specific data outputs for certain nodes
    ports.addAll(_createDataOutputPorts(definition));
    
    return ports;
  }
  
  /// Create data input ports based on node type
  static List<DataInputPortPrototype> _createDataInputPorts(NodeDefinition definition) {
    final ports = <DataInputPortPrototype>[];
    
    switch (definition.id) {
      case 'unified_shell':
        ports.addAll([
          DataInputPortPrototype(
            idName: 'code',
            displayName: 'Code',
            dataType: String,
            style: _dataInputPortStyle(Colors.yellow),
          ),
          DataInputPortPrototype(
            idName: 'language',
            displayName: 'Language',
            dataType: String,
            style: _dataInputPortStyle(Colors.yellow),
          ),
          DataInputPortPrototype(
            idName: 'inputs',
            displayName: 'Inputs',
            dataType: Map,
            style: _dataInputPortStyle(Colors.blue),
          ),
        ]);
        break;
      
      case 'http_request':
        ports.addAll([
          DataInputPortPrototype(
            idName: 'url',
            displayName: 'URL',
            dataType: String,
            style: _dataInputPortStyle(Colors.cyan),
          ),
          DataInputPortPrototype(
            idName: 'method',
            displayName: 'Method',
            dataType: String,
            style: _dataInputPortStyle(Colors.cyan),
          ),
          DataInputPortPrototype(
            idName: 'body',
            displayName: 'Body',
            dataType: dynamic,
            style: _dataInputPortStyle(Colors.cyan),
          ),
        ]);
        break;
      
      case 'loop':
        ports.add(DataInputPortPrototype(
          idName: 'list',
          displayName: 'List',
          dataType: dynamic,
          style: _dataInputPortStyle(Colors.purple),
        ));
        break;
      
      case 'if_else':
        ports.add(DataInputPortPrototype(
          idName: 'condition',
          displayName: 'Condition',
          dataType: bool,
          style: _dataInputPortStyle(Colors.green),
        ));
        break;
      
      case 'set_variable':
        ports.addAll([
          DataInputPortPrototype(
            idName: 'key',
            displayName: 'Key',
            dataType: String,
            style: _dataInputPortStyle(Colors.green),
          ),
          DataInputPortPrototype(
            idName: 'value',
            displayName: 'Value',
            dataType: dynamic,
            style: _dataInputPortStyle(Colors.green),
          ),
        ]);
        break;
      
      case 'get_variable':
        ports.add(DataInputPortPrototype(
          idName: 'key',
          displayName: 'Key',
          dataType: String,
          style: _dataInputPortStyle(Colors.lime),
        ));
        break;
      
      case 'composio_action':
        ports.addAll([
          DataInputPortPrototype(
            idName: 'tool',
            displayName: 'Tool',
            dataType: String,
            style: _dataInputPortStyle(Colors.purple),
          ),
          DataInputPortPrototype(
            idName: 'action',
            displayName: 'Action',
            dataType: String,
            style: _dataInputPortStyle(Colors.purple),
          ),
          DataInputPortPrototype(
            idName: 'parameters',
            displayName: 'Parameters',
            dataType: Map,
            style: _dataInputPortStyle(Colors.purple),
          ),
        ]);
        break;
      
      case 'mcp_action':
        ports.addAll([
          DataInputPortPrototype(
            idName: 'server',
            displayName: 'Server',
            dataType: String,
            style: _dataInputPortStyle(Colors.indigo),
          ),
          DataInputPortPrototype(
            idName: 'tool',
            displayName: 'Tool',
            dataType: String,
            style: _dataInputPortStyle(Colors.indigo),
          ),
          DataInputPortPrototype(
            idName: 'parameters',
            displayName: 'Parameters',
            dataType: Map,
            style: _dataInputPortStyle(Colors.indigo),
          ),
        ]);
        break;
    }
    
    return ports;
  }
  
  /// Create data output ports based on node type
  static List<DataOutputPortPrototype> _createDataOutputPorts(NodeDefinition definition) {
    final ports = <DataOutputPortPrototype>[];
    
    switch (definition.id) {
      case 'loop':
        ports.addAll([
          DataOutputPortPrototype(
            idName: 'listElem',
            displayName: 'Element',
            dataType: dynamic,
            style: _dataOutputPortStyle(Colors.purple),
          ),
          DataOutputPortPrototype(
            idName: 'listIdx',
            displayName: 'Index',
            dataType: int,
            style: _dataOutputPortStyle(Colors.purple),
          ),
        ]);
        break;
      
      case 'unified_shell':
        ports.add(DataOutputPortPrototype(
          idName: 'output',
          displayName: 'Output',
          dataType: String,
          style: _dataOutputPortStyle(Colors.yellow),
        ));
        break;
    }
    
    return ports;
  }
  
  /// Helper: Create control output port style
  static FlPortStyle _controlOutputPortStyle(Color color) {
    return FlPortStyle(
      shape: FlPortShape.triangle,
      color: color,
      linkStyleBuilder: (state) => FlLinkStyle(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.5)],
        ),
        lineWidth: 2.0,
        drawMode: FlLinkDrawMode.solid,
        curveType: FlLinkCurveType.bezier,
      ),
    );
  }
  
  /// Helper: Create data input port style
  static FlPortStyle _dataInputPortStyle(Color color) {
    return FlPortStyle(
      shape: FlPortShape.circle,
      color: color,
      linkStyleBuilder: (state) => FlLinkStyle(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
        ),
        lineWidth: 2.5,
        drawMode: FlLinkDrawMode.solid,
        curveType: FlLinkCurveType.bezier,
      ),
    );
  }
  
  /// Helper: Create data output port style
  static FlPortStyle _dataOutputPortStyle(Color color) {
    return FlPortStyle(
      shape: FlPortShape.circle,
      color: color,
      linkStyleBuilder: (state) => FlLinkStyle(
        gradient: LinearGradient(
          colors: [color, Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        lineWidth: 3.0,
        drawMode: FlLinkDrawMode.solid,
        curveType: FlLinkCurveType.bezier,
      ),
    );
  }
}

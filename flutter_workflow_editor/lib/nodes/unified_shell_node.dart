/// Unified Shell code execution node - CORRECTED FL NODES API
/// Exposes the app's powerful multi-language shell to workflows
library;

import '../stubs/fl_nodes_stubs.dart';
import 'package:flutter/material.dart';

/// Unified Shell node prototype factory - CORRECTED
class UnifiedShellNodePrototype {
  static NodePrototype create() {
    return NodePrototype(
      idName: 'unified_shell',
      displayName: 'Run Code',
      description: 'Execute Python or JavaScript code with full shell capabilities',
      
      // CORRECTED: Use single 'ports' array
      ports: [
        // Control input
        ControlInputPortPrototype(
          idName: 'exec',
          displayName: 'Execute',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.white,
          ),
        ),
        
        // Control outputs
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
        
        // Data inputs
        DataInputPortPrototype(
          idName: 'code',
          displayName: 'Code',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.yellow,
          ),
        ),
        DataInputPortPrototype(
          idName: 'language',
          displayName: 'Language',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.orange,
          ),
        ),
        DataInputPortPrototype(
          idName: 'inputs',
          displayName: 'Inputs',
          dataType: Map,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.blue,
          ),
        ),
        
        // Data outputs
        DataOutputPortPrototype(
          idName: 'output',
          displayName: 'Output',
          dataType: String,
          style: FlPortStyle(
            shape: FlPortShape.circle,
            color: Colors.yellow,
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
      
      // CORRECTED: Proper onExecute signature
      // (Map<String, dynamic> ports, Map<String, dynamic> fields, 
      //  Map<String, dynamic> state, Function flowTo, Function passData)
      onExecute: (ports, fields, state, flowTo, passData) async {
        // Get inputs from ports
        final String code = ports['code'] as String? ?? fields['code'] as String? ?? '';
        final String language = ports['language'] as String? ?? fields['language'] as String? ?? 'auto';
        final Map<String, dynamic> inputs = ports['inputs'] as Map<String, dynamic>? ?? {};
        final int timeout = fields['timeout'] as int? ?? 30;
        
        if (code.isEmpty) {
          // Pass error data and flow to error output
          passData({('error', 'No code provided')});
          await flowTo({'error'});
          return;
        }
        
        try {
          // Note: Actual execution would call platform bridge
          // For fl_nodes demonstration, we simulate success
          
          // Simulate execution result
          final result = {
            'success': true,
            'output': 'Code executed successfully',
            'result': {'data': 'example result'},
          };
          
          // Pass data to output ports
          passData({
            ('output', result['output']),
            ('result', result['result']),
          });
          
          // Flow to success output
          await flowTo({'success'});
        } catch (e) {
          // Pass error data
          passData({('error', e.toString())});
          
          // Flow to error output
          await flowTo({'error'});
        }
      },
      
      // Custom styling
      styleBuilder: (state) => FlNodeStyle(
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800).withOpacity(state.isSelected ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF9800),
            width: state.isSelected ? 3 : 2,
          ),
          boxShadow: state.isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        headerStyleBuilder: (state) => FlNodeHeaderStyle(
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800),
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
            fontSize: 14,
          ),
          icon: Icon(
            Icons.code,
            color: Colors.white,
            size: 18,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

/// Node-specific configuration for Unified Shell
class UnifiedShellNodeConfig {
  final String code;
  final String language;
  final int timeoutSeconds;
  final Map<String, dynamic> inputs;
  
  const UnifiedShellNodeConfig({
    required this.code,
    this.language = 'auto',
    this.timeoutSeconds = 30,
    this.inputs = const {},
  });
  
  Map<String, dynamic> toJson() => {
    'code': code,
    'language': language,
    'timeout': timeoutSeconds,
    'inputs': inputs,
  };
  
  factory UnifiedShellNodeConfig.fromJson(Map<String, dynamic> json) {
    return UnifiedShellNodeConfig(
      code: json['code'] as String? ?? '',
      language: json['language'] as String? ?? 'auto',
      timeoutSeconds: json['timeout'] as int? ?? 30,
      inputs: json['inputs'] as Map<String, dynamic>? ?? {},
    );
  }
}

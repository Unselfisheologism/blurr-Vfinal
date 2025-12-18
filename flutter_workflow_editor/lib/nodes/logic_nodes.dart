/// Logic node prototypes (IF/ELSE, Switch, Loop, Merge) - CORRECTED API
library;

import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// IF/ELSE node prototype - CORRECTED
class IfElseNodePrototype {
  static NodePrototype create() {
    return NodePrototype(
      idName: 'if_else',
      displayName: 'IF/ELSE',
      description: 'Conditional branching based on expression',
      
      // CORRECTED: Single ports array
      ports: [
        ControlInputPortPrototype(
          idName: 'exec',
          displayName: 'In',
        ),
        ControlOutputPortPrototype(
          idName: 'true',
          displayName: 'True',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.green,
          ),
        ),
        ControlOutputPortPrototype(
          idName: 'false',
          displayName: 'False',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.red,
          ),
        ),
        DataInputPortPrototype(
          idName: 'condition',
          displayName: 'Condition',
          dataType: bool,
        ),
        DataOutputPortPrototype(
          idName: 'result',
          displayName: 'Result',
          dataType: bool,
        ),
      ],
      
      // CORRECTED: Proper onExecute
      onExecute: (ports, fields, state, flowTo, passData) async {
        final bool condition = ports['condition'] as bool? ?? false;
        
        // Pass result data
        passData({('result', condition)});
        
        // Flow based on condition
        if (condition) {
          await flowTo({'true'});
        } else {
          await flowTo({'false'});
        }
      },
    );
  }
}

/// Loop node prototype - CORRECTED with stateful iteration
class LoopNodePrototype {
  static NodePrototype create() {
    return NodePrototype(
      idName: 'loop',
      displayName: 'Loop',
      description: 'Iterate over items in a list',
      
      ports: [
        ControlInputPortPrototype(
          idName: 'exec',
          displayName: 'In',
        ),
        ControlOutputPortPrototype(
          idName: 'loopBody',
          displayName: 'Loop Body',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.cyan,
          ),
        ),
        ControlOutputPortPrototype(
          idName: 'completed',
          displayName: 'Done',
          style: FlPortStyle(
            shape: FlPortShape.triangle,
            color: Colors.green,
          ),
        ),
        DataInputPortPrototype(
          idName: 'list',
          displayName: 'Items',
          dataType: List,
        ),
        DataOutputPortPrototype(
          idName: 'currentItem',
          displayName: 'Current Item',
          dataType: dynamic,
        ),
        DataOutputPortPrototype(
          idName: 'index',
          displayName: 'Index',
          dataType: int,
        ),
        DataOutputPortPrototype(
          idName: 'total',
          displayName: 'Total',
          dataType: int,
        ),
      ],
      
      // CORRECTED: Stateful iteration following fl_nodes pattern
      onExecute: (ports, fields, state, flowTo, passData) async {
        final List<dynamic> list = ports['list'] as List<dynamic>? ?? [];
        
        late int i;
        
        // Check if this node has stored iteration state
        if (!state.containsKey('iteration')) {
          i = state['iteration'] = 0;
        } else {
          i = state['iteration'] as int;
        }
        
        // If there are still elements to iterate
        if (i < list.length) {
          // Pass current element and index to output ports
          passData({
            ('currentItem', list[i]),
            ('index', i),
            ('total', list.length),
          });
          
          // Increment iteration counter and store in node state
          state['iteration'] = ++i;
          
          // Trigger the loop body control output
          await flowTo({'loopBody'});
        } else {
          // If iteration is complete, trigger the "completed" output
          // Use unawaited to prevent blocking
          unawaited(flowTo({'completed'}));
        }
      },
    );
  }
}

/// Switch node prototype - CORRECTED
class SwitchNodePrototype {
  static NodePrototype create() {
    return NodePrototype(
      idName: 'switch',
      displayName: 'Switch',
      description: 'Route flow based on multiple conditions',
      
      ports: [
        ControlInputPortPrototype(
          idName: 'exec',
          displayName: 'In',
        ),
        ControlOutputPortPrototype(
          idName: 'case1',
          displayName: 'Case 1',
          style: FlPortStyle(color: Colors.blue),
        ),
        ControlOutputPortPrototype(
          idName: 'case2',
          displayName: 'Case 2',
          style: FlPortStyle(color: Colors.orange),
        ),
        ControlOutputPortPrototype(
          idName: 'case3',
          displayName: 'Case 3',
          style: FlPortStyle(color: Colors.purple),
        ),
        ControlOutputPortPrototype(
          idName: 'default',
          displayName: 'Default',
          style: FlPortStyle(color: Colors.grey),
        ),
        DataInputPortPrototype(
          idName: 'value',
          displayName: 'Value',
          dataType: dynamic,
        ),
        DataOutputPortPrototype(
          idName: 'matchedCase',
          displayName: 'Matched Case',
          dataType: String,
        ),
      ],
      
      onExecute: (ports, fields, state, flowTo, passData) async {
        final dynamic value = ports['value'];
        final List<Map<String, dynamic>> cases = fields['cases'] as List<Map<String, dynamic>>? ?? [];
        
        // Check each case
        for (var i = 0; i < cases.length && i < 3; i++) {
          final caseData = cases[i];
          final expression = caseData['expression'] as String;
          
          // Simplified condition check (in production, use expression parser)
          if (_evaluateExpression(expression, value)) {
            final output = 'case${i + 1}';
            passData({('matchedCase', output)});
            await flowTo({output});
            return;
          }
        }
        
        // No match, use default
        passData({('matchedCase', 'default')});
        await flowTo({'default'});
      },
    );
  }
  
  static bool _evaluateExpression(String expression, dynamic value) {
    // Simplified - in production use expressions package
    return true;
  }
}

/// Merge node prototype - CORRECTED
class MergeNodePrototype {
  static NodePrototype create() {
    return NodePrototype(
      idName: 'merge',
      displayName: 'Merge',
      description: 'Wait for multiple paths and merge results',
      
      ports: [
        ControlInputPortPrototype(
          idName: 'input1',
          displayName: 'Input 1',
        ),
        ControlInputPortPrototype(
          idName: 'input2',
          displayName: 'Input 2',
        ),
        ControlInputPortPrototype(
          idName: 'input3',
          displayName: 'Input 3',
        ),
        ControlOutputPortPrototype(
          idName: 'out',
          displayName: 'Out',
        ),
        DataInputPortPrototype(
          idName: 'data1',
          displayName: 'Data 1',
          dataType: dynamic,
        ),
        DataInputPortPrototype(
          idName: 'data2',
          displayName: 'Data 2',
          dataType: dynamic,
        ),
        DataInputPortPrototype(
          idName: 'data3',
          displayName: 'Data 3',
          dataType: dynamic,
        ),
        DataOutputPortPrototype(
          idName: 'merged',
          displayName: 'Merged Data',
          dataType: List,
        ),
      ],
      
      onExecute: (ports, fields, state, flowTo, passData) async {
        final mode = fields['mode'] as String? ?? 'wait_all';
        
        // Collect all available data
        final mergedData = <dynamic>[];
        if (ports['data1'] != null) mergedData.add(ports['data1']);
        if (ports['data2'] != null) mergedData.add(ports['data2']);
        if (ports['data3'] != null) mergedData.add(ports['data3']);
        
        // Pass merged data
        passData({('merged', mergedData)});
        
        // Flow to output
        await flowTo({'out'});
      },
    );
  }
}

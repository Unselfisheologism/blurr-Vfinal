/// Main workflow editor screen
/// This is the entry point that will be embedded via FlutterFragment in Kotlin/Swift
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/workflow_canvas.dart';
import 'widgets/node_palette.dart';
import 'widgets/node_inspector.dart';
import 'widgets/toolbar.dart';
import 'widgets/execution_panel.dart';
import 'state/workflow_state.dart';
import 'state/app_state.dart';
import 'models/workflow.dart';

class WorkflowEditorScreen extends StatefulWidget {
  const WorkflowEditorScreen({super.key});

  @override
  State<WorkflowEditorScreen> createState() => _WorkflowEditorScreenState();
}

class _WorkflowEditorScreenState extends State<WorkflowEditorScreen> {
  bool _showPalette = true;
  bool _showInspector = true;
  bool _showExecutionPanel = false;

  @override
  void initState() {
    super.initState();
    _initializeWorkflow();
  }

  Future<void> _initializeWorkflow() async {
    final appState = context.read<AppState>();
    await appState.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Toolbar at top
            WorkflowToolbar(
              onTogglePalette: () => setState(() => _showPalette = !_showPalette),
              onToggleInspector: () => setState(() => _showInspector = !_showInspector),
              onToggleExecution: () => setState(() => _showExecutionPanel = !_showExecutionPanel),
              showPalette: _showPalette,
              showInspector: _showInspector,
              showExecutionPanel: _showExecutionPanel,
            ),
            
            // Main content area
            Expanded(
              child: Row(
                children: [
                  // Left sidebar - Node palette
                  if (_showPalette)
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: const NodePalette(),
                    ),
                  
                  // Center - Canvas
                  Expanded(
                    child: Stack(
                      children: [
                        const WorkflowCanvas(),

                        // Execution panel overlay (bottom sheet style)
                        if (_showExecutionPanel)
                          Positioned(
                            left: 0,
                            right: _showInspector ? 320 : 0,
                            bottom: 0,
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: const ExecutionPanel(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Right sidebar - Node inspector
                  if (_showInspector)
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: const NodeInspector(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

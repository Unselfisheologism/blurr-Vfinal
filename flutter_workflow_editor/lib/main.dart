/// Entry point for Flutter module
/// This file is used when running the module standalone for development
library workflow_editor;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workflow_editor_screen.dart';
import 'state/workflow_state.dart';
import 'state/app_state.dart';

void main() {
  runApp(const WorkflowEditorApp());
}

class WorkflowEditorApp extends StatelessWidget {
  const WorkflowEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => WorkflowState()),
      ],
      child: MaterialApp(
        title: 'Workflow Editor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: const WorkflowEditorScreen(),
      ),
    );
  }
}

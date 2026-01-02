import 'package:flutter/material.dart';

void main() {
  runApp(const FlutterWorkflowEditorModule());
}

class FlutterWorkflowEditorModule extends StatelessWidget {
  const FlutterWorkflowEditorModule({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Workflow Editor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ModuleHomePage(),
    );
  }
}

class ModuleHomePage extends StatelessWidget {
  const ModuleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Module'),
      ),
      body: const Center(
        child: Text('Flutter Workflow Editor Module'),
      ),
    );
  }
}

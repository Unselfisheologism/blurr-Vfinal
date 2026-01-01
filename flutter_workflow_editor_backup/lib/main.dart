/// Entry point for Flutter module
/// This file is used when running the module standalone for development
library workflow_editor;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workflow_editor_screen.dart';
import 'state/workflow_state.dart';
import 'state/app_state.dart';
import 'text_editor/text_editor_screen.dart';
import 'spreadsheet_editor/spreadsheet_editor_screen.dart';
import 'spreadsheet_editor/state/spreadsheet_state.dart';
import 'media_canvas/media_canvas_screen.dart';
import 'media_canvas/state/canvas_state.dart';
import 'daw_editor/daw_editor_screen.dart';
import 'daw_editor/state/daw_state.dart';
import 'learning_platform/learning_hub_screen.dart';
import 'learning_platform/state/learning_platform_state.dart';
import 'video_editor/video_editor_screen.dart';
import 'video_editor/state/video_editor_state.dart';

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
        ChangeNotifierProvider(create: (_) => SpreadsheetState()),
        ChangeNotifierProvider(create: (_) => CanvasState()),
        ChangeNotifierProvider(create: (_) => DawState.empty()),
        ChangeNotifierProvider(create: (_) => LearningPlatformState()),
        ChangeNotifierProvider(create: (_) => VideoEditorState()),
      ],
      child: MaterialApp(
        title: 'Blurr AI Apps',
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
        // Route configuration for AI-native apps
        initialRoute: '/',
        routes: {
          '/': (context) => const WorkflowEditorScreen(),
          '/text_editor': (context) => const TextEditorScreen(),
          '/text_editor_template': (context) => const TextEditorScreen(startWithTemplate: true),
          '/spreadsheet_editor': (context) => const SpreadsheetEditorScreen(),
          '/media_canvas': (context) => const MediaCanvasScreen(),
          '/daw_editor': (context) => const DawEditorScreen(),
          '/learning_hub': (context) => const LearningHubScreen(),
          '/video_editor': (context) => const VideoEditorScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes with parameters
          if (settings.name?.startsWith('/text_editor/') ?? false) {
            final documentId = settings.name!.replaceFirst('/text_editor/', '');
            return MaterialPageRoute(
              builder: (context) => TextEditorScreen(documentId: documentId),
            );
          }
          if (settings.name?.startsWith('/spreadsheet_editor/') ?? false) {
            final documentId = settings.name!.replaceFirst('/spreadsheet_editor/', '');
            return MaterialPageRoute(
              builder: (context) => SpreadsheetEditorScreen(documentId: documentId),
            );
          }
          if (settings.name?.startsWith('/media_canvas/') ?? false) {
            final documentId = settings.name!.replaceFirst('/media_canvas/', '');
            return MaterialPageRoute(
              builder: (context) => MediaCanvasScreen(documentId: documentId),
            );
          }
          if (settings.name?.startsWith('/daw_editor/') ?? false) {
            final projectName = settings.name!.replaceFirst('/daw_editor/', '');
            return MaterialPageRoute(
              builder: (context) => DawEditorScreen(projectName: projectName),
            );
          }
          return null;
        },
      ),
    );
  }
}

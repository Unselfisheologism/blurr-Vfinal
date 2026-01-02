import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_workflow_editor/main.dart';
import 'package:flutter_workflow_editor/workflow_editor_screen.dart';

void main() {
  testWidgets('WorkflowEditorApp boots', (WidgetTester tester) async {
    await tester.pumpWidget(const WorkflowEditorApp());
    await tester.pump();

    expect(find.byType(WorkflowEditorScreen), findsOneWidget);
  });
}

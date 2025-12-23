package com.twent.voice

import com.twent.voice.ui.placeholder.FlutterModuleRequiredActivity

/**
 * Placeholder host for the Flutter workflow editor.
 *
 * The real workflow editor is implemented in the Flutter module under flutter_workflow_editor/.
 * This activity keeps the Android app buildable even when the generated Flutter Android artifacts
 * are not present in the repository checkout.
 */
class WorkflowEditorActivity : FlutterModuleRequiredActivity() {

    override val featureName: String = "Workflow Editor"
}

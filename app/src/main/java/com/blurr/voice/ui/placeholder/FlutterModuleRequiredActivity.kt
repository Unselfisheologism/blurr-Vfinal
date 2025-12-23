package com.twent.voice.ui.placeholder

import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

abstract class FlutterModuleRequiredActivity : AppCompatActivity() {

    protected abstract val featureName: String

    protected open val extraDetails: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        title = featureName

        val paddingPx = (24 * resources.displayMetrics.density).toInt()

        val message = buildString {
            append("\"$featureName\" requires the bundled Flutter module, but this project checkout doesn't include the generated Android artifacts (e.g., flutter_workflow_editor/.android/Flutter or built AARs).\n\n")
            append("This build will work for the native Android assistant + tools, but the Flutter-based editors/canvas are disabled.\n\n")
            append("To enable these screens:\n")
            append("1) Install Flutter SDK\n")
            append("2) In flutter_workflow_editor/: run: flutter pub get\n")
            append("3) Generate Android add-to-app artifacts (e.g., flutter build aar, or generate the .android folder)\n")
            append("4) Re-enable the Flutter module inclusion in settings.gradle.kts and the project dependency in app/build.gradle.kts\n")

            extraDetails?.let {
                append("\n\n")
                append(it)
            }
        }

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(paddingPx, paddingPx, paddingPx, paddingPx)
            gravity = Gravity.CENTER
        }

        val textView = TextView(this).apply {
            text = message
            textSize = 16f
        }

        val closeButton = Button(this).apply {
            text = "Close"
            setOnClickListener { finish() }
        }

        root.addView(textView)
        root.addView(closeButton)

        setContentView(root)
    }
}

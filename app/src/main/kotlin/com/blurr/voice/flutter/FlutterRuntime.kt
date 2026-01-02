package com.blurr.voice.flutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.widget.Button
import android.widget.TextView
import com.blurr.voice.R

object FlutterRuntime {

    /**
     * In this repo we sometimes build without the real Flutter engine/artifacts and fall back to
     * lightweight stubs (see :flutter_stubs). Those stubs compile but cannot render Flutter UI.
     *
     * This check looks for io.flutter.embedding.engine.loader.FlutterLoader, which exists in the
     * real Flutter SDK but not in our stubs. This allows us to:
     * 1. Compile the Android app without Flutter SDK installed
     * 2. Detect at runtime whether Flutter is available
     * 3. Show a helpful error screen directing users to generate artifacts
     *
     * To enable Flutter features, run:
     *   cd flutter_workflow_editor && flutter pub get && flutter build aar --release
     * Then rebuild the Android app. Gradle will automatically use the real Flutter module when the
     * generated Android project exists; otherwise it will fall back to :flutter_stubs.
     *
     * See /FLUTTER_INTEGRATION_STATUS.md for complete documentation.
     */
    fun isAvailable(): Boolean {
        return runCatching {
            Class.forName("io.flutter.embedding.engine.loader.FlutterLoader")
        }.isSuccess
    }

    fun showUnavailableScreen(
        activity: Activity,
        featureTitle: String,
        featureDescription: String = ""
    ) {
        activity.setContentView(R.layout.activity_flutter_unavailable)

        activity.findViewById<TextView>(R.id.flutter_unavailable_title)?.text = featureTitle

        val message = buildString {
            if (featureDescription.isNotBlank()) {
                append(featureDescription.trim())
                append("\n\n")
            }
            append(
                "This build does not include the embedded Flutter module, so the editor cannot be displayed. " +
                    "If you're building from source, generate the Flutter Android artifacts (see flutter_workflow_editor/INTEGRATION_GUIDE.md) and rebuild."
            )
        }

        activity.findViewById<TextView>(R.id.flutter_unavailable_message)?.text = message

        activity.findViewById<Button>(R.id.flutter_unavailable_back)?.setOnClickListener {
            activity.finish()
        }

        activity.findViewById<Button>(R.id.flutter_unavailable_help)?.setOnClickListener {
            val url = "https://docs.flutter.dev/add-to-app"
            runCatching {
                activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
            }
        }
    }
}

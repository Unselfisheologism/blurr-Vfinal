package com.blurr.voice.flutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.widget.Button
import android.widget.TextView
import com.blurr.voice.BuildConfig
import com.blurr.voice.R

object FlutterRuntime {

    /**
     * In this repo we sometimes build without the real Flutter engine/artifacts and fall back to
     * lightweight stubs (see :flutter_stubs). Those stubs compile but cannot render Flutter UI.
     */
    fun isAvailable(): Boolean {
        if (!BuildConfig.HAS_EMBEDDED_FLUTTER_MODULE) return false

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
                "This build does not include the embedded Flutter module, so this feature cannot be displayed. " +
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

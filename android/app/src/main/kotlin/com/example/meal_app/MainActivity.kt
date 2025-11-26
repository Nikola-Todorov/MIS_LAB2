package com.example.recipe_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.recipe_app/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup method channel for native Android functionality
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        openUrlInBrowser(url)
                        result.success(true)
                    } else {
                        result.error("INVALID_URL", "URL is null", null)
                    }
                }
                "shareRecipe" -> {
                    val title = call.argument<String>("title")
                    val text = call.argument<String>("text")
                    if (title != null && text != null) {
                        shareRecipe(title, text)
                        result.success(true)
                    } else {
                        result.error("INVALID_DATA", "Title or text is null", null)
                    }
                }
                "showToast" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        android.widget.Toast.makeText(
                            this,
                            message,
                            android.widget.Toast.LENGTH_SHORT
                        ).show()
                        result.success(true)
                    } else {
                        result.error("INVALID_MESSAGE", "Message is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openUrlInBrowser(url: String) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            startActivity(intent)
        } catch (e: Exception) {
            android.widget.Toast.makeText(
                this,
                "Cannot open URL: ${e.message}",
                android.widget.Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun shareRecipe(title: String, text: String) {
        try {
            val shareIntent = Intent().apply {
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_SUBJECT, title)
                putExtra(Intent.EXTRA_TEXT, text)
                type = "text/plain"
            }
            startActivity(Intent.createChooser(shareIntent, "Share recipe via"))
        } catch (e: Exception) {
            android.widget.Toast.makeText(
                this,
                "Cannot share: ${e.message}",
                android.widget.Toast.LENGTH_SHORT
            ).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Additional native Android initialization can be added here
        // For example: analytics, crash reporting, etc.
    }

    override fun onResume() {
        super.onResume()
        // Handle when app comes to foreground
    }

    override fun onPause() {
        super.onPause()
        // Handle when app goes to background
    }
}
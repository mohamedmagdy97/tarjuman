package com.megtech.tarjuman

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/**
 * Receives videos/audio opened with or shared to the app ("Open with" / "Share"),
 * copies the content:// stream into the app cache and hands the path to Dart.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pending: Map<String, String>? = null
    private var dartReady = false
    private val io = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        ch.setMethodCallHandler { call, result ->
            if (call.method == "getInitial") {
                dartReady = true
                result.success(pending)
                pending = null
            } else {
                result.notImplemented()
            }
        }
        channel = ch
        handle(intent, initial = true)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handle(intent, initial = false)
    }

    private fun streamUri(i: Intent): Uri? = when (i.action) {
        Intent.ACTION_VIEW -> i.data
        Intent.ACTION_SEND ->
            if (Build.VERSION.SDK_INT >= 33) {
                i.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                i.getParcelableExtra(Intent.EXTRA_STREAM)
            }
        else -> null
    }

    private fun handle(i: Intent?, initial: Boolean) {
        val uri = i?.let(::streamUri) ?: return
        // Consume it so a recreated activity doesn't import the same file twice.
        setIntent(Intent(Intent.ACTION_MAIN))
        io.execute {
            val copied = copyToCache(uri) ?: return@execute
            runOnUiThread {
                if (initial && !dartReady) {
                    pending = copied
                } else {
                    channel?.invokeMethod("onIncoming", copied)
                }
            }
        }
    }

    private fun displayName(uri: Uri): String {
        contentResolver.query(uri, null, null, null, null)?.use { c ->
            val idx = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (idx >= 0 && c.moveToFirst()) return c.getString(idx)
        }
        return uri.lastPathSegment?.substringAfterLast('/') ?: "video"
    }

    private fun copyToCache(uri: Uri): Map<String, String>? {
        return try {
            val name = displayName(uri)
            val dir = File(cacheDir, "incoming").apply { mkdirs() }
            val out = File(dir, "${System.currentTimeMillis()}_${name.replace('/', '_')}")
            val input = contentResolver.openInputStream(uri) ?: return null
            input.use { src -> out.outputStream().use { src.copyTo(it) } }
            mapOf("path" to out.absolutePath, "name" to name)
        } catch (e: Exception) {
            null
        }
    }

    companion object {
        private const val CHANNEL = "com.megtech.tarjuman/incoming"
    }
}

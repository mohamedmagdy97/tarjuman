package com.megtech.tarjuman

import android.content.Intent
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EXPORT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "save") {
                    val path = call.argument<String>("path")
                    val name = call.argument<String>("name")
                    val mime = call.argument<String>("mime") ?: "video/mp4"
                    if (path == null || name == null) {
                        result.success(false)
                    } else {
                        io.execute {
                            val ok = saveToGallery(File(path), name, mime)
                            runOnUiThread { result.success(ok) }
                        }
                    }
                } else {
                    result.notImplemented()
                }
            }
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

    /** Text shared from another app (YouTube/Facebook "Share" -> link). */
    private fun sharedText(i: Intent): String? =
        if (i.action == Intent.ACTION_SEND && i.type?.startsWith("text/") == true) {
            i.getStringExtra(Intent.EXTRA_TEXT)
        } else {
            null
        }

    private fun deliver(map: Map<String, String>, initial: Boolean) {
        if (initial && !dartReady) {
            pending = map
        } else {
            channel?.invokeMethod("onIncoming", map)
        }
    }

    /**
     * Copies [file] into the public Movies/Music folder through MediaStore.
     * Android 10+ needs no permission; older versions return false so Dart
     * falls back to the share sheet.
     */
    private fun saveToGallery(file: File, name: String, mime: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || !file.exists()) return false
        return try {
            val audio = mime.startsWith("audio/")
            val collection = if (audio) {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            }
            val folder = if (audio) Environment.DIRECTORY_MUSIC else Environment.DIRECTORY_MOVIES
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, mime)
                put(MediaStore.MediaColumns.RELATIVE_PATH, "$folder/Tarjuman")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = contentResolver.insert(collection, values) ?: return false
            contentResolver.openOutputStream(uri)?.use { out ->
                file.inputStream().use { it.copyTo(out) }
            } ?: return false
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun handle(i: Intent?, initial: Boolean) {
        sharedText(i ?: return)?.let { text ->
            setIntent(Intent(Intent.ACTION_MAIN))
            deliver(mapOf("url" to text), initial)
            return
        }
        val uri = i.let(::streamUri) ?: return
        // Consume it so a recreated activity doesn't import the same file twice.
        setIntent(Intent(Intent.ACTION_MAIN))
        io.execute {
            val copied = copyToCache(uri) ?: return@execute
            runOnUiThread { deliver(copied, initial) }
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
        private const val EXPORT_CHANNEL = "com.megtech.tarjuman/export"
    }
}

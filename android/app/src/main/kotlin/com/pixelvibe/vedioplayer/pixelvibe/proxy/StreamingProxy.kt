package com.pixelvibe.vedioplayer.pixelvibe.proxy

import android.util.Log
import fi.iki.elonen.NanoHTTPD
import kotlinx.coroutines.runBlocking

class StreamingProxy(private val port: Int = 8765) : NanoHTTPD(port) {

    companion object {
        const val TAG = "StreamingProxy"
        private var currentClient: com.pixelvibe.vedioplayer.pixelvibe.network.NetworkClient? = null
        private var currentPath: String? = null
    }

    fun setStreamSource(client: com.pixelvibe.vedioplayer.pixelvibe.network.NetworkClient, path: String) {
        currentClient?.let { runBlocking { it.disconnect() } }
        currentClient = client
        currentPath = path
    }

    override fun serve(session: IHTTPSession): Response {
        return try {
            val client = currentClient
            val path = currentPath
            if (client == null || path == null) {
                return newFixedLengthResponse(
                    Response.Status.NOT_FOUND, "text/plain", "No stream available"
                )
            }

            val inputStream = runBlocking { client.getInputStream(path) }
            val mimeType = guessMimeType(path)

            newChunkedResponse(Response.Status.OK, mimeType, inputStream)
        } catch (e: Exception) {
            Log.e(TAG, "Proxy error", e)
            newFixedLengthResponse(
                Response.Status.INTERNAL_ERROR, "text/plain", e.message ?: "Proxy error"
            )
        }
    }

    fun startProxy(): Boolean {
        try {
            if (!isAlive) {
                start()
                Log.d(TAG, "Proxy started on port $port")
            }
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start proxy", e)
            return false
        }
    }

    fun stopProxy() {
        if (isAlive) {
            stop()
            Log.d(TAG, "Proxy stopped")
        }
    }

    private fun guessMimeType(path: String): String {
        val ext = path.substringAfterLast('.', "").lowercase()
        return when (ext) {
            "mp4" -> "video/mp4"
            "mkv" -> "video/x-matroska"
            "avi" -> "video/x-msvideo"
            "mov" -> "video/quicktime"
            "wmv" -> "video/x-ms-wmv"
            "webm" -> "video/webm"
            "m4v" -> "video/x-m4v"
            "flv" -> "video/x-flv"
            "mp3" -> "audio/mpeg"
            "aac" -> "audio/aac"
            "flac" -> "audio/flac"
            "ogg" -> "audio/ogg"
            "wav" -> "audio/wav"
            else -> "application/octet-stream"
        }
    }

    fun getProxyUrl(path: String): String {
        return "http://127.0.0.1:$port/$path"
    }
}

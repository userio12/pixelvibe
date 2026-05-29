package com.pixelvibe.app.proxy

import android.util.Log
import com.pixelvibe.app.network.NetworkClient
import fi.iki.elonen.NanoHTTPD
import kotlinx.coroutines.runBlocking

class StreamingProxy(private val port: Int = 8765) : NanoHTTPD(port) {

    companion object {
        const val TAG = "StreamingProxy"
    }

    private data class StreamSource(val client: NetworkClient, val path: String)
    private data class CacheKey(val path: String, val offset: Long)
    private val bufferCache = lruCache<CacheKey, ByteArray>(20) // Cache last 20 small reads

    @Volatile
    private var streamSource: StreamSource? = null

    private fun <K, V> lruCache(maxSize: Int): MutableMap<K, V> {
        return object : java.util.LinkedHashMap<K, V>(maxSize, 0.75f, true) {
            override fun removeEldestEntry(eldest: MutableMap.MutableEntry<K, V>?): Boolean {
                return size > maxSize
            }
        }
    }

    fun setStreamSource(client: NetworkClient, path: String) {
        streamSource?.let { runBlocking { it.client.disconnect() } }
        streamSource = StreamSource(client, path)
        synchronized(bufferCache) { bufferCache.clear() }
    }

    override fun serve(session: IHTTPSession): Response {
        return try {
            val source = streamSource
            if (source == null) {
                return newFixedLengthResponse(
                    Response.Status.NOT_FOUND, "text/plain", "No stream available"
                )
            }

            val mimeType = guessMimeType(source.path)
            val rangeHeader = session.headers["range"]

            if (rangeHeader != null && rangeHeader.startsWith("bytes=")) {
                val parts = rangeHeader.substring(6).split("-")
                val start = parts[0].toLongOrNull() ?: 0L
                val fileLength = runBlocking { source.client.getFileSize(source.path) }
                val end = if (parts.size > 1 && parts[1].isNotEmpty()) parts[1].toLong() else fileLength - 1
                val contentLength = end - start + 1

                // Small read optimization: check cache
                if (contentLength in 1..65536) {
                    val key = CacheKey(source.path, start)
                    val cached = synchronized(bufferCache) { bufferCache[key] }
                    if (cached != null && cached.size.toLong() == contentLength) {
                        return newFixedLengthResponse(Response.Status.PARTIAL_CONTENT, mimeType, java.io.ByteArrayInputStream(cached), contentLength).apply {
                            addHeader("Content-Range", "bytes $start-$end/$fileLength")
                            addHeader("Accept-Ranges", "bytes")
                        }
                    }
                }
                
                var inputStream: java.io.InputStream? = null
                var lastError: Exception? = null
                for (retry in 0..2) {
                    try {
                        inputStream = runBlocking { source.client.getInputStream(source.path, start) }
                        break
                    } catch (e: Exception) {
                        lastError = e
                        Thread.sleep(1000L * (retry + 1))
                    }
                }
                if (inputStream == null) throw lastError ?: Exception("Failed to open stream after retries")

                // If small read, buffer it
                val finalStream = if (contentLength in 1..65536) {
                    val buffer = inputStream.readBytes()
                    synchronized(bufferCache) { bufferCache[CacheKey(source.path, start)] = buffer }
                    java.io.ByteArrayInputStream(buffer)
                } else {
                    inputStream
                }
                
                val res = newFixedLengthResponse(Response.Status.PARTIAL_CONTENT, mimeType, finalStream, contentLength)
                res.addHeader("Content-Range", "bytes $start-$end/$fileLength")
                res.addHeader("Accept-Ranges", "bytes")
                res
            } else {
                var inputStream: java.io.InputStream? = null
                var lastError: Exception? = null
                for (retry in 0..2) {
                    try {
                        inputStream = runBlocking { source.client.getInputStream(source.path) }
                        break
                    } catch (e: Exception) {
                        lastError = e
                        Thread.sleep(1000L * (retry + 1))
                    }
                }
                if (inputStream == null) throw lastError ?: Exception("Failed to open stream after retries")

                val fileLength = runBlocking { source.client.getFileSize(source.path) }
                val res = newFixedLengthResponse(Response.Status.OK, mimeType, inputStream, fileLength)
                res.addHeader("Accept-Ranges", "bytes")
                res
            }
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

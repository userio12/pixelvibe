package com.pixelvibe.app.scan

import android.content.Context
import android.net.Uri
import android.provider.MediaStore
import android.util.Log

class MediaScanner(private val context: Context) {

    fun scanVideos(offset: Int, limit: Int): List<Map<String, Any?>> {
        val videos = mutableListOf<Map<String, Any?>>()
        val baseUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.TITLE,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.WIDTH,
            MediaStore.Video.Media.HEIGHT,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.DATE_MODIFIED,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.DISPLAY_NAME,
        )
        val sortOrder = "${MediaStore.Video.Media.DATE_MODIFIED} DESC"
        val cursor = context.contentResolver.query(baseUri, projection, null, null, sortOrder)
        cursor?.use {
            if (offset > 0 && !it.moveToPosition(offset - 1)) return videos

            val idIdx = it.getColumnIndex(MediaStore.Video.Media._ID)
            val titleIdx = it.getColumnIndex(MediaStore.Video.Media.TITLE)
            val durIdx = it.getColumnIndex(MediaStore.Video.Media.DURATION)
            val widthIdx = it.getColumnIndex(MediaStore.Video.Media.WIDTH)
            val heightIdx = it.getColumnIndex(MediaStore.Video.Media.HEIGHT)
            val sizeIdx = it.getColumnIndex(MediaStore.Video.Media.SIZE)
            val dateIdx = it.getColumnIndex(MediaStore.Video.Media.DATE_MODIFIED)
            val dataIdx = it.getColumnIndex(MediaStore.Video.Media.DATA)
            val displayNameIdx = it.getColumnIndex(MediaStore.Video.Media.DISPLAY_NAME)
            if (idIdx < 0) return videos

            var count = 0
            while (it.moveToNext() && count < limit) {
                count++
                try {
                    val id = it.getLong(idIdx)
                    val contentUri = Uri.withAppendedPath(baseUri, id.toString())
                    var filePath = if (dataIdx >= 0) it.getString(dataIdx) ?: "" else ""
                    val displayName = if (displayNameIdx >= 0) it.getString(displayNameIdx) ?: "" else ""
                    
                    if (filePath.isEmpty()) {
                        filePath = contentUri.toString()
                    }

                    val video = mapOf(
                        "path" to contentUri.toString(),
                        "filePath" to filePath,
                        "displayName" to displayName,
                        "title" to if (titleIdx >= 0) it.getString(titleIdx) ?: "" else "",
                        "durationMs" to if (durIdx >= 0) it.getInt(durIdx) else 0,
                        "width" to if (widthIdx >= 0) it.getInt(widthIdx) else 0,
                        "height" to if (heightIdx >= 0) it.getInt(heightIdx) else 0,
                        "size" to if (sizeIdx >= 0) it.getLong(sizeIdx) else 0L,
                        "lastModified" to if (dateIdx >= 0) it.getLong(dateIdx) * 1000L else 0L
                    )
                    videos.add(video)
                } catch (e: Exception) {
                    Log.e("MediaScanner", "Error scanning video", e)
                }
            }
        }
        return videos
    }
}

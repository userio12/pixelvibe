package com.pixelvibe.app.scan

import android.content.Context
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

class MediaScanner(private val context: Context) {

    fun scanVideos(): String {
        val videos = JSONArray()
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
        val cursor = context.contentResolver.query(baseUri, projection, null, null, null)
        cursor?.use {
            val idIdx = it.getColumnIndex(MediaStore.Video.Media._ID)
            val titleIdx = it.getColumnIndex(MediaStore.Video.Media.TITLE)
            val durIdx = it.getColumnIndex(MediaStore.Video.Media.DURATION)
            val widthIdx = it.getColumnIndex(MediaStore.Video.Media.WIDTH)
            val heightIdx = it.getColumnIndex(MediaStore.Video.Media.HEIGHT)
            val sizeIdx = it.getColumnIndex(MediaStore.Video.Media.SIZE)
            val dateIdx = it.getColumnIndex(MediaStore.Video.Media.DATE_MODIFIED)
            val dataIdx = it.getColumnIndex(MediaStore.Video.Media.DATA)
            val displayNameIdx = it.getColumnIndex(MediaStore.Video.Media.DISPLAY_NAME)
            if (idIdx < 0) return videos.toString()

            while (it.moveToNext()) {
                try {
                    val id = it.getLong(idIdx)
                    val contentUri = Uri.withAppendedPath(baseUri, id.toString())
                    val filePath = if (dataIdx >= 0) it.getString(dataIdx) ?: "" else ""
                    val displayName = if (displayNameIdx >= 0) it.getString(displayNameIdx) ?: "" else ""
                    val video = JSONObject().apply {
                        put("path", contentUri.toString())
                        put("filePath", filePath)
                        put("displayName", displayName)
                        put("title", if (titleIdx >= 0) it.getString(titleIdx) ?: "" else "")
                        put("durationMs", if (durIdx >= 0) it.getInt(durIdx) else 0)
                        put("width", if (widthIdx >= 0) it.getInt(widthIdx) else 0)
                        put("height", if (heightIdx >= 0) it.getInt(heightIdx) else 0)
                        put("size", if (sizeIdx >= 0) it.getLong(sizeIdx) else 0L)
                        put("lastModified", if (dateIdx >= 0) it.getLong(dateIdx) * 1000L else 0L)
                    }
                    videos.put(video)
                } catch (e: Exception) {
                    Log.e("MediaScanner", "Error scanning video", e)
                }
            }
        }
        return videos.toString()
    }
}

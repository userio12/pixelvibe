package com.pixelvibe.app.scan

import android.content.Context
import android.provider.MediaStore
import org.json.JSONArray
import org.json.JSONObject

class MediaScanner(private val context: Context) {

    fun scanVideos(): String {
        val videos = JSONArray()
        val uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.TITLE,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.WIDTH,
            MediaStore.Video.Media.HEIGHT,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.DATE_MODIFIED,
        )
        val cursor = context.contentResolver.query(uri, projection, null, null, null)
        cursor?.use {
            val dataIdx = it.getColumnIndex(MediaStore.Video.Media.DATA)
            val titleIdx = it.getColumnIndex(MediaStore.Video.Media.TITLE)
            val durIdx = it.getColumnIndex(MediaStore.Video.Media.DURATION)
            val widthIdx = it.getColumnIndex(MediaStore.Video.Media.WIDTH)
            val heightIdx = it.getColumnIndex(MediaStore.Video.Media.HEIGHT)
            val sizeIdx = it.getColumnIndex(MediaStore.Video.Media.SIZE)
            val dateIdx = it.getColumnIndex(MediaStore.Video.Media.DATE_MODIFIED)
            if (dataIdx < 0) return videos.toString()

            while (it.moveToNext()) {
                try {
                    val path = it.getString(dataIdx) ?: continue
                    val video = JSONObject().apply {
                        put("path", path)
                        put("title", if (titleIdx >= 0) it.getString(titleIdx) ?: "" else "")
                        put("durationMs", if (durIdx >= 0) it.getInt(durIdx) else 0)
                        put("width", if (widthIdx >= 0) it.getInt(widthIdx) else 0)
                        put("height", if (heightIdx >= 0) it.getInt(heightIdx) else 0)
                        put("size", if (sizeIdx >= 0) it.getLong(sizeIdx) else 0L)
                        put("lastModified", if (dateIdx >= 0) it.getLong(dateIdx) * 1000L else 0L)
                    }
                    videos.put(video)
                } catch (_: Exception) { }
            }
        }
        return videos.toString()
    }
}

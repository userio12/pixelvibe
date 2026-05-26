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
            while (it.moveToNext()) {
                val path = it.getString(it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)) ?: continue
                val video = JSONObject().apply {
                    put("path", path)
                    put("title", it.getString(it.getColumnIndexOrThrow(MediaStore.Video.Media.TITLE)) ?: "")
                    put("durationMs", it.getInt(it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)))
                    put("width", it.getInt(it.getColumnIndexOrThrow(MediaStore.Video.Media.WIDTH)))
                    put("height", it.getInt(it.getColumnIndexOrThrow(MediaStore.Video.Media.HEIGHT)))
                    put("size", it.getLong(it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)))
                    put("lastModified", it.getLong(it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED)) * 1000L)
                }
                videos.put(video)
            }
        }
        return videos.toString()
    }
}

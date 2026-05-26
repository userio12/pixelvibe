package com.pixelvibe.app.scan

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import java.io.File
import java.io.FileOutputStream

class ThumbnailHelper(private val context: Context) {

    fun getThumbnail(path: String, width: Int = 320): String? {
        return try {
            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(path)
            val bitmap = retriever.frameAtTime ?: return null
            val scaled = Bitmap.createScaledBitmap(bitmap, width, (bitmap.height * width / bitmap.width).coerceAtLeast(1), true)
            val cacheDir = File(context.cacheDir, "thumbnails")
            cacheDir.mkdirs()
            val file = File(cacheDir, "${path.hashCode()}.jpg")
            FileOutputStream(file).use { out ->
                scaled.compress(Bitmap.CompressFormat.JPEG, 80, out)
            }
            retriever.release()
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }
}

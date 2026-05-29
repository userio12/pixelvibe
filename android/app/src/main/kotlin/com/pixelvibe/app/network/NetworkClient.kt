package com.pixelvibe.app.network

import java.io.InputStream

interface NetworkClient {
    suspend fun listFiles(path: String): List<NetworkFile>
    suspend fun getInputStream(path: String, offset: Long = 0L): InputStream
    suspend fun getFileSize(path: String): Long
    suspend fun disconnect()
}

data class NetworkFile(
    val name: String,
    val path: String,
    val isDirectory: Boolean,
    val size: Long,
    val lastModified: Long
)
package com.pixelvibe.app.network

data class NetworkFile(
    val name: String,
    val path: String,
    val isDirectory: Boolean,
    val size: Long = 0,
    val lastModified: Long = 0
)

interface NetworkClient {
    suspend fun listFiles(path: String): List<NetworkFile>
    suspend fun getInputStream(path: String): java.io.InputStream
    suspend fun disconnect()
}

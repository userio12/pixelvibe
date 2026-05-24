package com.pixelvibe.vedioplayer.pixelvibe.network

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.InputStream

class SMBClient(
    private val host: String,
    private val port: Int,
    private val username: String,
    private val password: String
) : NetworkClient {

    override suspend fun listFiles(path: String): List<NetworkFile> = withContext(Dispatchers.IO) {
        emptyList()
    }

    override suspend fun getInputStream(path: String): InputStream = withContext(Dispatchers.IO) {
        throw UnsupportedOperationException("SMB not yet implemented")
    }

    override suspend fun disconnect() = withContext(Dispatchers.IO) {}
}

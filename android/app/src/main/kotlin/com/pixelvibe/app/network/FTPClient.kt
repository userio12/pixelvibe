package com.pixelvibe.app.network

import org.apache.commons.net.ftp.FTPClient as ApacheFTPClient
import org.apache.commons.net.ftp.FTPFile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class FTPClient(
    private val host: String,
    private val port: Int,
    private val username: String,
    private val password: String
) : NetworkClient {

    private var client: ApacheFTPClient? = null

    private fun getClient(): ApacheFTPClient {
        val existing = client
        if (existing == null || !existing.isConnected) {
            val newClient = ApacheFTPClient()
            newClient.connect(host, port)
            newClient.login(username, password)
            newClient.enterLocalPassiveMode()
            client = newClient
            return newClient
        }
        return existing
    }

    override suspend fun listFiles(path: String): List<NetworkFile> = withContext(Dispatchers.IO) {
        val ftp = getClient()
        ftp.changeWorkingDirectory(path)
        (ftp.listFiles() ?: emptyArray()).map { file: FTPFile ->
            NetworkFile(
                name = file.name,
                path = "$path/${file.name}",
                isDirectory = file.isDirectory,
                size = file.size,
                lastModified = file.timestamp?.timeInMillis ?: 0
            )
        }
    }

    override suspend fun getInputStream(path: String): java.io.InputStream = withContext(Dispatchers.IO) {
        val ftp = getClient()
        val stream = ftp.retrieveFileStream(path) ?: throw Exception("Failed to retrieve file: $path")
        object : java.io.FilterInputStream(stream) {
            override fun close() {
                try { super.close() } finally { ftp.completePendingCommand() }
            }
        }
    }

    override suspend fun disconnect() = withContext(Dispatchers.IO) {
        client?.let {
            if (it.isConnected) {
                it.logout()
                it.disconnect()
            }
        }
        client = null
    }
}

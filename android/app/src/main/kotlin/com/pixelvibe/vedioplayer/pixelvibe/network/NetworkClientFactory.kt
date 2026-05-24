package com.pixelvibe.vedioplayer.pixelvibe.network

sealed class NetworkResult {
    data class Success(val files: List<NetworkFile>) : NetworkResult()
    data class Error(val message: String) : NetworkResult()
}

object NetworkClientFactory {
    fun create(
        protocol: String,
        host: String,
        port: Int,
        username: String,
        password: String
    ): NetworkClient {
        return when (protocol.lowercase()) {
            "smb" -> SMBClient(host, port, username, password)
            "ftp" -> FTPClient(host, port, username, password)
            "webdav", "dav" -> WebDAVClient(host, port, username, password)
            else -> throw IllegalArgumentException("Unsupported protocol: $protocol")
        }
    }
}

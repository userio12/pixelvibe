package com.pixelvibe.vedioplayer.pixelvibe.network

object NetworkClientFactory {
    fun create(
        protocol: String,
        host: String,
        port: Int,
        username: String,
        password: String
    ): NetworkClient {
        return when (protocol.lowercase()) {
            "smb" -> SmbClient(host, port, username, password)
            "ftp" -> FTPClient(host, port, username, password)
            "webdav", "dav" -> WebDAVClient(host, port, username, password)
            else -> throw IllegalArgumentException("Unsupported protocol: $protocol")
        }
    }
}

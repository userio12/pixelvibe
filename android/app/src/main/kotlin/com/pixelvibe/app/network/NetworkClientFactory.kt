package com.pixelvibe.app.network

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
            "webdav", "dav" -> WebDAVClient(host, port, username, password, useTls = false)
            "webdavs", "davs" -> WebDAVClient(host, port, username, password, useTls = true)
            else -> throw IllegalArgumentException("Unsupported protocol: $protocol")
        }
    }
}

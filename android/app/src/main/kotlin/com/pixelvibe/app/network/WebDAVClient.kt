package com.pixelvibe.app.network

import java.net.HttpURLConnection
import java.net.URL
import java.util.Base64
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class WebDAVClient(
    private val host: String,
    private val port: Int,
    private val username: String,
    private val password: String
) : NetworkClient {

    private val baseUrl: String = "http://$host:$port"

    private fun createConnection(path: String): HttpURLConnection {
        val url = URL("$baseUrl${path.removePrefix("/")}")
        val conn = url.openConnection() as HttpURLConnection
        val authStr = "$username:$password"
        val encoded = Base64.getEncoder().encodeToString(authStr.toByteArray())
        conn.setRequestProperty("Authorization", "Basic $encoded")
        conn.connectTimeout = 10000
        conn.readTimeout = 30000
        return conn
    }

    override suspend fun listFiles(path: String): List<NetworkFile> = withContext(Dispatchers.IO) {
        val conn = createConnection(path)
        conn.requestMethod = "PROPFIND"
        conn.setRequestProperty("Depth", "1")
        conn.setRequestProperty("Content-Type", "application/xml")

        val body = """<?xml version="1.0" encoding="utf-8"?>
<d:propfind xmlns:d="DAV:">
  <d:prop>
    <d:resourcetype/>
    <d:getcontentlength/>
    <d:getlastmodified/>
    <d:displayname/>
  </d:prop>
</d:propfind>""".trimIndent()

        conn.doOutput = true
        conn.outputStream.write(body.toByteArray())

        val responseCode = conn.responseCode
        if (responseCode != 207 && responseCode != 200) {
            throw Exception("WebDAV list failed: $responseCode")
        }

        val responseXml = conn.inputStream.bufferedReader().readText()
        parsePropfindResponse(responseXml)
    }

    private fun parsePropfindResponse(xml: String): List<NetworkFile> {
        val files = mutableListOf<NetworkFile>()
        val responses = xml.split("<d:response>", "</d:response>")
            .filter { it.contains("<d:href>") }

        for (response in responses) {
            try {
                val href = response.substringAfter("<d:href>").substringBefore("</d:href>")
                val name = response.substringAfter("<d:displayname>").substringBefore("</d:displayname>")
                val isCollection = response.contains("<d:collection/>") || response.contains("<d:collection ")
                val sizeStr = response.substringAfter("<d:getcontentlength>").substringBefore("</d:getcontentlength>")

                if (name.isNotEmpty()) {
                    files.add(NetworkFile(
                        name = name,
                        path = href,
                        isDirectory = isCollection,
                        size = sizeStr.toLongOrNull() ?: 0
                    ))
                }
            } catch (_: Exception) { }
        }
        return files
    }

    override suspend fun getInputStream(path: String): java.io.InputStream = withContext(Dispatchers.IO) {
        val conn = createConnection(path)
        conn.requestMethod = "GET"
        conn.inputStream
    }

    override suspend fun disconnect() {
    }
}

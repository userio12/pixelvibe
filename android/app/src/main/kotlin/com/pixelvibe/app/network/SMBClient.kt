package com.pixelvibe.app.network

import com.hierynomus.msdtyp.AccessMask
import com.hierynomus.msfscc.FileAttributes
import com.hierynomus.mssmb2.SMB2CreateDisposition
import com.hierynomus.mssmb2.SMB2ShareAccess
import android.util.Log
import com.hierynomus.smbj.SMBClient
import com.hierynomus.smbj.auth.AuthenticationContext
import com.hierynomus.smbj.share.DiskShare
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.InputStream
import java.util.EnumSet

class SmbClient(
    private val host: String,
    private val port: Int,
    private val username: String,
    private val password: String
) : NetworkClient {

    private var client: SMBClient? = null
    private var session: com.hierynomus.smbj.session.Session? = null

    companion object {
        private const val FILE_ATTRIBUTE_DIRECTORY = 0x10000000L
    }

    private fun getSession(): com.hierynomus.smbj.session.Session {
        val s = session
        if (s != null) return s
        val c = SMBClient()
        val connection = c.connect(host, port.takeIf { it > 0 } ?: 445)
        val auth = AuthenticationContext(username, password.toCharArray(), null)
        val sess = connection.authenticate(auth)
        client = c
        session = sess
        return sess
    }

    override suspend fun listFiles(path: String): List<NetworkFile> = withContext(Dispatchers.IO) {
        val sess = getSession()
        val cleanPath = path.removePrefix("/").removeSuffix("/")
        if (cleanPath.isEmpty()) return@withContext emptyList()

        val parts = cleanPath.split("/", limit = 2)
        val shareName = parts[0]
        val subPath = if (parts.size > 1) parts[1] else ""
        val share = sess.connectShare(shareName) as DiskShare
        val files = share.list(subPath, "*")
        files.map { f ->
            val attrs = f.fileAttributes
            NetworkFile(
                name = f.fileName,
                path = "/$shareName/${f.fileName}",
                isDirectory = (attrs and FILE_ATTRIBUTE_DIRECTORY) != 0L,
                size = f.endOfFile,
                lastModified = f.lastWriteTime?.toInstant()?.toEpochMilli() ?: 0,
            )
        }
    }

    override suspend fun getInputStream(path: String): InputStream = withContext(Dispatchers.IO) {
        val sess = getSession()
        val cleanPath = path.removePrefix("/")
        val parts = cleanPath.split("/", limit = 2)
        if (parts.size < 2) throw IllegalArgumentException("Invalid SMB path: $path")
        val shareName = parts[0]
        val filePath = parts[1]
        val share = sess.connectShare(shareName) as DiskShare
        val smbFile = share.openFile(
            filePath,
            EnumSet.of(AccessMask.GENERIC_READ),
            EnumSet.of(FileAttributes.FILE_ATTRIBUTE_NORMAL),
            EnumSet.of(SMB2ShareAccess.FILE_SHARE_READ),
            SMB2CreateDisposition.FILE_OPEN,
            emptySet(),
        )
        smbFile.inputStream
    }

    override suspend fun disconnect() = withContext(Dispatchers.IO) {
        try { client?.close() } catch (e: Exception) { Log.e("SMBClient", "Disconnect error", e) }
        client = null
        session = null
    }
}

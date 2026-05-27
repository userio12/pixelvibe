package com.pixelvibe.app

import android.util.Log
import com.pixelvibe.app.network.NetworkClientFactory
import com.pixelvibe.app.proxy.StreamingProxy
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

class PixelvibePlugin(private val channel: MethodChannel) {

    companion object {
        const val TAG = "PixelvibePlugin"
    }

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val proxy = StreamingProxy()
    private val activeClients = mutableMapOf<String, com.pixelvibe.app.network.NetworkClient>()

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> connect(call, result)
            "listFiles" -> listFiles(call, result)
            "streamFile" -> streamFile(call, result)
            "disconnect" -> disconnect(call, result)
            else -> result.notImplemented()
        }
    }

    private fun arg(call: MethodCall, key: String): Any? = call.argument(key)

    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        val id = arg(call, "id") as? String ?: return result.error("INVALID", "Missing id", null)
        val protocol = arg(call, "protocol") as? String ?: ""
        val host = arg(call, "host") as? String ?: ""
        val port = (arg(call, "port") as? Int) ?: 0
        val username = arg(call, "username") as? String ?: ""
        val password = arg(call, "password") as? String ?: ""

        scope.launch {
            try {
                val client = NetworkClientFactory.create(protocol, host, port, username, password)
                activeClients[id] = client
                result.success(true)
            } catch (e: Exception) {
                Log.e(TAG, "Connect failed", e)
                result.error("CONNECT_FAILED", e.message ?: "Connection failed", null)
            }
        }
    }

    private fun listFiles(call: MethodCall, result: MethodChannel.Result) {
        val id = arg(call, "id") as? String ?: return result.error("INVALID", "Missing id", null)
        val path = arg(call, "path") as? String ?: "/"
        val client = activeClients[id] ?: return result.error("NOT_CONNECTED", "Not connected", null)

        scope.launch {
            try {
                val files = client.listFiles(path)
                val jsonArray = JSONArray()
                files.forEach { file ->
                    jsonArray.put(JSONObject().apply {
                        put("name", file.name)
                        put("path", file.path)
                        put("isDirectory", file.isDirectory)
                        put("size", file.size)
                        put("lastModified", file.lastModified)
                    })
                }
                result.success(jsonArray.toString())
            } catch (e: Exception) {
                Log.e(TAG, "List failed", e)
                result.error("LIST_FAILED", e.message ?: "List failed", null)
            }
        }
    }

    private fun streamFile(call: MethodCall, result: MethodChannel.Result) {
        val id = arg(call, "id") as? String ?: return result.error("INVALID", "Missing id", null)
        val path = arg(call, "path") as? String ?: return result.error("INVALID", "Missing path", null)
        val client = activeClients[id] ?: return result.error("NOT_CONNECTED", "Not connected", null)

        scope.launch {
            try {
                proxy.setStreamSource(client, path)
                proxy.startProxy()
                val proxyUrl = proxy.getProxyUrl(path)
                result.success(proxyUrl)
            } catch (e: Exception) {
                Log.e(TAG, "Stream failed", e)
                result.error("STREAM_FAILED", e.message ?: "Stream failed", null)
            }
        }
    }

    private fun disconnect(call: MethodCall, result: MethodChannel.Result) {
        val id = arg(call, "id") as? String ?: return result.error("INVALID", "Missing id", null)
        val client = activeClients.remove(id) ?: return result.error("NOT_CONNECTED", "Not connected", null)

        scope.launch {
            try {
                client.disconnect()
                if (activeClients.isEmpty()) proxy.stopProxy()
                result.success(true)
            } catch (e: Exception) {
                Log.e(TAG, "Disconnect failed", e)
                result.error("DISCONNECT_FAILED", e.message ?: "Disconnect failed", null)
            }
        }
    }

    fun disconnectAll() {
        scope.launch {
            activeClients.values.forEach { it.disconnect() }
            activeClients.clear()
            proxy.stopProxy()
        }
    }

    fun cancel() {
        scope.cancel()
        proxy.stopProxy()
    }

}

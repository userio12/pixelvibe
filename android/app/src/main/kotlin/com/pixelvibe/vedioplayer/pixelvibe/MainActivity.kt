package com.pixelvibe.vedioplayer.pixelvibe

import android.content.Intent
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.pixelvibe.vedioplayer.pixelvibe.background.PlaybackService
import com.pixelvibe.vedioplayer.pixelvibe.mediasession.MediaSessionCallback
import com.pixelvibe.vedioplayer.pixelvibe.pip.PiPHelper

class MainActivity : FlutterActivity() {
    private val pipChannel = "com.pixelvibe/pip"
    private val backgroundChannel = "com.pixelvibe/background"

    private var pipHelper: PiPHelper? = null
    private var mediaSessionCallback: MediaSessionCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pipHelper = PiPHelper(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannel).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "enterPip" -> {
                        val w = (call.argument("width") as? Int) ?: 16
                        val h = (call.argument("height") as? Int) ?: 9
                        pipHelper?.enterPip(Rational(w, h))
                        result.success(true)
                    }
                    "isPipSupported" -> {
                        result.success(pipHelper?.isPipSupported() ?: false)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        mediaSessionCallback = MediaSessionCallback(this, MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, backgroundChannel
        ))

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, backgroundChannel).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        val title = (call.argument("title") as? String) ?: "pixelvibe"
                        val content = (call.argument("content") as? String) ?: "Playing"
                        startForegroundService(title, content)
                        result.success(true)
                    }
                    "stopService" -> {
                        stopForegroundService()
                        result.success(true)
                    }
                    "updateMetadata" -> {
                        val title = (call.argument("title") as? String) ?: ""
                        val duration = (call.argument("duration") as? Long) ?: 0L
                        mediaSessionCallback?.updateMetadata(title, duration)
                        result.success(true)
                    }
                    "updatePlaybackState" -> {
                        val playing = (call.argument("playing") as? Boolean) ?: false
                        val position = (call.argument("position") as? Long) ?: 0L
                        mediaSessionCallback?.updatePlaybackState(playing, position)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        val networkChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.pixelvibe/network")
        val networkPlugin = PixelvibePlugin(networkChannel)
        networkChannel.setMethodCallHandler { call, result ->
            networkPlugin.handle(call, result)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        pipHelper?.enterPip(Rational(16, 9))
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        MethodChannel(
            flutterEngine?.dartExecutor?.binaryMessenger ?: return,
            pipChannel
        ).invokeMethod("onPictureInPictureModeChanged", mapOf("isInPip" to isInPictureInPictureMode))
    }

    override fun onDestroy() {
        mediaSessionCallback?.release()
        super.onDestroy()
    }

    private fun startForegroundService(title: String, content: String) {
        val intent = Intent(this, PlaybackService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        // Update notification content after service is running
        val updateIntent = Intent(this, PlaybackService::class.java).apply {
            putExtra("title", title)
            putExtra("content", content)
            action = "UPDATE"
        }
        startService(updateIntent)
    }

    private fun stopForegroundService() {
        stopService(Intent(this, PlaybackService::class.java))
    }
}

package com.pixelvibe.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.pixelvibe.app.background.PlaybackService
import com.pixelvibe.app.mediasession.MediaSessionCallback
import com.pixelvibe.app.pip.PiPHelper
import com.pixelvibe.app.scan.MediaScanner
import com.pixelvibe.app.scan.ThumbnailHelper

class MainActivity : FlutterActivity() {
    private val pipChannel = "com.pixelvibe/pip"
    private val backgroundChannel = "com.pixelvibe/background"

    private var pipHelper: PiPHelper? = null
    private var mediaSessionCallback: MediaSessionCallback? = null
    private var pipMethodChannel: MethodChannel? = null
    private val pipActionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == PlaybackService.ACTION_TOGGLE) {
                pipMethodChannel?.invokeMethod("togglePlayback", null)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pipHelper = PiPHelper(this)

        registerReceiver(pipActionReceiver, IntentFilter(PlaybackService.ACTION_TOGGLE), Context.RECEIVER_NOT_EXPORTED)

        pipMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannel).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "enterPip" -> {
                        val w = (call.argument("width") as? Int) ?: 16
                        val h = (call.argument("height") as? Int) ?: 9
                        val playing = (call.argument("playing") as? Boolean) ?: true
                        pipHelper?.enterPip(Rational(w, h), playing)
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

        val mediaScanner = MediaScanner(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.pixelvibe/scan").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "scanVideos" -> {
                        result.success(mediaScanner.scanVideos())
                    }
                    else -> result.notImplemented()
                }
            }
        }

        val thumbnailHelper = ThumbnailHelper(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.pixelvibe/thumbnails").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getThumbnail" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("NO_PATH", "Path required", null)
                            return@setMethodCallHandler
                        }
                        val width = call.argument<Int>("width") ?: 320
                        val thumbnailPath = thumbnailHelper.getThumbnail(path, width)
                        result.success(thumbnailPath)
                    }
                    else -> result.notImplemented()
                }
            }
        }
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
        unregisterReceiver(pipActionReceiver)
        super.onDestroy()
    }

    private fun startForegroundService(title: String, content: String) {
        val intent = Intent(this, PlaybackService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
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

package com.pixelvibe.app.mediasession

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import io.flutter.plugin.common.MethodChannel

class MediaSessionCallback(
    private val context: Context,
    private val channel: MethodChannel
) : MediaSession.Callback() {

    private val mediaSession: MediaSession
    private var isPlaying = false
    private val receiver: BroadcastReceiver

    init {
        mediaSession = MediaSession(context, "pixelvibe").apply {
            setCallback(this@MediaSessionCallback)
            isActive = true
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                when (intent.action) {
                    "com.pixelvibe.action.TOGGLE_PLAYBACK" -> {
                        if (isPlaying) onPause() else onPlay()
                    }
                    "com.pixelvibe.action.STOP" -> onStop()
                }
            }
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) Context.RECEIVER_NOT_EXPORTED else 0
        context.registerReceiver(receiver, IntentFilter().apply {
            addAction("com.pixelvibe.action.TOGGLE_PLAYBACK")
            addAction("com.pixelvibe.action.STOP")
        }, flags)
    }

    fun updateMetadata(title: String, durationMs: Long, thumbnailPath: String? = null) {
        val builder = MediaMetadata.Builder()
            .putString(MediaMetadata.METADATA_KEY_TITLE, title)
            .putLong(MediaMetadata.METADATA_KEY_DURATION, durationMs)
        if (thumbnailPath != null) {
            val artUri = if (thumbnailPath.startsWith("/")) {
                android.net.Uri.fromFile(java.io.File(thumbnailPath))
            } else {
                android.net.Uri.parse(thumbnailPath)
            }
            builder.putString(MediaMetadata.METADATA_KEY_ALBUM_ART_URI, artUri.toString())
        }
        mediaSession.setMetadata(builder.build())
    }

    fun updatePlaybackState(playing: Boolean, positionMs: Long) {
        isPlaying = playing
        val state = if (playing) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED
        mediaSession.setPlaybackState(
            PlaybackState.Builder()
                .setState(state, positionMs, 1.0f)
                .setActions(
                    PlaybackState.ACTION_PLAY or
                    PlaybackState.ACTION_PAUSE or
                    PlaybackState.ACTION_PLAY_PAUSE or
                    PlaybackState.ACTION_STOP or
                    PlaybackState.ACTION_SEEK_TO
                )
                .build()
        )
    }

    override fun onPlay() {
        isPlaying = true
        channel.invokeMethod("onPlay", null)
    }

    override fun onPause() {
        isPlaying = false
        channel.invokeMethod("onPause", null)
    }

    override fun onStop() {
        isPlaying = false
        channel.invokeMethod("onStop", null)
    }

    override fun onSeekTo(pos: Long) {
        channel.invokeMethod("onSeekTo", pos)
    }

    fun release() {
        mediaSession.isActive = false
        mediaSession.release()
        context.unregisterReceiver(receiver)
    }
}

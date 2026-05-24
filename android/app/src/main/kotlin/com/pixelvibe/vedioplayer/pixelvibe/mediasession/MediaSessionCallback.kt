package com.pixelvibe.vedioplayer.pixelvibe.mediasession

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import io.flutter.plugin.common.MethodChannel

class MediaSessionCallback(
    private val context: Context,
    private val channel: MethodChannel
) : MediaSessionCompat.Callback() {

    private val mediaSession: MediaSessionCompat
    private var isPlaying = false

    init {
        mediaSession = MediaSessionCompat(context, "pixelvibe").apply {
            setCallback(this@MediaSessionCallback)
            isActive = true
        }

        val receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                when (intent.action) {
                    "com.pixelvibe.action.TOGGLE_PLAYBACK" -> {
                        if (isPlaying) onPause() else onPlay()
                    }
                    "com.pixelvibe.action.STOP" -> onStop()
                }
            }
        }
        context.registerReceiver(receiver, IntentFilter().apply {
            addAction("com.pixelvibe.action.TOGGLE_PLAYBACK")
            addAction("com.pixelvibe.action.STOP")
        }, Context.RECEIVER_EXPORTED)
    }

    fun updateMetadata(title: String, durationMs: Long) {
        mediaSession.setMetadata(
            MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_TITLE, title)
                .putLong(MediaMetadataCompat.METADATA_KEY_DURATION, durationMs)
                .build()
        )
    }

    fun updatePlaybackState(playing: Boolean, positionMs: Long) {
        isPlaying = playing
        val state = if (playing) {
            PlaybackStateCompat.STATE_PLAYING
        } else {
            PlaybackStateCompat.STATE_PAUSED
        }
        mediaSession.setPlaybackState(
            PlaybackStateCompat.Builder()
                .setState(state, positionMs, 1.0f)
                .setActions(
                    PlaybackStateCompat.ACTION_PLAY or
                    PlaybackStateCompat.ACTION_PAUSE or
                    PlaybackStateCompat.ACTION_PLAY_PAUSE or
                    PlaybackStateCompat.ACTION_STOP or
                    PlaybackStateCompat.ACTION_SEEK_TO
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
    }
}

package com.pixelvibe.app

import android.content.Context
import android.media.AudioFocusRequest
import android.media.AudioManager

class AudioFocusHelper(private val context: Context) {

    private val audioManager = context.getSystemService(AudioManager::class.java)!!
    private var onFocusChange: ((Int) -> Unit)? = null

    private val afChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        onFocusChange?.invoke(focusChange)
    }

    private var audioFocusRequest: AudioFocusRequest? = null

    fun requestFocus(callback: (Int) -> Unit) {
        onFocusChange = callback
        audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setOnAudioFocusChangeListener(afChangeListener)
            .setAudioAttributes(
                android.media.AudioAttributes.Builder()
                    .setUsage(android.media.AudioAttributes.USAGE_MEDIA)
                    .setContentType(android.media.AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .build()
        val result = audioFocusRequest?.let { audioManager.requestAudioFocus(it) } ?: AudioManager.AUDIOFOCUS_REQUEST_FAILED
        callback(result)
    }

    fun abandonFocus() {
        audioFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
        audioFocusRequest = null
    }
}

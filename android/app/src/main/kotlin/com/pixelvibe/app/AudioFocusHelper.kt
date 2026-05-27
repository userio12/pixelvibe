package com.pixelvibe.app

import android.content.Context
import android.media.AudioFocusRequest
import android.media.AudioManager

class AudioFocusHelper(private val context: Context) {

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
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
        audioFocusRequest?.let { audioManager.requestAudioFocus(it) }
    }

    fun abandonFocus() {
        audioFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
        audioFocusRequest = null
    }
}

package com.pixelvibe.app

import android.content.Context
import android.media.AudioManager

class AudioFocusHelper(private val context: Context) {

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var onFocusChange: ((Int) -> Unit)? = null

    private val afChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        onFocusChange?.invoke(focusChange)
    }

    fun requestFocus(callback: (Int) -> Unit) {
        onFocusChange = callback
        audioManager.requestAudioFocus(
            afChangeListener,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN,
        )
    }

    fun abandonFocus() {
        audioManager.abandonAudioFocus(afChangeListener)
    }
}

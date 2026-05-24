package com.pixelvibe.vedioplayer.pixelvibe.pip

import android.app.PendingIntent
import android.app.RemoteAction
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Rational
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity

@RequiresApi(Build.VERSION_CODES.O)
class PiPHelper(private val activity: FlutterActivity) {

    fun isPipSupported(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

    fun enterPip(aspectRatio: Rational, isPlaying: Boolean = true) {
        if (!isPipSupported()) return

        val actions = listOf(createPlayPauseAction(activity, isPlaying))
        val params = buildPipParams(aspectRatio, actions)
        activity.enterPictureInPictureMode(params)
    }

    fun buildPipParams(
        aspectRatio: Rational = Rational(16, 9),
        actions: List<RemoteAction> = emptyList()
    ): android.app.PictureInPictureParams {
        return android.app.PictureInPictureParams.Builder()
            .setAspectRatio(aspectRatio)
            .setAutoEnterEnabled(true)
            .setActions(actions)
            .build()
    }

    companion object {
        fun createPlayPauseAction(
            context: Context,
            isPlaying: Boolean,
            requestCode: Int = 1001
        ): RemoteAction {
            val intent = Intent("com.pixelvibe.action.TOGGLE_PLAYBACK").apply {
                putExtra("playing", isPlaying)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            val icon = if (isPlaying) {
                Icon.createWithResource(context, android.R.drawable.ic_media_pause)
            } else {
                Icon.createWithResource(context, android.R.drawable.ic_media_play)
            }
            return RemoteAction(icon, "Play/Pause", "Toggle playback", pendingIntent)
        }
    }
}

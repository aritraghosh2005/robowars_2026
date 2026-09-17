package robowars.com.robowars_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.widget.Toast

object NotificationHelper {
    const val CHANNEL_ID = "robowars_alerts"
    @Volatile
    private var isAppForeground = false

    fun setAppForeground(isForeground: Boolean) {
        isAppForeground = isForeground
    }

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Robowars alerts",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Arena alerts, call-ups, and event notifications"
            enableVibration(true)
        }
        context.getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    fun show(
        context: Context,
        title: String,
        body: String,
        notificationId: Int = System.currentTimeMillis().toInt(),
    ) {
        if (isAppForeground) {
            showCompactAlert(context, title, body)
            return
        }

        createChannel(context)
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            builder.setPriority(Notification.PRIORITY_HIGH)
        }

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        try {
            manager.notify(notificationId, builder.build())
        } catch (_: SecurityException) {
            // Android 13+ can deny POST_NOTIFICATIONS after scheduling succeeds.
        }
    }

    private fun showCompactAlert(context: Context, title: String, body: String) {
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(
                context.applicationContext,
                "$title\n$body",
                Toast.LENGTH_LONG,
            ).show()
        }
    }
}

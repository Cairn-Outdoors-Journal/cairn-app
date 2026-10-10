package com.cairnjournal.app.capture

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.IBinder
import com.cairnjournal.app.R

/**
 * A foreground service that lives only long enough to take one fix.
 *
 * Android lets an app with "While using" permission use location from a
 * foreground service that was started while the app was allowed to start one;
 * the spike checks whether a quick-settings tile tap counts.
 */
class CaptureForegroundService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL, "Saving location points", NotificationManager.IMPORTANCE_LOW),
        )
        val notification = Notification.Builder(this, CHANNEL)
            .setSmallIcon(R.drawable.ic_capture_tile)
            .setContentTitle("Saving a location point")
            .build()

        try {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } catch (e: SecurityException) {
            LocationCapture.recordFailure(this, "tile", "fgs", "fgsSecurityException", e.message)
            stopSelf()
            return START_NOT_STICKY
        } catch (e: IllegalStateException) {
            LocationCapture.recordFailure(this, "tile", "fgs", "fgsNotAllowed", e.toString())
            stopSelf()
            return START_NOT_STICKY
        }

        LocationCapture.capture(applicationContext, source = "tile", method = "fgs") {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        }
        return START_NOT_STICKY
    }

    private companion object {
        const val CHANNEL = "capture"
        const val NOTIFICATION_ID = 47
    }
}

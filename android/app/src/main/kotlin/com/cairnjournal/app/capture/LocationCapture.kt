package com.cairnjournal.app.capture

import android.Manifest
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.location.LocationRequest
import android.os.Build
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import org.json.JSONObject
import java.io.File
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Takes one location fix and records what happened.
 *
 * Spike code for stage 5b: it exists to learn what Android allows from each
 * capture surface at each permission level, so it records failures as
 * carefully as successes.
 */
object LocationCapture {
    private const val TIMEOUT_MS = 20_000L
    private const val LOG_FILE = "captures.jsonl"

    fun logFile(context: Context): File = File(context.filesDir, LOG_FILE)

    /** "always", "whileInUse" or "denied". */
    fun permissionLevel(context: Context): String {
        val fine = granted(context, Manifest.permission.ACCESS_FINE_LOCATION)
        val coarse = granted(context, Manifest.permission.ACCESS_COARSE_LOCATION)
        if (!fine && !coarse) return "denied"
        return if (granted(context, Manifest.permission.ACCESS_BACKGROUND_LOCATION)) "always" else "whileInUse"
    }

    fun preciseGranted(context: Context): Boolean =
        granted(context, Manifest.permission.ACCESS_FINE_LOCATION)

    private fun granted(context: Context, permission: String) =
        context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    /** Whether the app has a visible activity right now. */
    fun appState(): String {
        val info = ActivityManager.RunningAppProcessInfo()
        ActivityManager.getMyMemoryState(info)
        return if (info.importance <= ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
            "foreground"
        } else {
            "background"
        }
    }

    /**
     * Requests one fix and appends a record to the log. [done] is called on
     * the main thread with the result code ("fix", "lastKnown", "timeout",
     * "noFix", "securityException", "denied", "error").
     */
    fun capture(context: Context, source: String, method: String, done: ((String) -> Unit)? = null) {
        val requestedAt = System.currentTimeMillis()
        val record = JSONObject()
            .put("id", UUID.randomUUID().toString())
            .put("platform", "android")
            .put("source", source)
            .put("method", method)
            .put("permission", permissionLevel(context))
            .put("precise", preciseGranted(context))
            .put("appState", appState())
            .put("requestedAt", requestedAt)

        val main = Handler(Looper.getMainLooper())
        val finished = AtomicBoolean(false)

        fun finish(result: String, location: Location?, error: String?) {
            if (!finished.compareAndSet(false, true)) return
            val now = System.currentTimeMillis()
            record.put("result", result)
                .put("completedAt", now)
                .put("latencyMs", now - requestedAt)
            if (location != null) {
                record.put("lat", location.latitude)
                    .put("lon", location.longitude)
                    .put("accuracyM", location.accuracy.toDouble())
                    .put("altitudeM", if (location.hasAltitude()) location.altitude else JSONObject.NULL)
                    .put("provider", location.provider ?: "")
                    .put("locationAgeMs", now - location.time)
            }
            if (error != null) record.put("error", error)
            append(context, record)
            main.post { done?.invoke(result) }
        }

        if (record.getString("permission") == "denied") {
            finish("denied", null, null)
            return
        }

        val manager = context.getSystemService(LocationManager::class.java)
        val provider = when {
            Build.VERSION.SDK_INT >= 31 &&
                manager.allProviders.contains(LocationManager.FUSED_PROVIDER) &&
                manager.isProviderEnabled(LocationManager.FUSED_PROVIDER) -> LocationManager.FUSED_PROVIDER
            manager.isProviderEnabled(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
            else -> LocationManager.NETWORK_PROVIDER
        }
        record.put("requestedProvider", provider)

        val cancel = CancellationSignal()
        main.postDelayed({
            cancel.cancel()
            val last = try {
                manager.getLastKnownLocation(provider)
            } catch (e: SecurityException) {
                null
            }
            finish(if (last != null) "lastKnown" else "timeout", last, null)
        }, TIMEOUT_MS)

        if (Build.VERSION.SDK_INT < 31) {
            finish("error", null, "spike needs Android 12 (API 31) or later")
            return
        }
        // A location point should be precise: ask for high accuracy (GPS) rather
        // than the default balanced quality, which may use only network
        // positioning and return nothing outdoors with no signal.
        val request = LocationRequest.Builder(0)
            .setQuality(LocationRequest.QUALITY_HIGH_ACCURACY)
            .setDurationMillis(TIMEOUT_MS)
            .build()
        record.put("quality", "high")
        try {
            manager.getCurrentLocation(provider, request, cancel, context.mainExecutor) { location ->
                if (location != null) {
                    finish("fix", location, null)
                } else {
                    finish("noFix", null, "provider returned no location")
                }
            }
        } catch (e: SecurityException) {
            finish("securityException", null, e.message)
        } catch (e: IllegalArgumentException) {
            finish("error", null, e.message)
        }
    }

    /** Records a failure that happened before a fix could be requested. */
    fun recordFailure(context: Context, source: String, method: String, result: String, error: String?) {
        val now = System.currentTimeMillis()
        val record = JSONObject()
            .put("id", UUID.randomUUID().toString())
            .put("platform", "android")
            .put("source", source)
            .put("method", method)
            .put("permission", permissionLevel(context))
            .put("precise", preciseGranted(context))
            .put("appState", appState())
            .put("requestedAt", now)
            .put("completedAt", now)
            .put("latencyMs", 0)
            .put("result", result)
        if (error != null) record.put("error", error)
        append(context, record)
    }

    @Synchronized
    private fun append(context: Context, record: JSONObject) {
        logFile(context).appendText(record.toString() + "\n")
    }

    @Synchronized
    fun readLog(context: Context): String =
        logFile(context).takeIf { it.exists() }?.readText() ?: ""

    @Synchronized
    fun clearLog(context: Context) {
        logFile(context).delete()
    }
}

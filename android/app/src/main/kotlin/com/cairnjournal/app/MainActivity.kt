package com.cairnjournal.app

import android.Manifest
import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.cairnjournal.app.capture.CaptureTileService
import com.cairnjournal.app.capture.LocationCapture
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Bridge for the stage 5b location spike (lib/spikes/location_capture).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cairn/location_spike")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(
                        mapOf(
                            "permission" to LocationCapture.permissionLevel(this),
                            "precise" to LocationCapture.preciseGranted(this),
                        ),
                    )
                    "readLog" -> result.success(LocationCapture.readLog(this))
                    "clearLog" -> {
                        LocationCapture.clearLog(this)
                        result.success(null)
                    }
                    "captureNow" -> LocationCapture.capture(applicationContext, "app", "direct") {
                        result.success(it)
                    }
                    "requestWhileUsing" -> {
                        requestPermissions(
                            arrayOf(
                                Manifest.permission.ACCESS_FINE_LOCATION,
                                Manifest.permission.ACCESS_COARSE_LOCATION,
                            ),
                            1,
                        )
                        result.success(null)
                    }
                    "requestAlways" -> {
                        // The manifest no longer declares background location
                        // (ADR 0009), so Android ignores this request now.
                        requestPermissions(arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION), 2)
                        result.success(null)
                    }
                    "openSettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null)),
                        )
                        result.success(null)
                    }
                    "addTile" -> {
                        if (Build.VERSION.SDK_INT >= 33) {
                            getSystemService(StatusBarManager::class.java).requestAddTileService(
                                ComponentName(this, CaptureTileService::class.java),
                                "Save point",
                                Icon.createWithResource(this, R.drawable.ic_capture_tile),
                                mainExecutor,
                            ) { code -> result.success(code) }
                        } else {
                            result.success(-1)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

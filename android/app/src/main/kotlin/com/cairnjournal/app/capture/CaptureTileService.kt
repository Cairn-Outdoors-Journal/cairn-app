package com.cairnjournal.app.capture

import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Quick-settings tile: saves a location point without opening Cairn.
 *
 * It first asks for a fix directly. With only "While using" permission that
 * may be refused while Cairn is in the background, so it then also tries a
 * short foreground service, the other route Android may allow after a tile
 * tap. Both attempts are logged.
 */
class CaptureTileService : TileService() {

    override fun onStartListening() {
        showIdle()
    }

    override fun onClick() {
        val app = applicationContext
        show(Tile.STATE_ACTIVE, "Saving…")
        val permission = LocationCapture.permissionLevel(app)
        LocationCapture.capture(app, source = "tile", method = "direct") { result ->
            if (permission == "whileInUse") {
                startForegroundFallback()
            } else {
                show(Tile.STATE_INACTIVE, if (result == "fix") "Point saved" else "No point")
            }
        }
    }

    private fun startForegroundFallback() {
        val app = applicationContext
        try {
            app.startForegroundService(Intent(app, CaptureForegroundService::class.java))
            show(Tile.STATE_INACTIVE, "Saving…")
        } catch (e: IllegalStateException) {
            // ForegroundServiceStartNotAllowedException is an IllegalStateException.
            LocationCapture.recordFailure(app, "tile", "fgs", "fgsNotAllowed", e.toString())
            showIdle()
        } catch (e: SecurityException) {
            LocationCapture.recordFailure(app, "tile", "fgs", "fgsSecurityException", e.message)
            showIdle()
        }
    }

    private fun showIdle() = show(Tile.STATE_INACTIVE, "Save point")

    private fun show(state: Int, label: String) {
        val tile = qsTile ?: return
        tile.state = state
        tile.label = label
        tile.updateTile()
    }
}

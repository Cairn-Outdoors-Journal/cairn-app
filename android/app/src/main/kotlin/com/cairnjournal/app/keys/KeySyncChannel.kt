package com.cairnjournal.app.keys

import android.content.Context
import com.google.android.gms.auth.blockstore.Blockstore
import com.google.android.gms.auth.blockstore.DeleteBytesRequest
import com.google.android.gms.auth.blockstore.RetrieveBytesRequest
import com.google.android.gms.auth.blockstore.StoreBytesData
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Keeps a copy of the journal key in Block Store (ADR 0012).
 *
 * Play services keeps it on this phone through a reinstall, and backs it up
 * to the Google account only when it can encrypt it end to end, which needs
 * a screen lock. A new Android phone restored from that backup gets the key.
 */
object KeySyncChannel {
    fun register(context: Context, messenger: BinaryMessenger) {
        val client = Blockstore.getClient(context)
        MethodChannel(messenger, "cairn/key_sync").setMethodCallHandler { call, result ->
            val fail = { e: Exception -> result.error("block_store", e.message, null) }
            when (call.method) {
                "read" -> {
                    val name = call.arguments as String
                    val request = RetrieveBytesRequest.Builder().setKeys(listOf(name)).build()
                    client.retrieveBytes(request)
                        .addOnSuccessListener { result.success(it.blockstoreDataMap[name]?.bytes) }
                        .addOnFailureListener(fail)
                }
                // Stores the key, backed up only when end-to-end encryption is
                // available. Checked on every store, so a screen lock added
                // later starts the backup. Answers whether it is backed up.
                "keep" -> {
                    val name = call.argument<String>("name")!!
                    val key = call.argument<ByteArray>("key")!!
                    client.isEndToEndEncryptionAvailable()
                        .addOnSuccessListener { toCloud ->
                            val data = StoreBytesData.Builder()
                                .setKey(name)
                                .setBytes(key)
                                .setShouldBackupToCloud(toCloud)
                                .build()
                            client.storeBytes(data)
                                .addOnSuccessListener { result.success(toCloud) }
                                .addOnFailureListener(fail)
                        }
                        // Storing without the check would mark the copy as not
                        // backed up, and Google would delete the cloud copy.
                        .addOnFailureListener(fail)
                }
                "delete" -> {
                    val name = call.arguments as String
                    val request = DeleteBytesRequest.Builder().setKeys(listOf(name)).build()
                    client.deleteBytes(request)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener(fail)
                }
                else -> result.notImplemented()
            }
        }
    }
}

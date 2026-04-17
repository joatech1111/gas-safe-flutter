package com.joainfo.gas_safe

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.joatech.gassafe/phone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getPhoneNumber") {
                val phoneNumber = getPhoneNumber()
                if (phoneNumber != null) {
                    result.success(phoneNumber)
                } else {
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getPhoneNumber(): String? {
        return try {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_NUMBERS) == PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                val tm = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
                tm.line1Number
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }
}

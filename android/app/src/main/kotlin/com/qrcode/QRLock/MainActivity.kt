package com.games.qrprivacy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri


class MainActivity: FlutterActivity() {
    private val CHANNEL = "actionChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "openCrypto") {

                val cryptoURI: String = (call.arguments as? String)  ?: "";

                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(cryptoURI)

                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent)
                    result.success("")
                }
                else
                {
                    result.error("UNAVAILABLE", "Can't open this Crypto QR Code. There is no Crypto app found.", null)
                }

            } else {
                result.notImplemented()
            }
        }
    }
}

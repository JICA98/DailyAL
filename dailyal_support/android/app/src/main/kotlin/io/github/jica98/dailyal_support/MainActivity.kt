package io.github.jica98.dailyal_support

import android.content.pm.PackageInfo
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "io.github.jica98.dailal_support"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAppInfo") {
                val data = getDataFromNative()
                result.success(data)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getDataFromNative(): String? {
        return try {
            val app = "io.github.jica98";
            val packageInfo = packageManager.getPackageInfo(app, 0)
            val versionName = packageInfo.versionName
            val versionCode = getVersionCode(packageInfo)
            return if (versionCode != null && versionName != null) {
                "$versionName+$versionCode"
            } else {
                null
            }
        } catch (e: Exception) {
            println(e.message);
            null
        }
    }

    private fun getVersionCode(packageInfo: PackageInfo): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            "${packageInfo.longVersionCode}"
        } else {
            null
        }
    }
}

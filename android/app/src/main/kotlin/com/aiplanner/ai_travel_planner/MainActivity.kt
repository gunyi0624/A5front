package com.aiplanner.ai_travel_planner

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL =
            "ai_travel_planner/app_config"
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "getMapsApiKey" -> {
                    try {
                        val applicationInfo =
                            packageManager.getApplicationInfo(
                                packageName,
                                PackageManager.GET_META_DATA
                            )

                        val apiKey =
                            applicationInfo.metaData
                                ?.getString(
                                    "com.google.android.geo.API_KEY"
                                )

                        if (apiKey.isNullOrBlank()) {
                            result.error(
                                "MISSING_API_KEY",
                                "Google Maps API Key를 찾을 수 없습니다.",
                                null
                            )
                        } else {
                            result.success(apiKey)
                        }
                    } catch (e: Exception) {
                        result.error(
                            "API_KEY_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
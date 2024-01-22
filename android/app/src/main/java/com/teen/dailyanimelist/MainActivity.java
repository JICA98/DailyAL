package com.teen.dailyanimelist;

import android.content.ComponentName;
import android.content.pm.PackageManager;
import android.os.Bundle;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.teen.dailyanimelist/app";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                          switch (call.method){
                              case "setAppName":
                                  try {
                                      setAppName(call.argument("appName"));
                                      result.success("null");
                                  } catch (Exception e){
                                      result.error("Error", e.getMessage(), e.getMessage());
                                  }
                                  break;
                          }
                        }
                );
    }

    public void setAppName(String appName){
        getPackageManager().setComponentEnabledSetting(
                new ComponentName(BuildConfig.APPLICATION_ID, "com.teen.dailyanimelist." + appName),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP
        );
    }
}

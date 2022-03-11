package com.example.cast_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
//import com.connectsdk.CastController

/** CastSdkPlugin */
class CastSdkPlugin : FlutterPlugin, ActivityAware {

  var castController = CastHelper()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    castController.setUpMethodChannel(flutterPluginBinding)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    castController.removeMethodChannel()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    castController.setUpActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onDetachedFromActivity() {
  }
}

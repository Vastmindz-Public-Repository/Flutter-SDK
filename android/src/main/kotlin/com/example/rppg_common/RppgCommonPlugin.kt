package com.example.rppg_common

import android.app.Activity
import com.example.rppg_common.utils.PermissionResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** RppgCommonPlugin */
class RppgCommonPlugin: FlutterPlugin, MethodCallHandler, ActivityAware,
  EventChannel.StreamHandler {

  private var analysisInstance = Analysis.getInstance()

  /// Method channel
  private lateinit var channel : MethodChannel

  /// Event channel
  private var eventChannel: EventChannel? = null
  var eventSink: EventChannel.EventSink? = null


  /// Activity
  private lateinit var activity: Activity

  /// App Lifecycle
  private lateinit var lifecycle: Any

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
    lifecycle = binding.lifecycle;
    if(this::activity.isInitialized) {
      analysisInstance.initialization(activity, lifecycle)
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Method Channel
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rppg_common")
    channel.setMethodCallHandler(this)

    // Event Channel
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "rppgCommon/analysisDataStream"); // timeHandlerEvent event name
    eventChannel?.setStreamHandler(this)

    // Platform View
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory("rppg_native_camera", FLNativeViewFactory())

  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "getState"->
        result.success(analysisInstance.getState())
      "askPermissions"->
        analysisInstance.setupPermission(activity,object :PermissionResult{
          override fun onPermissionCheck(isGranted: Boolean) {
            result.success(isGranted)
          }
        })
      "configure"-> {
        var fps = call.argument<Int>("fps")
        var isFrontCamera = call.argument<Boolean>("isFrontCamera")
        if (fps != null) {
          if (isFrontCamera != null) {
            analysisInstance.configure(fps = fps,isFrontCamera = isFrontCamera)
          }
        }
      }
      "startVideo"-> {
        analysisInstance.startVideo(activity)
      }
      "startAnalysis"-> {
        var baseUrl = call.argument<String>("baseUrl").toString()
        var authToken = call.argument<String>("authToken").toString()
        var fps = call.argument<String>("fps").toString()
        var age = call.argument<String>("age").toString()
        var sex = call.argument<String>("sex").toString()
        var height = call.argument<String>("height").toString()
        var weight = call.argument<String>("weight").toString()

        analysisInstance.startAnalysis(
          baseUrl,
          authToken,
          fps,
          age,
          sex,
          height,
          weight
          )
      }
      "stopAnalysis"-> {
        analysisInstance.stopAnalysis()
      }
      "cleanMesh"-> {
        analysisInstance.cleanMesh()
      }
      "meshColor"-> {
        analysisInstance.meshColor()
      }
      else ->
        result.notImplemented()
    }

  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


  /// Event Channel
  override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
    this.eventSink = eventSink
    analysisInstance.setEventSink(eventSink)
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
    eventChannel = null
  }

  public fun sendEvent(data: Any) {
    // Check if the eventSink is available
    if(eventSink == null) {
      return
    }

    eventSink!!.success(data)
  }

  public fun cancelStream() {
    if(eventSink == null) {
      return
    }

    eventSink!!.endOfStream()
  }


}

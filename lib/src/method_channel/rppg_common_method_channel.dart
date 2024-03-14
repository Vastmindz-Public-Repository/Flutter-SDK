import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../analysis_data/analysis_data.dart';
import '../assets/Constants/rppg_constants.dart';
import '../platform_interface/rppg_common_platform_interface.dart';

/// An implementation of [RppgCommonPlatform] that uses method channels.
class MethodChannelRppgCommon extends RppgCommonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(RppgConstants.methodChannelName);

  /// The event channel used to interact with the native platform for stream data interchange.
  static const EventChannel streamEventChannel =
      EventChannel(RppgConstants.eventChannelName);

  /// Stream Controller to handle upcoming stream response
  final streamController = StreamController<AnalysisData>();

  @override
  Future<String> getState() async {
    final result =
        await methodChannel.invokeMethod<String>(RppgConstants.getState) ??
            RppgConstants.defaultString;
    return result;
  }

  @override
  Future<bool> askPermissions() async {
    final result =
        await methodChannel.invokeMethod<bool>(RppgConstants.askPermissions) ??
            false;
    return result;
  }

  @override
  configure(int fps, bool isFrontCamera) async {
    Map<String, dynamic> configArguments = {
      'fps': fps,
      'isFrontCamera': isFrontCamera,
    };
    await methodChannel.invokeMethod<String>(
        RppgConstants.configure, configArguments);
    return null;
  }

  @override
  startVideo() async {
    await methodChannel.invokeMethod<String>(RppgConstants.startVideo);
    return null;
  }

  @override
  Stream<AnalysisData> startAnalysis(String baseUrl, String authToken,
      String fps, String age, String sex, String height, String weight) {
    Map<String, dynamic> arguments = {
      'baseUrl': baseUrl,
      'authToken': authToken,
      'fps': fps,
      'age': age,
      'sex': sex,
      'height': height,
      'weight': weight
    };

    methodChannel.invokeMethod(RppgConstants.startAnalysis, arguments);
    // return streamEventChannel.receiveBroadcastStream();

    streamEventChannel.receiveBroadcastStream().listen((data) {
      AnalysisData analysisDataModel = analysisDataFromJson(data);
      streamController.add(analysisDataModel);
    }, onError: (error) {
      // Handle errors if needed
      streamController.addError(error);
    }, onDone: () {
      // Close the controller when the input stream is done
      streamController.close();
    });
    // Return the transformed stream
    return streamController.stream.asBroadcastStream();
  }

  @override
  stopAnalysis() async {
    await methodChannel.invokeMethod<String>(RppgConstants.stopAnalysis);
    return null;
  }

  @override
  meshColor() async {
    await methodChannel.invokeMethod<String>(RppgConstants.meshColor);
    return null;
  }

  @override
  cleanMesh() async {
    await methodChannel.invokeMethod<String>(RppgConstants.cleanMesh);
    return null;
  }
}

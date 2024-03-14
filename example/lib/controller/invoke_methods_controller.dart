import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rppg_common/rppg_common.dart';
import '../assets/constants/app_constants.dart';

class InvokeMethodController extends GetxController {
  /// Main Object of RppgCommon Class
  final rppgCommon = RppgCommon();

  /// State of RppgCommon Class
  var rppgCommonState = "".obs;

  /// RppgCommon method's response If any
  var invokeResult = "".obs;

  /// Permission response
  var resultPermissions = false.obs;

  /// Analysis Done flag
  var isAnalysisDone = false.obs;

  ///  Circular Animation Controller
  late AnimationController animationController;

  /// UI Interface
  /// Button
  var buttonTitle = "Start Process".obs;
  /// Data Visibility Flag
  var scanResultVisibility = false.obs;

  /// Timer
  late Timer? timer;
  var timerValue = 60.obs;

  /// Data Carriers
  /// Analysis Value
  var avgBpm = ''.obs;
  var avgO2SaturationLevel = ''.obs;
  var avgRespirationRate = ''.obs;
  var bloodPressureSys = ''.obs;
  var bloodPressureDia = ''.obs;
  var bloodPressureStatus = ''.obs;
  var stressStatus = ''.obs;
  var statusMessage = ''.obs;
  var sdnns = ''.obs;
  var isMoveWarning = false.obs;
  RxInt progressPercentage = 0.obs;

  /// Reset All Values to Initial
  void resetValues() {
    avgBpm = ''.obs;
    avgO2SaturationLevel = ''.obs;
    avgRespirationRate = ''.obs;
    bloodPressureSys = ''.obs;
    bloodPressureDia = ''.obs;
    bloodPressureStatus = ''.obs;
    stressStatus = ''.obs;
    statusMessage = ''.obs;
    sdnns = ''.obs;
    isMoveWarning = false.obs;
    progressPercentage = 0.obs;
  }

  /// Initial set of commands
  startWholeSession() async {
    await invokeMethod("getState");
    invokeMethod("askPermissions");
    updateButtonTitle();
    if (resultPermissions.value == true) {
      invokeMethod("configure");
      invokeMethod("startVideo");
      updateButtonTitle();
    } else {
      startWholeSession();
    }
  }

  /// Handle all Methods of RppgCommon, according it's rppgCommonState
  startSession() async {
    await invokeMethod("getState");
    switch (rppgCommonState.value) {
      case "initial":
        {
          invokeMethod("askPermissions");
          if (resultPermissions.value == true) {
            invokeMethod("configure");
          }
          updateButtonTitle();
        }
        break;
      case "prepared":
        {
          invokeMethod("startVideo");
          scanResultVisibility.value = false;
          updateButtonTitle();
        }
        break;
      case "videoStarted":
        {
          isAnalysisDone.value = false;
          scanResultVisibility.value = true;
          resetValues();
          invokeMethod("startAnalysis");
          invokeMethod("meshColor");
          updateButtonTitle();
        }
        break;
      case "analysisRunning":
        {
          invokeMethod("stopAnalysis");
          invokeMethod("cleanMesh");
          isAnalysisDone.value = true;
          timerValue.value = 60;
          updateButtonTitle();
        }
        break;
      default:
        {
          updateButtonTitle();
        }
        break;
    }
  }

  /// Update the UI button Text
  void updateButtonTitle() async {
    rppgCommonState.value = await rppgCommon.getState();
    switch (rppgCommonState.value) {
      case "initial":
        {
          buttonTitle.value = "Ask for Permissions";
        }
        break;
      case "prepared":
        {
          buttonTitle.value = "Start Video Session";
        }
        break;
      case "videoStarted":
        {
          buttonTitle.value = "Start Scanning";
        }
        break;
      case "analysisRunning":
        {
          buttonTitle.value = "Stop Scanning";
        }
        break;
      case "fail":
        {
          buttonTitle.value = "Fail";
        }
        break;
      default:
        {
          buttonTitle.value = "Please Wait...";
        }
        break;
    }
  }

  /// Handle Timer
  void startTimer() {
    const oneSec = Duration(seconds: 1);

    try {
      if (timer!.isActive) {
        timer!.cancel();
        timerValue.value = 60;
      }
      timer = Timer.periodic(oneSec, (Timer timer) {
        if (timerValue.value == 0) {
          timer.cancel();
          checkLastValues();
        } else {
          timerValue.value = timerValue.value - 1;
        }
      });
    } catch (e) {
      timerValue.value = 60;
      timer = Timer.periodic(oneSec, (Timer timer) {
        if (timerValue.value == 0) {
          timer.cancel();
          checkLastValues();
        } else {
          timerValue.value = timerValue.value - 1;
        }
      });
    }
  }

  /// All available methods of RppgCommon
  invokeMethod(String methodName) async {
    switch (methodName) {
      case "getState":
        {
          try {
            rppgCommonState.value = await rppgCommon.getState();
          } on PlatformException {
            invokeResult.value = 'Failed to get getState.';
          }
        }
        break;

      case "askPermissions":
        {
          try {
            resultPermissions.value = await rppgCommon.askPermissions();
          } on PlatformException {
            invokeResult.value = 'Failed to askPermissions.';
          }
        }
        break;

      case "configure":
        {
          try {
            await rppgCommon.configure(30, true);
          } on PlatformException {
            invokeResult.value = 'Failed to configure.';
          }
        }
        break;

      case "startVideo":
        {
          try {
            await rppgCommon.startVideo();
          } on PlatformException {
            invokeResult.value = 'Failed to startVideo.';
          }
        }
        break;

      case "startAnalysis":
        {
          startTimer();
          try {
            resetValues();
            rppgCommon
                .startAnalysis(
                    AppConstants.baseUrl,
                    AppConstants.authToken,
                    AppConstants.fps,
                    AppConstants.age,
                    AppConstants.sex,
                    AppConstants.height,
                    AppConstants.weight)
                .listen((eventData) {

              sdnns.value = parseStringToDouble(eventData.sdnns.toString()) ;
              statusMessage.value = eventData.statusMessage;
              progressPercentage.value = eventData.progressPercentage;

              avgBpm.value = '${eventData.avgBpm}';
              avgO2SaturationLevel.value =
              '${eventData.avgO2SaturationLevel}';
              avgRespirationRate.value =
              '${eventData.avgRespirationRate}';

              bloodPressureSys.value =
              "${eventData.bloodPressure.systolic}";
              bloodPressureDia.value =
              "${eventData.bloodPressure.diastolic}";

              bloodPressureStatus.value = eventData.bloodPressureStatus;
              stressStatus.value = eventData.stressStatus;

              isMoveWarning.value =
                  eventData.isMovingWarning;

              if (checkIfGotAllValues()) {
                checkLastValues();
              }
            });
          } on PlatformException {
            statusMessage.value = 'Failed startAnalysis.';
            invokeResult.value = 'Failed startAnalysis.';
          }
        }
        break;

      case "stopAnalysis":
        {
          try {
            await rppgCommon.stopAnalysis();
          } on PlatformException {
            invokeResult.value = 'Failed stopAnalysis.';
          }
        }
        break;

      case "meshColor":
        {
          try {
            await rppgCommon.meshColor();
          } on PlatformException {
            invokeResult.value = 'Failed meshColor.';
          }
        }
        break;

      case "cleanMesh":
        {
          try {
            await rppgCommon.cleanMesh();
          } on PlatformException {
            invokeResult.value = 'Failed cleanMesh.';
          }
        }
        break;

      default:
        {
          invokeResult.value = 'Failed inside default invokeMethod().';
        }
        break;
    }
  }

  /// Check analysis values during data streaming from running socket
  ///
  /// To stop the running analysis if all needed values got
  bool checkIfGotAllValues() {
    var percent = 0;

    if (!((avgBpm.value == '0.0') || (avgBpm.value == '0'))) {
      percent = percent + 20;
    }
    if (!((avgO2SaturationLevel.value == '0.0') ||
        (avgO2SaturationLevel.value == '0'))) {
      percent = percent + 20;
    }
    if (!((avgRespirationRate.value == '0.0') ||
        (avgRespirationRate.value == '0'))) {
      percent = percent + 20;
    }
    if (!((bloodPressureSys.value == '0.0') ||
        (bloodPressureSys.value == '0'))) {
      percent = percent + 10;
    }
    if (!((bloodPressureDia.value == '0.0') ||
        (bloodPressureDia.value == '0'))) {
      percent = percent + 10;
    }

    if (!((stressStatus.value.toLowerCase() == "no_data") ||
        (stressStatus.value.toLowerCase() == "nodata"))) {
      percent = percent + 20;
    }

    if (percent == 100) {
      return true;
    }

    return false;
  }

  /// Check and Update data values during Analysis
  void checkLastValues() {
    if (checkEmptyValue(avgBpm.value)) {
      avgBpm.value = '-';
    }
    if (checkEmptyValue(avgO2SaturationLevel.value)) {
      avgO2SaturationLevel.value = '-';
    }
    if (checkEmptyValue(avgRespirationRate.value)) {
      avgRespirationRate.value = '-';
    }
    if (checkEmptyValue(bloodPressureSys.value)) {
      bloodPressureSys.value = '-';
    }
    if (checkEmptyValue(bloodPressureDia.value)) {
      bloodPressureDia.value = '-';
    }

    if (checkEmptyValue(sdnns.value)) {
      sdnns.value = '-';
    }

    if (checkEmptyValue(bloodPressureStatus.value)) {
      bloodPressureStatus.value = '-';
    }
    if (checkEmptyValue(stressStatus.value)) {
      stressStatus.value = '-';
    }

    if (isMoveWarning.isTrue) {
      isMoveWarning.value = false;
    }

    timerValue.value = 60;
    statusMessage.value = 'Analysis Done!!!';
    isAnalysisDone.value = true;
    stopCircularAnimation();
    invokeMethod("stopAnalysis");
    invokeMethod("cleanMesh");
    updateButtonTitle();
  }


  /// Convert (String to Double)
  String parseStringToDouble(String inputString) {
    // Convert string to double
    double inputValue = double.parse(inputString);
    // Round to two decimal places
    String roundedString = inputValue.toStringAsFixed(2);
    return roundedString;
  }

  /// Check empty value
  bool checkEmptyValue(String dataTextValue) {
    bool isEmptyValue = true;

    if ((dataTextValue == "") || (dataTextValue == '0.0') || (dataTextValue == '0.00') ||
        (dataTextValue == '0') || (dataTextValue.toLowerCase() == "no_data") || (dataTextValue.toLowerCase() == "nodata")) {
      isEmptyValue = true;
    } else {
      isEmptyValue = false;
    }

    return isEmptyValue;
  }

  /// Circular Animation
  ///
  /// Start animation
  void startCircularAnimation() {
    animationController.repeat();
  }

  /// Stop animation
  void stopCircularAnimation() {
    animationController.stop();
  }
}

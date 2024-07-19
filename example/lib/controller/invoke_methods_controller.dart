import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rppg_common/rppg_common.dart';
import 'package:rppg_common_example/res/constants/app_constants.dart';
import 'package:rppg_common_example/res/rppg_method/rppg_method.dart';
import 'package:rppg_common_example/res/rppg_state/rppg_state.dart';

abstract class UpdateUI {
  void updateButtonTitle();
}

class InvokeMethodController extends GetxController implements UpdateUI {
  /// Main Object of RppgCommon Class
  final rppgCommon = RppgCommon();

  /// State of RppgCommon Class
  Rx<RppgState> rppgCommonState = RppgState.initial.obs;

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

  @override
  void onInit() {
    super.onInit();
    // Call updateButtonTitle whenever rppgCommonState changes
    ever(rppgCommonState, (_) => updateButtonTitle());
  }

  @override
  void dispose() {
    // Your disposal logic here
    super.dispose();
  }

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

  /// Check analysis values during data streaming from running socket
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
    timer!.cancel();
    statusMessage.value = 'Analysis Done!!!';
    isAnalysisDone.value = true;
    stopCircularAnimation();
    invokeMethod(RppgMethod.stopAnalysis);
    invokeMethod(RppgMethod.cleanMesh);
    invokeMethod(RppgMethod.getState);
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

  /// Initial set of commands
  void startWholeSession() async {
    await invokeMethod(RppgMethod.getState);
    await invokeMethod(RppgMethod.askPermissions);
    await invokeMethod(RppgMethod.getState);
    if (resultPermissions.value == true) {
      invokeMethod(RppgMethod.configure);
      invokeMethod(RppgMethod.startVideo);
      invokeMethod(RppgMethod.getState);
    } else {
      startWholeSession();
    }
  }

  /// Handle all Methods of RppgCommon, according it's rppgCommonState
  void startSession() {
    invokeMethod(RppgMethod.getState);
    switch (rppgCommonState.value) {
      case RppgState.initial:
        {
          invokeMethod(RppgMethod.askPermissions);
          if (resultPermissions.value == true) {
            invokeMethod(RppgMethod.configure);
          }
          invokeMethod(RppgMethod.getState);
        }
        break;
      case RppgState.prepared:
        {
          invokeMethod(RppgMethod.startVideo);
          scanResultVisibility.value = false;
          invokeMethod(RppgMethod.getState);
        }
        break;
      case RppgState.videoStarted:
        {
          isAnalysisDone.value = false;
          scanResultVisibility.value = true;
          resetValues();
          invokeMethod(RppgMethod.startAnalysis);
          invokeMethod(RppgMethod.meshColor);
          invokeMethod(RppgMethod.getState);
        }
        break;
      case RppgState.analysisRunning:
        {
          checkLastValues();
          // invokeMethod(RppgMethod.stopAnalysis);
          // invokeMethod(RppgMethod.cleanMesh);
          // isAnalysisDone.value = true;
          // timerValue.value = 60;
          // invokeMethod(RppgMethod.getState);
        }
        break;
      default:
        {
          invokeMethod(RppgMethod.getState);
        }
        break;
    }
  }

  /// All available methods of RppgCommon
  Future<void> invokeMethod(RppgMethod methodName) async {
    switch (methodName) {
      case RppgMethod.getState:
        {
          // rppgCommonState.value = await rppgCommon.getState();
          rppgCommonState.value =
              stringToRppgState(await rppgCommon.getState());
          // print(";:::::::: rppgCommonState.value  ::::::::; ${rppgCommonState.value}");
        }
        break;

      case RppgMethod.askPermissions:
        {
          resultPermissions.value = await rppgCommon.askPermissions();
        }
        break;

      case RppgMethod.configure:
        {
          await rppgCommon.configure(30, true);
        }
        break;

      case RppgMethod.startVideo:
        {
          await rppgCommon.startVideo();
        }
        break;

      case RppgMethod.startAnalysis:
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
              sdnns.value = parseStringToDouble(eventData.sdnns.toString());
              statusMessage.value = eventData.statusMessage;
              progressPercentage.value = eventData.progressPercentage;

              avgBpm.value = '${eventData.avgBpm}';
              avgO2SaturationLevel.value = '${eventData.avgO2SaturationLevel}';
              avgRespirationRate.value = '${eventData.avgRespirationRate}';

              bloodPressureSys.value = "${eventData.bloodPressure.systolic}";
              bloodPressureDia.value = "${eventData.bloodPressure.diastolic}";

              bloodPressureStatus.value = eventData.bloodPressureStatus;
              stressStatus.value = eventData.stressStatus;

              isMoveWarning.value = eventData.isMovingWarning;

              if (checkIfGotAllValues()) {
                checkLastValues();
              }
            });
          } on PlatformException {
            statusMessage.value = 'Failed startAnalysis.';
          }
        }
        break;

      case RppgMethod.stopAnalysis:
        {
          await rppgCommon.stopAnalysis();
        }
        break;

      case RppgMethod.stopVideo:
        {
          try {
            await rppgCommon.stopVideo();
          } on PlatformException {
            statusMessage.value = 'Failed stopVideo.';
          }

          break;
        }

      case RppgMethod.meshColor:
        {
          await rppgCommon.meshColor();
        }
        break;

      case RppgMethod.cleanMesh:
        {
          await rppgCommon.cleanMesh();
        }
        break;

      default:
        {}
        break;
    }
  }

  void resetToInitial() {
    timerValue.value = 60;
    statusMessage.value = 'Analysis Done!!!';
    isAnalysisDone.value = true;
    stopCircularAnimation();
    invokeMethod(RppgMethod.stopAnalysis);
    invokeMethod(RppgMethod.cleanMesh);
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

    if ((dataTextValue == "") ||
        (dataTextValue == '0.0') ||
        (dataTextValue == '0.00') ||
        (dataTextValue == '0') ||
        (dataTextValue.toLowerCase() == "no_data") ||
        (dataTextValue.toLowerCase() == "nodata")) {
      isEmptyValue = true;
    } else {
      isEmptyValue = false;
    }

    return isEmptyValue;
  }

  /// Update the UI button Text
  @override
  void updateButtonTitle() {
    switch (rppgCommonState.value) {
      case RppgState.initial:
        {
          buttonTitle.value = "Ask for Permissions";
        }
        break;
      case RppgState.prepared:
        {
          buttonTitle.value = "Start Video Session";
        }
        break;
      case RppgState.videoStarted:
        {
          buttonTitle.value = "Start Scanning";
        }
        break;
      case RppgState.analysisRunning:
        {
          buttonTitle.value = "Stop Scanning";
        }
        break;
      case RppgState.fail:
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

  /// Circular Animation
  /// Start animation
  void startCircularAnimation() {
    animationController.repeat();
  }

  /// Stop animation
  void stopCircularAnimation() {
    animationController.stop();
  }
}

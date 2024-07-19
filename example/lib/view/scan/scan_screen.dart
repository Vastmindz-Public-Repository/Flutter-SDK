import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rppg_common/constants/rppg_constants.dart';
import 'package:rppg_common/rppg_common.dart';
import 'package:rppg_common_example/controller/invoke_methods_controller.dart';
import 'package:rppg_common_example/res/assets/image_assets.dart';
import 'package:rppg_common_example/res/rppg_method/rppg_method.dart';
import 'package:rppg_common_example/res/rppg_state/rppg_state.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final invokeMethodController = Get.put(InvokeMethodController());

  Color blueColor = const Color(0xFF1660b7);
  double? fontSizeVar = 14.00;
  Color? fontColorVar = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    /// Initializing the GetX Controller and Opening the camera
    initialStep();
  }

  /// Startup of the app
  Future<void> initialStep() async {
    /// Animation Controller
    invokeMethodController.animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    invokeMethodController.startCircularAnimation();

    /// Open the Camera
    invokeMethodController.startWholeSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Obx(
        () => Stack(
          children: [
            /// Black Empty Container
            Container(
              color: Colors.black,
            ),

            /// Camera View
            Positioned(
                height: Get.height,
                width: Get.width,
                child: const RppgCameraView()),

            /// Full Bottom View
            Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// Moving Warning
                    if (invokeMethodController.isMoveWarning.value == true)
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: 33,
                        color: Colors.redAccent,
                        child: Text(
                          "Please keep your face in front of camera",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: fontColorVar,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.00),
                        ),
                      ),

                    /// SDK status message banner
                    if ((invokeMethodController.isMoveWarning.value == false) &&
                        (invokeMethodController.statusMessage.value
                            .toString()
                            .isNotEmpty))
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: 33,
                        color: (invokeMethodController.statusMessage.value
                                    .toString() ==
                                "Analysis Done!!!")
                            ? Colors.green
                            : blueColor,
                        child: Text(
                          invokeMethodController.statusMessage.value.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: fontColorVar,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.00),
                        ),
                      ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// Result Progress Bar
                    if (invokeMethodController.scanResultVisibility.isTrue)
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        // height: 150,
                        margin: const EdgeInsets.only(top: 12.0, bottom: 5.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildItem(
                                  invokeMethodController.avgBpm.value,
                                  ImageAssets.heartRateReadingImage,
                                  ImageAssets.heartRateGreenImage,
                                  "BPM"),
                              buildItem(
                                  invokeMethodController
                                      .avgRespirationRate.value,
                                  ImageAssets.respirationRateReadingImage,
                                  ImageAssets.respirationRateGreenImage,
                                  "RR"),
                              buildItem(
                                  invokeMethodController.bloodPressureSys.value,
                                  ImageAssets.bloodPressureReadingImage,
                                  ImageAssets.bloodPressureGreenImage,
                                  "BP",
                                  secondDataTextValue: invokeMethodController
                                      .bloodPressureDia.value),
                              buildItem(
                                  invokeMethodController.stressStatus.value,
                                  ImageAssets.stressIndexReadingImage,
                                  ImageAssets.stressIndexGreenImage,
                                  "SI"),
                              buildItem(
                                  invokeMethodController
                                      .avgO2SaturationLevel.value,
                                  ImageAssets.spo2ReadingImage,
                                  ImageAssets.spo2GreenImage,
                                  "SPO2"),
                              buildItem(
                                  invokeMethodController.sdnns.value,
                                  ImageAssets.hrvReadingImage,
                                  ImageAssets.hrvGreenImage,
                                  "HRV"),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 10,
                    ),

                    /// Button View
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: Column(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(blueColor),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: Text(
                              (invokeMethodController.rppgCommonState.value ==
                                      RppgState.analysisRunning)
                                  ? "Stop Scanning"
                                  : invokeMethodController.buttonTitle.value,
                              style: const TextStyle(
                                  fontFamily: 'outfit_regular',
                                  color: Colors.white),
                            ),
                            onPressed: () {
                              if (invokeMethodController
                                      .rppgCommonState.value ==
                                  RppgState.analysisRunning) {
                                try {
                                  if (invokeMethodController.timer != null) {
                                    invokeMethodController.timer!.cancel();
                                  }
                                  invokeMethodController.checkLastValues();
                                } catch (e) {
                                  invokeMethodController.checkLastValues();
                                }

                                invokeMethodController.statusMessage.value =
                                    'Scanning stopped';
                              } else {
                                invokeMethodController.startSession();
                                invokeMethodController.startCircularAnimation();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Circular data widget item
  Widget buildItem(
      String dataTextValue, String firstImage, String secondImage, String label,
      {String? secondDataTextValue = ""}) {
    bool isEmptyValue = invokeMethodController.checkEmptyValue(dataTextValue);

    return Column(
      children: [
        isEmptyValue
            ? const Text(
                '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'outfit_regular',
                  color: Colors.white,
                  fontSize: 13.0,
                ),
              )
            : SizedBox(
                width: 60,
                child: Text(
                  '$dataTextValue ${(secondDataTextValue != "") ? ', $secondDataTextValue' : ""}',
                  textAlign: TextAlign.center,
                  textScaler:
                      TextScaler.linear(dataTextValue.length > 6 ? 0.8 : 1),
                  softWrap: true,
                  style: const TextStyle(
                      fontFamily: 'outfit_regular',
                      color: Colors.white,
                      fontSize: 13.0,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.3, vertical: 4.0),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(2.0),
                child: Image.asset(
                  isEmptyValue ? firstImage : secondImage,
                  width: 42.0,
                  height: 42.0,
                ),
              ),
              Visibility(
                visible: isEmptyValue ? true : false,
                child: Positioned.fill(
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(invokeMethodController.animationController),
                    child: Image.asset(
                      ImageAssets.circleAnimImage,
                      width: 42.0,
                      height: 42.0,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: isEmptyValue ? false : true,
                child: Container(
                  margin: const EdgeInsets.only(left: 25.0),
                  child: Image.asset(
                    ImageAssets.blueTickImage,
                    width: 16.0,
                    height: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'outfit_regular',
            color: Colors.white,
            fontSize: 13.0,
          ),
        ),
      ],
    );
  }

  void showSnackbar() {
    const snackBar = SnackBar(
      content: Text('Yay! A SnackBar!'),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    //stop camera video
    invokeMethodController.invokeMethod(RppgMethod.stopVideo);

    invokeMethodController.resetToInitial();
    // Animation controller
    //invokeMethodController.animationController.dispose();
    // GetX Controller
    Get.delete<InvokeMethodController>();
    // TODO: implement dispose
    super.dispose();
  }
}

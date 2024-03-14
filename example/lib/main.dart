import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rppg_common/rppg_common.dart';
import 'controller/invoke_methods_controller.dart';

void main() {
  runApp(const GetMaterialApp(home: RPPGExampleApp()));
}

class RPPGExampleApp extends StatefulWidget {
  const RPPGExampleApp({super.key});

  @override
  State<RPPGExampleApp> createState() => _RPPGExampleAppState();
}

class _RPPGExampleAppState extends State<RPPGExampleApp>
    with SingleTickerProviderStateMixin {
  late final InvokeMethodController invokeMethodController;

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
    /// Initialization of GetX Controller
    try {
      invokeMethodController = Get.find<InvokeMethodController>();
      Get.delete<InvokeMethodController>();
      invokeMethodController = Get.put(InvokeMethodController());
    } catch (e) {
      invokeMethodController = Get.put(InvokeMethodController());
    }

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
            const RppgCameraView(),

            /// Full Bottom View
            Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// Moving Warning
                    if (invokeMethodController.isMoveWarning.value == true) Container(
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
                    if ((invokeMethodController.isMoveWarning.value == false) && (invokeMethodController.statusMessage.value
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
                                  "heart_rate_reading",
                                  "heart_rate_green",
                                  "progressHeart",
                                  "BPM"),
                              buildItem(
                                  invokeMethodController
                                      .avgRespirationRate.value,
                                  "respiretion_rate_reading",
                                  "respiration_rate_green",
                                  "progressResperation",
                                  "RR"),
                              buildItem(
                                  invokeMethodController.bloodPressureSys.value,
                                  "bp_reading",
                                  "blood_pressure_green",
                                  "progressBP",
                                  "BP",
                                  secondDataTextValue: invokeMethodController
                                      .bloodPressureDia.value),
                              buildItem(
                                  invokeMethodController.stressStatus.value,
                                  "stress_index_reading",
                                  "stress_index_green",
                                  "progressStress",
                                  "SI"),
                              buildItem(
                                  invokeMethodController
                                      .avgO2SaturationLevel.value,
                                  "spo2_reading",
                                  "spo2_green",
                                  "progressOxy",
                                  "SPO2"),
                              buildItem(
                                  invokeMethodController.sdnns.value,
                                  "hrv_reading",
                                  "hrv_green",
                                  "progressHRV",
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
                                      "analysisRunning")
                                  ? "Stop Scanning"
                                  : invokeMethodController.buttonTitle.value,
                              style: const TextStyle(
                                  fontFamily: 'outfit_regular',
                                  color: Colors.white),
                            ),
                            onPressed: () {
                              if (invokeMethodController
                                      .rppgCommonState.value ==
                                  "analysisRunning") {

                                try {
                                  if (invokeMethodController.timer != null) {
                                    invokeMethodController.timer!.cancel();
                                  }
                                  invokeMethodController.checkLastValues();

                                } catch (e) {
                                  invokeMethodController.checkLastValues();
                                }

                                invokeMethodController.statusMessage.value = 'Scanning stopped';

                              } else {
                                invokeMethodController.startCircularAnimation();
                                invokeMethodController.startSession();
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
  Widget buildItem(String dataTextValue, String firstImage, String secondImage,
      String progressId, String label,
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
                textScaler: TextScaler.linear(dataTextValue.length > 6 ? 0.8 : 1),
                  softWrap: true,
                  style: const TextStyle(
                    fontFamily: 'outfit_regular',
                    color: Colors.white,
                    fontSize: 13.0,
                      overflow: TextOverflow.ellipsis
                  ),
                ),
            ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.3, vertical: 4.0),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(2.0),
                child: Image.asset(
                  isEmptyValue
                      ? 'lib/assets/$firstImage.png'
                      : 'lib/assets/$secondImage.png',
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
                      'lib/assets/circle_anim.png',
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
                    'lib/assets/blue_tick.png',
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

  void showSnacbar() {
    const snackBar = SnackBar(
      content: Text('Yay! A SnackBar!'),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    // Animation controller
    invokeMethodController.animationController.dispose();
    // GetX Controller
    Get.delete<InvokeMethodController>();
    // TODO: implement dispose
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rppg_common_example/res/routes/routes_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3),
            () => Get.offNamed(RouteName.scanScreen));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text("Rppg Flutter SDK", textAlign: TextAlign.center,)),
    );
  }
}

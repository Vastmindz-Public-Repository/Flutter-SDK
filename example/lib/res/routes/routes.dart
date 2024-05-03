

import 'package:get/get.dart';
import 'package:rppg_common_example/controller/binding/invoke_methods_binding.dart';
import 'package:rppg_common_example/res/routes/routes_name.dart';
import 'package:rppg_common_example/view/scan/scan_screen.dart';
import 'package:rppg_common_example/view/splash_screen.dart';


class AppRoutes {

  static appRoutes() => [
    GetPage(
      name: RouteName.splashScreen,
      page: () => const SplashScreen() ,
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade ,
    ) ,
    GetPage(
      name: RouteName.scanScreen,
      page: () => const ScanScreen() ,
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade ,
      binding: InvokeMethodsBinding(),
    )
  ];

}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rppg_common_example/res/routes/routes.dart';
import 'package:rppg_common_example/res/routes/routes_name.dart';

void main() {
  runApp(
      GetMaterialApp(
        initialRoute: RouteName.splashScreen,
        getPages: AppRoutes.appRoutes(),
      ),
  );
}

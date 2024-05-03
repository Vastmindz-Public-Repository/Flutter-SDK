import 'package:get/get.dart';
import 'package:rppg_common_example/controller/invoke_methods_controller.dart';

class InvokeMethodsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => InvokeMethodController());
  }
}
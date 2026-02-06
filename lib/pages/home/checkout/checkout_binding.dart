import 'package:get/get.dart';

import 'package:smartfixTech/pages/home/checkout/checkout_controller.dart';

class CheckoutBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}

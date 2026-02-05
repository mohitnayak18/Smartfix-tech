import 'package:get/get.dart';

import 'package:smartfixapp/pages/home/checkout/checkout_controller.dart';

class CheckoutBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}

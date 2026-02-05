import 'package:get/get.dart';
import 'package:smartfixapp/pages/store/store_controller.dart';

class StoreBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreController>(() => StoreController());
  }
}
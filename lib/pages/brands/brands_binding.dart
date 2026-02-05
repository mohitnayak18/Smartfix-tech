import 'package:get/get.dart';
import 'package:smartfixapp/pages/brands/brands_controller.dart';

class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BrandsController());
  }
}

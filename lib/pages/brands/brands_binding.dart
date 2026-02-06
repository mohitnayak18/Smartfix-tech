import 'package:get/get.dart';
import 'package:smartfixTech/pages/brands/brands_controller.dart';

class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BrandsController());
  }
}

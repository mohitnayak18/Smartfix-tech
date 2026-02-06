import 'package:get/get.dart';
import 'package:smartfixTech/pages/product_screen/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductController());
  }
}

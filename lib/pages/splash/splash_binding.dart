import 'package:get/get.dart';
import 'package:smartfixTech/pages/pages.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }
}

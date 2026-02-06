import 'package:get/get.dart';
import 'package:smartfixTech/pages/home/home.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut(() => HomeController(), fenix: true);
  }
}

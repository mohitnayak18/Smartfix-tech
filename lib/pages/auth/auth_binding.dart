import 'package:get/get.dart';
import 'package:smartfixTech/pages/auth/auth.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}

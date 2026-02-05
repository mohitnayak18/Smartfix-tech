import 'package:get/get.dart';
import 'package:smartfixapp/pages/auth/auth.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}

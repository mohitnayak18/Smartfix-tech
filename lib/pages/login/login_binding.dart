import 'package:get/get.dart';
import 'package:smartfixapp/pages/login/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController(), permanent: true);
  }
}

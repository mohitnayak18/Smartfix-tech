import 'package:get/get.dart';
import 'package:smartfixapp/pages/onboarding/onboarding.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController());
  }
}

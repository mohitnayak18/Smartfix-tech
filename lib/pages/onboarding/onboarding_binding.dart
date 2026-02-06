import 'package:get/get.dart';
import 'package:smartfixTech/pages/onboarding/onboarding.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController());
  }
}

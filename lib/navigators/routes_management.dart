
import 'package:get/get.dart';
import 'package:smartfixTech/navigators/navigators.dart';

class RouteManagement {
  /// Go to the splash screen.
  static void goToSplash() {
    Get.offNamed<void>(Routes.splash);
  }

  /// Go to the splash screen.
  static void goToHome() {
    Get.offNamed<void>(Routes.home);
  }

  /// Go to the onboarding screen.
  static void goOffAllboarding() {
    Get.offAllNamed<void>(Routes.onboarding);
  }

  /// Go off all Home Screen
  static void goOffAllHomScreen() {
    Get.offAllNamed<void>(Routes.home);
  }

  /// Go to the login screen.
  static void goToLogin() {
    Get.offAllNamed<void>(Routes.login);
  }
  
  /// Go to the otp screen.
  static void goToOtp(String phone) {
    Get.toNamed<void>(Routes.auth, arguments: phone);
  }

  /// Go to the sub catagory screen.
  static void goToSubCatagoryScreen(Map<String, dynamic> args) {
    Get.toNamed<void>(Routes.subCatagory, arguments: args);
  }

  /// Go to the checkout screen.
  static void goToCheckout() {
    Get.toNamed<void>(Routes.checkoutScreen);
  }
  static void goToBookingScreen() {
    Get.toNamed<void>(Routes.bookingScreen);
   }
  static void goToOrderHistory() {
    Get.toNamed<void>(Routes.orderHistory);
   }
   static void goToCartScreen() {
    Get.toNamed<void>(Routes.cart);
   }
}

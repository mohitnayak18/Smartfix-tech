import 'package:get/get.dart';
import 'package:smartfixTech/pages/cart/cart.dart';

import 'package:smartfixTech/pages/home/home.dart';
import 'package:smartfixTech/pages/onboarding/onboarding.dart';
import 'package:smartfixTech/pages/pages.dart';
import 'package:smartfixTech/pages/auth/auth.dart';
import 'package:smartfixTech/pages/profile/profile.dart';


part 'app_routes.dart';

class AppPages {
  static final transitionDuration = const Duration(milliseconds: 350);

  static const initial = Routes.splash;

  static final pages = [
    GetPage(
      name: _Paths.splash,
      transitionDuration: transitionDuration,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.onboarding,
      transitionDuration: transitionDuration,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.login,
      transitionDuration: transitionDuration,
      page: () => LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.auth,
      transitionDuration: transitionDuration,
      page: () {
        final args = Get.arguments;
        print(' OTP screen args: $args'); // Debug log

        final verificationId =
            (args as Map<String, dynamic>?)?['verificationId'];
        final phoneNumber = (args)?['phoneNumber'];

        if (verificationId == null || phoneNumber == null) {
          print(' Missing arguments! Redirecting back to login.');
          return LoginView(); // fallback
        }

        return OtpScreen(
          // verificationId: verificationId,
          // phoneNumber: phoneNumber,
        );
      },

      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.home,
      transitionDuration: transitionDuration,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.profile,
      transitionDuration: transitionDuration,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/orderDetails',
      page: () => OrderDetailsScreen(orderId: Get.arguments['orderId'], orderNumber: Get.arguments['orderNumber']),
      binding: CartBinding(), // 🔥 IMPORTANT
    ),
    // GetPage(
    //   name: _Paths.bookingScreen,
    //   transitionDuration: transitionDuration,
    //   page: () => BookingScreen(),
    //   binding: BookingBinding(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: '/order-success',
    //   page: () {
    //     final arguments = Get.arguments;
    //     return OrderSuccessScreen(orderData: arguments);
    //   },
    // ),
  ];
}

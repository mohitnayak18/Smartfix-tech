part of 'app_pages.dart';

abstract class Routes {
  static const splash = _Paths.splash;
  static const profile = _Paths.profile;
  static const onboarding = _Paths.onboarding;
  static const home = _Paths.home;
  static const login = _Paths.login;
   static const register = _Paths.register;
  static const auth = _Paths.auth;
  static const subCatagory = _Paths.subCatagory;
  static const checkoutScreen = _Paths.checkoutScreen;
  static const bookingScreen = _Paths.bookingScreen;
  static const orderHistory = _Paths.orderHistory;
  static const cart = _Paths.cart;
}

abstract class _Paths {
  static const splash = '/splash-screen';
  static const profile = '/profile-screen';
  static const onboarding = '/onboarding-screen';
  static const home = '/home-screen';
  static const login = '/login-view';
  static const auth = '/auth_screen';
  static const register = '/register-view';
  static const subCatagory = '/sub-catagory-screen';
  static const checkoutScreen = '/checkout-screen';
  static const bookingScreen = '/booking-screen';
  static const orderHistory = '/order-history';
  static const cart = '/cart-screen';
}

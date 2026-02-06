import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/navigators/app_pages.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ----------------------------
  // Phone Data
  // ----------------------------
  String countryCode = '+91';
  String phoneNumber = '';
  String verificationId = '';

  // 
  // ----------------------------
  bool isPhoneValid = false;
  bool isLoading = false;

  void setPhoneData(String code, String number) {
    countryCode = code;
    phoneNumber = number;
    isPhoneValid = number.length == 10;

    update(['login_screen']);
  }

  String get fullPhoneNumber => '$countryCode$phoneNumber';

  
  Future<void> verifyPhoneNumber() async {
    if (!isPhoneValid || isLoading) return;

    isLoading = true;
    update(['login_screen']);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          // await _auth.signInWithCredential(credential);
          // Get.offAllNamed(Routes.home);
        },

        
        verificationFailed: (FirebaseAuthException e) {
          isLoading = false;
          update(['login_screen']);
          Get.snackbar('Verification Failed', e.message ?? 'Unknown error');
        },

        codeSent: (String id, int? resendToken) {
          verificationId = id;
          isLoading = false;
          update(['login_screen']);

          Get.toNamed(
            Routes.auth,
            arguments: {
              'phoneNumber': fullPhoneNumber,
              'verificationId': verificationId, 
            },
          );
        },

        codeAutoRetrievalTimeout: (String id) {
          verificationId = id;
        },
      );
    } catch (e) {
      isLoading = false;
      update(['login_screen']);
      Get.snackbar('Error', e.toString());
    }
  }
}

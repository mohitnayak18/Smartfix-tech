import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixapp/api_calls/services/common_service.dart';
import 'package:smartfixapp/navigators/app_pages.dart';
import 'package:smartfixapp/utils/utils.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _commonService = Get.find<CommonService>();
  final otpController = TextEditingController();
  final isLoading = false.obs;

  late String verificationId;

  @override
  void onInit() {
    super.onInit();
    verificationId = Get.arguments['verificationId'];
  }

  Future<void> verifyOtp() async {
    final smsCode = otpController.text.trim();

    if (smsCode.length != 6) return;

    isLoading.value = true;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await auth.signInWithCredential(credential).then((userCredential) {
        final user = userCredential.user;
        var uid = user?.uid;
      
        _commonService.saveValue(AppConstants.token, uid);
        Get.offAllNamed(Routes.home);
      });
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    } finally {
      isLoading.value = false;
    }
  }
}

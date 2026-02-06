import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:smartfixTech/pages/auth/auth_controller.dart';
import 'package:smartfixTech/theme/dimens.dart';
import 'package:smartfixTech/utils/asset_constants.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({super.key});

  final AuthController controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args == null || args['phoneNumber'] == null) {
      Future.microtask(() => Get.back());
      return const SizedBox.shrink();
    }

    final String phoneNumber = args['phoneNumber'];

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // ✅ important
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Dimens.edgeInsets25,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                Lottie.asset(AssetConstants.authscreen, height: 220),

                Dimens.boxHeight20,

                Text(
                  'Phone Verification',
                  style: TextStyle(
                    fontSize: Dimens.twentyFour,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                Dimens.boxHeight10,

                Text(
                  'Enter the 6-digit code sent to\n$phoneNumber',
                  textAlign: TextAlign.center,
                ),

                Dimens.boxHeight30,

                Pinput(
                  controller: controller.otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  validator: (v) {
                    if (v == null || v.length != 6) {
                      return 'Enter valid OTP';
                    }
                    return null;
                  },
                ),

                Dimens.boxHeight30,

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: Dimens.fiftyFive,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        disabledBackgroundColor: const Color(
                          0xFF0D9488,
                        ).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => HomeScreen(),
                              //   ),
                              // );
                              if (_formKey.currentState!.validate()) {
                                controller.verifyOtp();
                              }
                            },
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),

                Dimens.boxHeight10,

                TextButton(
                  onPressed: Get.back,
                  child: const Text('Edit phone number?',style: TextStyle(color: Colors.teal),),

                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

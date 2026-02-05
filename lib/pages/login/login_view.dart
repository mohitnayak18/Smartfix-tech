import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:smartfixapp/pages/login/login_controller.dart';
import 'package:smartfixapp/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:smartfixapp/utils/asset_constants.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<LoginController>(
        id: 'login_screen',
        builder: (controller) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: Dimens.edgeInsets15,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Dimens.boxHeight30,
                    Lottie.asset(
                      AssetConstants.loginpage,
                      height: Dimens.twoHundredFifty,
                      fit: BoxFit.contain,
                    ),
                    Dimens.boxHeight10,
                    Text(
                      'Enter your phone number',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimens.twentyFour,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Dimens.boxHeight20,

                    /// PHONE FIELD
                    IntlPhoneField(
                      initialCountryCode: 'IN',
                      disableLengthCheck: true,
                      dropdownIconPosition: IconPosition.trailing,
                      showDropdownIcon: true,
                      flagsButtonPadding: const EdgeInsets.only(left: 12),

                      decoration: InputDecoration(
                        hintText: 'Enter phone number',
                        filled: true,
                        fillColor: Colors.grey.shade100,

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.2,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.6),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),

                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.red),
                        ),

                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),

                      dropdownTextStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),

                      pickerDialogStyle: PickerDialogStyle(
                        backgroundColor: Colors.white,
                        searchFieldInputDecoration: InputDecoration(
                          hintText: 'Search country',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      onChanged: (phone) {
                        controller.setPhoneData(
                          phone.countryCode,
                          phone.number,
                        );
                      },

                      validator: (phone) {
                        if (phone == null || phone.number.length != 10) {
                          return 'Enter valid phone number';
                        }
                        return null;
                      },
                    ),

                    Dimens.boxHeight20,

                    /// SEND OTP BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: Dimens.fiftyFive,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: controller.isPhoneValid
                            ? () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => OtpScreen(),
                                //   ),
                                // );
                                if (_formKey.currentState!.validate()) {
                                  controller.verifyPhoneNumber();
                                }
                              }
                            : null,
                        child: controller.isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Text('Send OTP'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

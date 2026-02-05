import 'package:smartfixapp/theme/dimens.dart';
import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    //required this.hintstyle,
    //required this.textfilestyle,
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    required this.textFieldName,
    required this.validator,
    required this.suffixIcon,
    required this.obscureText,
    required this.maxLength,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  //final TextStyle hintstyle;
  final String hintText;
  final String textFieldName;
  //final String textfilestyle;
  final String? Function(String? value)? validator;
  final Widget suffixIcon;
  final bool obscureText;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            textFieldName,
            style: TextStyle(color: Theme.of(context).primaryColor,
                fontSize: Dimens.twelve),
          ),
        ),
        Dimens.boxHeight5,
        SizedBox(
          child: TextFormField(
            maxLength: maxLength,
            controller: controller,
            style: TextStyle(fontSize: Dimens.fourteen),
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            validator: validator,
            obscureText: obscureText,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              counterText: "",
              filled: true,
              fillColor: Colors.white,
              focusColor: Theme.of(context).primaryColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.0),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.0),
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.0),
                borderRadius: BorderRadius.circular(30),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1.0),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1.0),
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey, fontSize: Dimens.twelve),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixapp/theme/dimens.dart';
import 'package:smartfixapp/theme/styles.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.text, required this.title});

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Styles.white14.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.adaptive.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Container(
            color: Colors.white,
            padding: Dimens.edgeInsets16_16_16_0,
            height: Get.height,
            width: Get.width,
            child: SingleChildScrollView(
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }
}

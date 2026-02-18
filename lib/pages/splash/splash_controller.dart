import 'dart:async';

import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/services/services.dart';
import 'package:smartfixTech/navigators/navigators.dart';
import 'package:smartfixTech/utils/utils.dart';

class SplashController extends GetxController {
  final _commonService = Get.find<CommonService>();

  @override
  void onInit() {
    Timer(const Duration(seconds: 6), () async {
      final accessKey =
          await _commonService.getValue(AppConstants.token) as String? ?? '';

      if (accessKey.isNotEmpty) {
        RouteManagement.goOffAllHomScreen();
      } else {
        RouteManagement.goOffAllboarding();
      }
    });
    super.onInit();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:smartfixTech/theme/theme.dart';
import 'package:smartfixTech/widgets/widgets.dart';

abstract class Utility {
  static void printDLog(String message) {
    Logger().d('${'appname'.tr}: $message');
  }

  /// Print info log.
  ///
  /// [message] : The message which needed to be print.
  static void printILog(dynamic message) {
    Logger().i('${'appname'.tr}: $message');
  }

  /// Print info log.
  ///
  /// [message] : The message which needed to be print.
  static void printLog(dynamic message) {
    Logger().log(Level.info, message);
  }

  /// Print error log.
  ///
  /// [message] : The message which needed to be print.
  static void printELog(String message) {
    Logger().e('${'appname'.tr}: $message');
  }

  /// Close any open dialog.
  static void closeDialog() {
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }

  /// Number Format
  static String numberFormat(num price) {
    return NumberFormat('#,##,###.##', 'en_US').format(price);
  }

  /// Show no internet dialog if there is no
  /// internet available.
  static Future<void> showNoInternetDialog() async {
    await Get.dialog<void>(const NoInternetWidget(), barrierDismissible: false);
  }

  /// Show loader
  static void showLoader() async {
    await Get.dialog<void>(
      const Center(child: CircularProgressIndicator.adaptive()),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(.3),
    );
  }

  /// Returns true if the internet connection is available.
  static Future<bool> isNetworkAvailable() async =>
      await InternetConnectionChecker().hasConnection;

  /// Show Error bottomsheet.
  ///
  static void showErrorBottomSheet({
    required String? message,
    Function()? onPress,
    bool isDismissible = true,
  }) async {
    await Get.bottomSheet<void>(
      Container(
        padding: Dimens.edgeInsets30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$message',
              style: Styles.blackBold16.copyWith(
                color: const Color.fromRGBO(235, 87, 87, 1),
              ),
            ),
            Dimens.boxHeight10,
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(255, 206, 206, 1),
      isScrollControlled: true,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
    ).timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        if (Get.isBottomSheetOpen!) {
          Get.back<void>();
        }
      },
    );
  }

  /// Show Success bottomsheet.
  ///
  static void showSuccessBottomSheet({
    required String? message,
    Function()? onPress,
    bool isDismissible = true,
  }) async {
    await Get.bottomSheet<void>(
      Container(
        padding: Dimens.edgeInsets30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$message',
              style: Styles.blackBold16.copyWith(color: Colors.black),
            ),
            Dimens.boxHeight10,
          ],
        ),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
    ).timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        if (Get.isBottomSheetOpen!) {
          Get.back<void>();
        }
      },
    );
  }
}

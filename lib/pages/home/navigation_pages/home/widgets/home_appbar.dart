import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/models/appbar.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/cart/cart_view.dart';
import 'package:smartfixTech/pages/home/widgets/appcarticon.dart';
import 'package:smartfixTech/theme/dimens.dart';

class Homeappbar extends StatelessWidget {
  const Homeappbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme
    
    return TAppbar(
      backgroundColor: theme.primaryColor, // Optional: Add to TAppbar
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              'smartfixnm'.tr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          Dimens.boxHeight2, // Consider using boxHeight instead of boxWidth for vertical spacing
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              'appBarTitle'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Appcarticon(
          onPressed: () {
            Get.to(
              () => CartView(),
              binding: BindingsBuilder(() {
                Get.put(CartController());
              }),
            );
          },
          iconColor: theme.colorScheme.onPrimary,
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';

class Appcarticon extends StatelessWidget {
  const Appcarticon({
    super.key,
    required this.onPressed,
    required this.iconColor,
  });

  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.shopping_bag, color: iconColor),
        ),

        /// 🔥 Badge
        Positioned(
          right: -2,
          top: -2,
          child: Obx(() {
            final itemCount = cartController.cartItems.length;

            if (itemCount == 0) {
              return const SizedBox(); // Hide badge if empty
            }

            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(100),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  itemCount.toString(), // 🔥 Only number (correct UI)
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

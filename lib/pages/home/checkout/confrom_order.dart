import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smartfixTech/api_calls/models/order_model.dart';
import 'package:smartfixTech/pages/order/order_details.dart';
import 'package:smartfixTech/pages/home/home_screen.dart';
import 'package:smartfixTech/theme/dimens.dart';
import 'package:smartfixTech/utils/asset_constants.dart';

class OrderSuccessView extends StatelessWidget {
  final OrderModel? order;
  final String orderId;
  final String orderNumber;

  const OrderSuccessView({
    super.key,
    required this.orderId,
    this.order,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                AssetConstants.checkmark,
                height: Dimens.twoHundredFifty,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                "Order Placed Successfully!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Payment will be collected after service completion.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Get.to(
                    () => OrderDetailsScreen(
                      orderId: order?.orderId ?? orderId,
                      orderNumber: order?.orderNumber ?? orderNumber,
                    ),
                  );
                },
                child: const Text(
                  "View My Orders",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



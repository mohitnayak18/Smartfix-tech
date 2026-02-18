import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/home/checkout/checkout_view.dart';
import 'package:smartfixTech/theme/dimens.dart';

class CheckoutBar extends StatelessWidget {
  final CartController cartCtrl;
  const CheckoutBar({super.key, required this.cartCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cartCtrl.cartItems.isEmpty) return const SizedBox();

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Breakdown Title
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "PRICE DETAILS",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price Breakdown
                _buildPriceDetailRow(
                  "Total MRP",
                  cartCtrl.subtotal.value,
                  isTotal: true,
                ),
                _buildPriceDetailRow(
                  "Platform Fee",
                  cartCtrl.platformFee.value,
                  showCheck: true,
                ),
                _buildPriceDetailRow(
                  "Shipping Fee",
                  cartCtrl.shippingFee.value,
                  showCheck: true,
                ),
                if (cartCtrl.gstAmount.value > 0)
                  _buildPriceDetailRow(
                    "GST & Charges",
                    cartCtrl.gstAmount.value,
                    showCheck: true,
                  ),
                _buildPriceDetailRow(
                  "Discount",
                  -cartCtrl.discount.value,
                  isDiscount: true,
                  showCheck: true,
                ),

                const Divider(height: 20),

                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "₹${NumberFormat('#,##0').format(cartCtrl.totalPrice.value)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Savings
                if (cartCtrl.discount.value > 0)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.savings,
                          size: 14,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "You'll save ₹${NumberFormat('#,##0').format(cartCtrl.discount.value)} on this order!",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Delivery Estimate
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: Colors.teal.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Delivery by",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _getDeliveryDate(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: cartCtrl.totalPrice.value > 0
                        ? () {
                            // Validate address before navigating
                            if (cartCtrl.selectedAddress.isEmpty) {
                              Get.snackbar(
                                "Address Required",
                                "Please select a delivery address",
                                backgroundColor: Colors.white,
                                colorText: Colors.black,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                              return;
                            }

                            // Navigate to checkout - GetX handles the data automatically
                            Get.to(() => const CheckoutView());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Text(
                      "Continue".tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Terms
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "By continuing, you agree to our Terms of Use & Privacy Policy".tr,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPriceDetailRow(
    String label,
    double value, {
    bool isDiscount = false,
    bool showCheck = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showCheck)
                Icon(Icons.check_circle, size: 13, color: Colors.teal.shade600),
              if (showCheck) const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isTotal ? Colors.black87 : Colors.grey.shade700,
                  fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            "${value < 0 ? '-' : ''}₹${NumberFormat('#,##0').format(value.abs())}",
            style: TextStyle(
              fontSize: 12,
              color: isDiscount ? Colors.teal.shade600 : Colors.black87,
              fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getDeliveryDate() {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 0));
    return DateFormat('MMM dd, EEEE').format(deliveryDate);
  }
}
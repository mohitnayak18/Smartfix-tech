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
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.shade300,
          //     blurRadius: 8,
          //     offset: const Offset(0, -2),
          //   ),
          // ],
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

                // Location warning

                // oono
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
                            if (cartCtrl.cartItems.isEmpty) {
                              Get.snackbar(
                                "Cart Empty",
                                "Add services before checkout",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            // if (cartCtrl.distanceInKm.value == 0) {
                            // Get.snackbar(
                            //   "Location Required",
                            //   "Please set location to calculate shipping",
                            //   backgroundColor: Colors.orange,
                            //   colorText: Colors.white,
                            // );
                            // _showLocationDialog();
                            //   return;
                            // }
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
                      "continue".tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Dimens.boxHeight10,

                // Terms
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "PrivacyPolicy".tr,
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

  // void _showLocationDialog() {
  //   final distanceController = TextEditingController(
  //     text: Get.find<CartController>().distanceInKm.value > 0
  //         ? Get.find<CartController>().distanceInKm.value.toStringAsFixed(1)
  //         : '',
  //   );

  //   Get.dialog(
  //     Dialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       child: Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               "Set Location",
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //             ),
  //             const SizedBox(height: 10),
  //             const Text(
  //               "Enter distance from service center (in km):",
  //               style: TextStyle(fontSize: 13, color: Colors.grey),
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: distanceController,
  //               keyboardType: TextInputType.numberWithOptions(decimal: true),
  //               decoration: InputDecoration(
  //                 hintText: "e.g., 5.5",
  //                 prefixIcon: const Icon(Icons.location_on, size: 20),
  //                 suffixText: "km",
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                   borderSide: BorderSide(color: Colors.blue.shade700),
  //                 ),
  //                 contentPadding: const EdgeInsets.symmetric(
  //                   horizontal: 12,
  //                   vertical: 12,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             const Text(
  //               "Shipping Rates:",
  //               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
  //             ),
  //             const SizedBox(height: 6),
  //             Text(
  //               "• 0-5 km: Free\n• 5-10 km: ₹50\n• 10-20 km: ₹100\n• 20-30 km: ₹150\n• 30+ km: ₹150 + ₹10/km extra",
  //               style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
  //             ),
  //             const SizedBox(height: 20),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: TextButton(
  //                     onPressed: () => Get.back(),
  //                     style: TextButton.styleFrom(
  //                       foregroundColor: Colors.grey.shade700,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                         side: BorderSide(color: Colors.grey.shade300),
  //                       ),
  //                       padding: const EdgeInsets.symmetric(vertical: 10),
  //                     ),
  //                     child: const Text("Cancel"),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       final distance = double.tryParse(
  //                         distanceController.text,
  //                       );
  //                       if (distance != null && distance >= 0) {
  //                         Get.find<CartController>().updateDistance(distance);
  //                         Get.back();
  //                         Get.snackbar(
  //                           "Location Updated",
  //                           "Shipping fee calculated for ${distance.toStringAsFixed(1)} km",
  //                           backgroundColor: Colors.teal,
  //                           colorText: Colors.white,
  //                         );
  //                       } else {
  //                         Get.snackbar(
  //                           "Invalid Distance",
  //                           "Please enter a valid distance",
  //                           backgroundColor: Colors.red,
  //                           colorText: Colors.white,
  //                         );
  //                       }
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.blue.shade700,
  //                       foregroundColor: Colors.white,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       padding: const EdgeInsets.symmetric(vertical: 10),
  //                     ),
  //                     child: const Text("Save"),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

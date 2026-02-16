import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfixTech/api_calls/models/order_model.dart';
import 'package:smartfixTech/pages/Map_Location/Map_Location_screen.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/get_loaction.dart/get_location_screen.dart';
import 'package:smartfixTech/pages/home/checkout/checkout_controller.dart';
import 'package:smartfixTech/pages/home/checkout/confrom_order.dart';
import 'package:smartfixTech/pages/order/order_controller.dart';
import 'package:smartfixTech/theme/dimens.dart';
import 'package:uuid/uuid.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutCtrl = Get.put(CheckoutController());
    final CartController cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Progress Tracker
              _buildOrderProgress(),

              // Delivery Info Card
              _buildDeliveryInfoCard(checkoutCtrl),

              // Address Section - FIXED: Now shows selected address from cart
              _buildAddressSection(checkoutCtrl, cartCtrl),

              // Price Summary
              _buildPriceSummary(cartCtrl),

              // Payment Mode
              _buildPaymentSection(checkoutCtrl),

              // Terms & Conditions
              _buildTermsSection(),

              // Checkout Button
              _buildCheckoutButton(checkoutCtrl, cartCtrl),

              // Bottom padding
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Checkout",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 26, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.headset_mic, size: 22),
          onPressed: () {
            // Handle support
          },
        ),
      ],
    );
  }

  Widget _buildOrderProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          _buildProgressStep(1, "Cart", true),
          _buildProgressLine(),
          _buildProgressStep(2, "Checkout", true),
          _buildProgressLine(),
          _buildProgressStep(3, "Payment", false),
          _buildProgressLine(),
          _buildProgressStep(4, "Confirm", false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.teal : Colors.grey.shade300,
              border: Border.all(
                color: isActive ? Colors.teal.shade700 : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.teal.shade700 : Colors.grey.shade500,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDeliveryInfoCard(CheckoutController checkoutCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // padding: const EdgeInsets.all(16),
      // margin: const EdgeInsets.only(bottom: 12),
    );
  }

  // FIXED: Address section now correctly shows selected address from cart
  Widget _buildAddressSection(
    CheckoutController checkoutCtrl,
    CartController cartCtrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.teal,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Delivery Address",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildChangeAddressButton(checkoutCtrl, cartCtrl),
              ],
            ),
            const SizedBox(height: 16),

            // Selected Address Display - Shows the address from cart
            Obx(() {
              final selectedAddress = cartCtrl.selectedAddress;

              // Show selected address if it exists in cart
              if (selectedAddress.isNotEmpty &&
                  selectedAddress['address'] != null &&
                  selectedAddress['address'].toString().isNotEmpty) {
                // Show selected address from cart
                //   return _buildSelectedAddressCard(...);
                // }
                // if (selectedAddress.isNotEmpty &&
                //     selectedAddress['address'] != null &&
                //     selectedAddress['address'].toString().isNotEmpty) {
                // return _buildSelectedAddressCard(checkoutCtrl, {
                // 'id': 'selected',
                // 'title': selectedAddress['title'] ?? 'Delivery Address',
                // 'selectedAddress': selectedAddress['address'] ?? '',
                // 'lebel': selectedAddress['lebel'] ?? 'home',
                //   'distance': selectedAddress['distance'],
                // });
                // return _buildSelectedAddressCard(checkoutCtrl, selectedAddress);
              }

              // If no address in cart, show manual input
              return Column(
                children: [
                  _buildAddressInputField(checkoutCtrl),
                  const SizedBox(height: 12),
                  // _buildSearchAddressButton(checkoutCtrl),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Phone Input
            _buildPhoneInputField(checkoutCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeAddressButton(
    CheckoutController checkoutCtrl,
    CartController cartCtrl,
  ) {
    return GestureDetector(
      onTap: () {
        Get.to(() => GetLocationScreen());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_location, size: 14, color: Colors.teal.shade700),
            const SizedBox(width: 4),
            Text(
              "CHANGE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAddressCard(
    CheckoutController checkoutCtrl,
    Map<String, dynamic> selectedAddress,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  checkoutCtrl.getAddressIcon(
                    selectedAddress['lebel'] ?? 'home',
                  ),
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Text(
                        //   selectedAddress['title'] ?? 'Delivery Address',
                        //   style: const TextStyle(
                        //     fontSize: 15,
                        //     fontWeight: FontWeight.w700,
                        //     color: Colors.black87,
                        //   ),
                        // ),
                        // const SizedBox(width: 8),
                        if (selectedAddress['lebel'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedAddress['lebel'].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedAddress['address'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInputField(CheckoutController checkoutCtrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: checkoutCtrl.addressCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Enter complete address with landmark",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Icon(Icons.location_on, color: Colors.teal.shade300),
          ),
        ),
      ),
    );
  }

  // Widget _buildSearchAddressButton(CheckoutController checkoutCtrl) {
  //   return InkWell(
  //     onTap: () =>
  //         _showAddressSelectionSheet(checkoutCtrl, Get.find<CartController>()),
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: Colors.teal.withOpacity(0.05),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.teal.withOpacity(0.2)),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(Icons.search, color: Colors.teal.shade700, size: 18),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               "Search or select from saved addresses",
  //               style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
  //             ),
  //           ),
  //           Icon(
  //             Icons.arrow_forward_ios,
  //             color: Colors.teal.shade700,
  //             size: 14,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPhoneInputField(CheckoutController checkoutCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contact Number",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: checkoutCtrl.phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              hintText: "Enter 10-digit mobile number",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              counterText: "",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              prefixIcon: Icon(
                Icons.phone,
                color: Colors.teal.shade300,
                size: 18,
              ),
              suffixIcon: checkoutCtrl.phoneCtrl.text.length == 10
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green.shade400,
                      size: 18,
                    )
                  : null,
            ),
            onChanged: (value) {
              // Trigger UI update
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(CartController cartCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt,
                    color: Colors.teal,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "PRICE DETAILS",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${cartCtrl.cartItems.length} ITEMS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Breakdown
            _buildPriceBreakdown(cartCtrl),

            const Divider(height: 24),

            // Total
            _buildTotalRow(cartCtrl),

            const SizedBox(height: 16),

            // Savings
            if (cartCtrl.discount.value > 0) _buildSavingsBanner(cartCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(CartController cartCtrl) {
    return Column(
      children: [
        _buildPriceRow(
          "Total MRP",
          cartCtrl.subtotal.value,
          icon: Icons.shopping_bag_outlined,
        ),
        const SizedBox(height: 10),
        _buildPriceRow(
          "Platform Fee",
          cartCtrl.platformFee.value,
          icon: Icons.devices,
          showDiscount: true,
        ),
        const SizedBox(height: 10),
        _buildPriceRow(
          "Shipping Fee",
          cartCtrl.shippingFee.value,
          icon: Icons.delivery_dining,
          showDiscount: cartCtrl.shippingFee.value == 0,
          discountText: cartCtrl.shippingFee.value == 0 ? "Free" : null,
        ),
        if (cartCtrl.gstAmount.value > 0) ...[
          const SizedBox(height: 10),
          _buildPriceRow(
            "GST & Taxes",
            cartCtrl.gstAmount.value,
            icon: Icons.receipt_outlined,
          ),
        ],
        const SizedBox(height: 10),
        _buildPriceRow(
          "Discount",
          -cartCtrl.discount.value,
          icon: Icons.local_offer_outlined,
          isDiscount: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double value, {
    IconData? icon,
    bool isDiscount = false,
    bool showDiscount = false,
    String? discountText,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
        if (showDiscount && discountText != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              discountText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ),
        Text(
          "${value < 0 ? '- ' : ''}₹${NumberFormat('#,##0').format(value.abs())}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDiscount
                ? Colors.green.shade700
                : value < 0
                ? Colors.green.shade700
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(CartController cartCtrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Total Amount",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Inclusive of all taxes",
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "₹${NumberFormat('#,##0').format(cartCtrl.totalPrice.value)}",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.teal.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsBanner(CartController cartCtrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.savings, color: Colors.green.shade700, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're saving big!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Save ₹${NumberFormat('#,##0').format(cartCtrl.discount.value)} on this order",
                  style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.celebration, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(CheckoutController checkoutCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.teal,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "PAYMENT OPTION",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Method Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade200, width: 2),
                gradient: LinearGradient(
                  colors: [Colors.teal.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.money,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pay on Service",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Pay when service is completed",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.security,
                                size: 14,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Secure & Hassle-free",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Additional payment info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You can pay via Cash, UPI, or Card at the time of service",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Dimens.boxHeight12,
            Container(
               child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delivery_dining,
              size: 24,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery by",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  checkoutCtrl.getDeliveryDate(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  "Express",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
            )
            
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.teal.shade300),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "By continuing, you agree to our Terms of Use & Privacy Policy",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(
    CheckoutController checkoutCtrl,
    CartController cartCtrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Order Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payable Amount",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₹${NumberFormat('#,##0').format(cartCtrl.totalPrice.value)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "SECURE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Place Order Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _placeOrder(checkoutCtrl, cartCtrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "PLACE ORDER",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel Button
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text("Cancel Order", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(
    CheckoutController checkoutCtrl,
    CartController cartCtrl,
  ) async {
    // Validate phone
    if (!checkoutCtrl.validatePhone()) {
      Get.snackbar(
        "Invalid Phone Number",
        "Please enter a valid 10-digit mobile number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Validate address
    if (cartCtrl.selectedAddress.isEmpty ||
        cartCtrl.selectedAddress['address'] == null) {
      Get.snackbar(
        "Address Required",
        "Please select a delivery address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.location_off, color: Colors.white),
      );
      return;
    }

    try {
      // Get current user ID
      final String userId = _getCurrentUserId();

      // Get controllers
      final OrderController orderCtrl = Get.put(OrderController());

      // Prepare order data
      final orderItems = checkoutCtrl.prepareOrderItems();
      final addressData = {
        'title': cartCtrl.selectedAddress['title'] ?? 'Delivery Address',
        'address': cartCtrl.selectedAddress['address'] ?? '',
        'type': cartCtrl.selectedAddress['type'] ?? 'home',
      };

      // Show processing message
      Get.snackbar(
        "Processing Order",
        "Please wait while we place your order...",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Create order
      final result = await orderCtrl.createOrderFromCart(
        cartItems: orderItems,
        subtotal: cartCtrl.subtotal.value,
        platformFee: cartCtrl.platformFee.value,
        shippingFee: cartCtrl.shippingFee.value,
        gstAmount: cartCtrl.gstAmount.value,
        discount: cartCtrl.discount.value,
        totalAmount: cartCtrl.totalPrice.value,
        address: addressData,
        phone: checkoutCtrl.phoneCtrl.text.trim(),
        userId: userId,
        customerName: addressData['title'] ?? 'Customer',
      );

      if (result['success'] == true) {
        // Clear cart after successful order
        cartCtrl.clearCart();

        // Navigate to success screen
        Get.offAll(
          () => OrderSuccessView(
            orderId: result['orderId'] as String,
            orderNumber: result['orderNumber'] as String,
          ),
        );

        // Show success message
        Get.snackbar(
          "Order Placed Successfully!",
          "Your order #${result['orderNumber']} has been confirmed",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          "Order Failed",
          result['error'] ?? "Something went wrong. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e, stackTrace) {
      print('Order error: $e');
      print('Stack trace: $stackTrace');

      Get.snackbar(
        "Error",
        "Failed to place order. Please check your connection and try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
      );
    }
  }

  String _getCurrentUserId() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        const uuid = Uuid();
        final guestId = 'guest_${uuid.v4().substring(0, 8)}';
        print('No authenticated user, using guest ID: $guestId');

        // Show guest mode message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Guest Mode",
            "You're placing order as a guest. Sign in to track orders easily.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        });

        return guestId;
      }
    } catch (e) {
      print('Error getting user ID: $e');
      const uuid = Uuid();
      return 'error_${uuid.v4().substring(0, 8)}';
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/home/checkout/checkout_controller.dart';
import 'package:smartfixTech/pages/home/checkout/confrom_order.dart';
import 'package:smartfixTech/pages/order/order_controller.dart';
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
        child: Obx(() {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Progress Tracker
                _buildOrderProgress(),

                // Delivery Info Card
                _buildDeliveryInfoCard(checkoutCtrl),

                // Address Section - Shows selected address from cart
                _buildAddressSection(cartCtrl),

                // Price Summary with Icons
                _buildPriceSummary(cartCtrl),

                // Payment Mode
                _buildPaymentSection(),

                // Terms & Conditions
                _buildTermsSection(),

                // Checkout Button
                _buildCheckoutButton(checkoutCtrl, cartCtrl),

                // Bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          );
        }),
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
        icon: const Icon(Icons.arrow_back_ios, size: 20),
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
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
    );
  }

  // Address section - Shows selected address from CartController
  Widget _buildAddressSection(CartController cartCtrl) {
    final selectedAddress = cartCtrl.selectedAddress;

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
              ],
            ),
            const SizedBox(height: 16),

            // Display selected address from cart
            if (selectedAddress.isNotEmpty && selectedAddress['address'] != null)
              Container(
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
                            _getAddressIcon(selectedAddress['type'] ?? 'home'),
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedAddress['title'] ?? 'Delivery Address',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (selectedAddress['isDefault'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "DEFAULT",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.teal,
                                fontWeight: FontWeight.w600,
                              ),
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
                            selectedAddress['address'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                          if (selectedAddress['distance'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_bike,
                                  size: 14,
                                  color: Colors.teal.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${selectedAddress['distance'].toStringAsFixed(1)} km away',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    "No address selected",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Phone Input
            _buildPhoneInputField(),
          ],
        ),
      ),
    );
  }

  IconData _getAddressIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildPhoneInputField() {
  final CheckoutController checkoutCtrl = Get.find<CheckoutController>();
  
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
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
          decoration: InputDecoration(
            hintText: "Enter 10-digit mobile number",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
              
            ),
            focusColor: Colors.teal,
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
            // Force update to show/hide check icon
            checkoutCtrl.phoneCtrl.text = value.trim();
            checkoutCtrl.phoneCtrl.selection = TextSelection.fromPosition(
              TextPosition(offset: checkoutCtrl.phoneCtrl.text.length),
            );
          },
        ),
      ),
    ],
  );
}
  // Price Summary with Icons
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
                    Icons.receipt_long,
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${cartCtrl.cartItems.length} ITEMS",
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
            const SizedBox(height: 16),

            // Price Breakdown with Icons
            _buildPriceRowWithIcon(
              icon: Icons.shopping_cart_outlined,
              label: "Total MRP",
              value: cartCtrl.subtotal.value,
            ),
            const SizedBox(height: 10),
            
            _buildPriceRowWithIcon(
              icon: Icons.discount_outlined,
              label: "Discount",
              value: -cartCtrl.discount.value,
              isDiscount: true,
            ),
            const SizedBox(height: 10),
            
            _buildPriceRowWithIcon(
              icon: Icons.devices,
              label: "Platform Fee",
              value: cartCtrl.platformFee.value,
            ),
            const SizedBox(height: 10),
            
            _buildPriceRowWithIcon(
              icon: Icons.delivery_dining,
              label: "Shipping Fee",
              value: cartCtrl.shippingFee.value,
              showFree: cartCtrl.shippingFee.value == 0,
            ),
            
            if (cartCtrl.gstAmount.value > 0) ...[
              const SizedBox(height: 10),
              _buildPriceRowWithIcon(
                icon: Icons.receipt,
                label: "GST & Taxes",
                value: cartCtrl.gstAmount.value,
              ),
            ],

            const Divider(height: 24),

            // Total with Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payments,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Inclusive of all taxes",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${NumberFormat('#,##0').format(cartCtrl.totalPrice.value)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Savings Banner
            if (cartCtrl.discount.value > 0)
              Container(
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.savings,
                        color: Colors.green.shade700,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You save ₹${NumberFormat('#,##0').format(cartCtrl.discount.value)} on this order!",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRowWithIcon({
    required IconData icon,
    required String label,
    required double value,
    bool isDiscount = false,
    bool showFree = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDiscount ? Colors.green.shade600 : Colors.grey.shade500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        if (showFree)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "FREE",
              style: TextStyle(
                fontSize: 10,
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

  Widget _buildPaymentSection() {
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
          Icon(Icons.check_circle_outline, size: 16, color: Colors.teal.shade300),
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
        backgroundColor: Colors.white,
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    // Validate address
    if (cartCtrl.selectedAddress.isEmpty) {
      Get.snackbar(
        "Address Required",
        "Please select a delivery address",
        backgroundColor: Colors.white,
        colorText: Colors.black,
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
      // Get.snackbar(
      //   "Processing Order",
      //   "Please wait while we place your order...",
      //   backgroundColor: Colors.blue,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: const Duration(seconds: 2),
      //   margin: const EdgeInsets.all(16),
      //   borderRadius: 12,
      // );

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

        Get.snackbar(
          "Order Placed Successfully!",
          "Your order #${result['orderNumber']} has been confirmed",
          backgroundColor: Colors.white,
          colorText: Colors.black,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          "Order Failed",
          result['error'] ?? "Something went wrong. Please try again.",
          backgroundColor: Colors.white,
          colorText: Colors.red,
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
        return guestId;
      }
    } catch (e) {
      print('Error getting user ID: $e');
      const uuid = Uuid();
      return 'error_${uuid.v4().substring(0, 8)}';
    }
  }
}
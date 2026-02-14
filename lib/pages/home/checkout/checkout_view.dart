import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfixTech/api_calls/models/order_model.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/home/checkout/checkout_controller.dart';
import 'package:smartfixTech/pages/home/checkout/confrom_order.dart';
import 'package:smartfixTech/pages/order/order_controller.dart';
import 'package:smartfixTech/theme/theme.dart';
import 'package:uuid/uuid.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutCtrl = Get.put(CheckoutController());
    final CartController cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Delivery Info Card
              _buildDeliveryInfoCard(checkoutCtrl),

              // Address Section
              _buildAddressSection(checkoutCtrl, cartCtrl),

              // Price Summary
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
        ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard(CheckoutController checkoutCtrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.delivery_dining,
                size: 18,
                color: Colors.teal.shade700,
              ),
              const SizedBox(width: 8),
              const Text(
                "Delivery by",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                checkoutCtrl.getDeliveryDate(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.teal.shade100),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAddressSection(
    CheckoutController checkoutCtrl,
    CartController cartCtrl,
  ) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Delivery Address",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Obx(() {
                  return cartCtrl.addresses.isNotEmpty
                      ? TextButton(
                          onPressed: checkoutCtrl.toggleAddressType,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            checkoutCtrl.useSavedAddress
                                ? "ENTER NEW"
                                : "SAVED",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            ),
            const SizedBox(height: 12),

            // Saved Addresses Radio List
            Obx(() {
              if (cartCtrl.addresses.isNotEmpty &&
                  checkoutCtrl.useSavedAddress) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: _buildAddressRadioList(checkoutCtrl, cartCtrl),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // New Address Input
            if (!checkoutCtrl.useSavedAddress ||
                cartCtrl.addresses.isEmpty) ...[
              const SizedBox(height: 12),
              TextField(
                controller: checkoutCtrl.addressCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter full address with landmark",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.shade700),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddressSelectionSheet(checkoutCtrl),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text("SEARCH ADDRESS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.teal.shade200),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Phone Input
            const Text(
              "Contact Number",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: checkoutCtrl.phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                hintText: "10-digit mobile number",
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.teal.shade400,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(
                  Icons.phone,
                  size: 20,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAddressRadioList(
    CheckoutController checkoutCtrl,
    CartController cartCtrl,
  ) {
    final List<Widget> radioTiles = [];

    for (int i = 0; i < cartCtrl.addresses.length; i++) {
      final address = cartCtrl.addresses[i];
      radioTiles.add(
        RadioListTile<String>(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    checkoutCtrl.getAddressIcon(address['type'] ?? 'home'),
                    size: 16,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address['title'] ?? 'Address',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  address['address'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          value: address['id'],
          groupValue: checkoutCtrl.selectedAddressId,
          onChanged: (value) => checkoutCtrl.selectAddress(value!),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      );

      if (i < cartCtrl.addresses.length - 1) {
        radioTiles.add(const Divider(height: 12));
      }
    }

    return radioTiles;
  }

  void _showAddressSelectionSheet(CheckoutController checkoutCtrl) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16, top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildAddressSelectionUI(
                    checkoutCtrl,
                    scrollController,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.black54,
    );
  }

  Widget _buildAddressSelectionUI(
    CheckoutController checkoutCtrl,
    ScrollController scrollController,
  ) {
    final CartController cartCtrl = Get.find<CartController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Text(
            "Select Delivery Address",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Current Location
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.withOpacity(0.2)),
            ),
            child: InkWell(
              onTap: () {
                Get.snackbar(
                  "Info",
                  "Fetching current location...",
                  backgroundColor: Colors.teal,
                  colorText: Colors.white,
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Use Current Location",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final location =
                              cartCtrl.selectedAddress['address'] ??
                              "No address selected";
                          return Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.teal),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Saved Addresses
          Text(
            "SAVED ADDRESSES",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Address List
          Expanded(
            child: Obx(() {
              if (cartCtrl.addresses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 50,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No saved addresses",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: scrollController,
                itemCount: cartCtrl.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = cartCtrl.addresses[index];
                  final isSelected =
                      checkoutCtrl.selectedAddressId == address['id'];
                  return _buildAddressTile(checkoutCtrl, address, isSelected);
                },
              );
            }),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (checkoutCtrl.selectedAddressId != null) {
                  final selectedAddress = cartCtrl.addresses.firstWhere(
                    (addr) => addr['id'] == checkoutCtrl.selectedAddressId,
                  );
                  checkoutCtrl.selectAddressFromList(selectedAddress);
                }
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("USE THIS ADDRESS"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(
    CheckoutController checkoutCtrl,
    Map<String, dynamic> address,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => checkoutCtrl.selectAddress(address['id']),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                checkoutCtrl.getAddressIcon(address['type'] ?? 'home'),
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address['title'] ?? 'Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.teal.shade800
                                : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address['address'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address['distance'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions,
                          size: 12,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${address['distance'].toStringAsFixed(1)} km away',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.teal.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.teal, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(CartController cartCtrl) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PRICE DETAILS",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Price Breakdown
            _buildPriceRow("Total MRP", cartCtrl.subtotal.value, isTotal: true),
            _buildPriceRow(
              "Platform Fee",
              cartCtrl.platformFee.value,
              showCheck: true,
            ),
            _buildPriceRow(
              "Shipping Fee",
              cartCtrl.shippingFee.value,
              showCheck: true,
            ),
            if (cartCtrl.gstAmount.value > 0)
              _buildPriceRow(
                "GST & Charges",
                cartCtrl.gstAmount.value,
                showCheck: true,
              ),
            _buildPriceRow(
              "Discount",
              -cartCtrl.discount.value,
              isDiscount: true,
              showCheck: true,
            ),

            const Divider(height: 20),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  "₹${NumberFormat('#,##0').format(cartCtrl.totalPrice.value)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Savings
            if (cartCtrl.discount.value > 0)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings, size: 16, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You'll save ₹${NumberFormat('#,##0').format(cartCtrl.discount.value)} on this order!",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.w500,
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

  Widget _buildPriceRow(
    String label,
    double value, {
    bool isDiscount = false,
    bool showCheck = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showCheck)
                Icon(Icons.check_circle, size: 14, color: Colors.teal.shade600),
              if (showCheck) const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isTotal ? Colors.black87 : Colors.grey.shade700,
                  fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            "${value < 0 ? '-' : ''}₹${NumberFormat('#,##0').format(value.abs())}",
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.teal.shade600 : Colors.black87,
              fontWeight: isTotal ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PAYMENT",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration( 
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Icon(Icons.money, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "pay on Service".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Dimens.boxHeight2,
                        Text(
                          "Pay when service is completed",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.teal.shade600),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "By continuing, you confirm that you are above 18 years of age, and you agree to our Terms of Use & Privacy Policy",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
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
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Payable Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Payable Amount",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                "₹${NumberFormat('#,##0').format(cartCtrl.totalPrice.value)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _placeOrder(checkoutCtrl, cartCtrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "PLACE ORDER",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // Updated _placeOrder method
  Future<void> _placeOrder(
    CheckoutController checkoutCtrl,
    CartController cartCtrl,
  ) async {
    // Validate phone
    if (!checkoutCtrl.validatePhone()) {
      Get.snackbar(
        "Invalid Phone",
        "Please enter valid 10-digit number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate address
    if (!checkoutCtrl.validateAddress()) {
      Get.snackbar(
        "Address Required",
        checkoutCtrl.useSavedAddress
            ? "Please select an address from saved addresses"
            : "Please enter service address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.teal)),
      barrierDismissible: false,
    );

    try {
      // Get current user ID
      final String userId = _getCurrentUserId();

      // Get controllers
      final OrderController orderCtrl = Get.put(OrderController());

      // Prepare order data
      final orderItems = checkoutCtrl.prepareOrderItems();
      final addressData = checkoutCtrl.getAddressData();

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
        userId: userId, // Pass the user ID
        customerName: addressData['title'] ?? 'Customer',
      );

      Get.back(); // Close loading dialog

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
          "Success!",
          "Order #${result['orderNumber']} placed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to create order: ${result['error']}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      Get.back();
      print('Order error: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        "Error",
        "Failed to place order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper method to get current user ID
  String _getCurrentUserId() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        // If no user is logged in, create a guest user ID
        // In production, you should redirect to login instead
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

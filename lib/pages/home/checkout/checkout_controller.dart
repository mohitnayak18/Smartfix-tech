// checkout_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfixapp/pages/cart/cart_controller.dart';
import 'package:uuid/uuid.dart';

class CheckoutController extends GetxController {
  // Controllers
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  
  // State variables
  bool useSavedAddress = true;
  String? selectedAddressId;
  
  // UUID instance
  final Uuid _uuid = const Uuid();
  
  // Get other controllers
  CartController get cartCtrl => Get.find<CartController>();
  
  @override
  void onInit() {
    super.onInit();
    _initializeAddress();
  }
  
  void _initializeAddress() {
    // Safely check selectedAddress
    final selectedAddress = cartCtrl.selectedAddress;
    if (selectedAddress is Map && 
        selectedAddress.isNotEmpty && 
        selectedAddress['id'] != null) {
      selectedAddressId = selectedAddress['id'];
      addressCtrl.text = selectedAddress['address'] ?? '';
      phoneCtrl.text = selectedAddress['phone'] ?? '';
    } else if (cartCtrl.addresses.isNotEmpty) {
      final firstAddress = cartCtrl.addresses.first;
      selectedAddressId = firstAddress['id'];
      addressCtrl.text = firstAddress['address'] ?? '';
      phoneCtrl.text = firstAddress['phone'] ?? '';
    }
  }
  
  String getDeliveryDate() {
    final now = Timestamp.now().toDate();
    final deliveryDate = now.add(const Duration(minutes: 45));
    return DateFormat('MMM dd, EEEE').format(deliveryDate);
  }
  
  String formatCurrency(double amount) {
    return '₹${NumberFormat('#,##0').format(amount)}';
  }
  
  IconData getAddressIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'other':
        return Icons.location_on_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
  
  void toggleAddressType() {
    useSavedAddress = !useSavedAddress;
    update();
  }
  
  void selectAddress(String addressId) {
    selectedAddressId = addressId;
    final selectedAddress = cartCtrl.addresses.firstWhere(
      (addr) => addr['id'] == addressId,
      orElse: () => {},
    );
    
    if (selectedAddress.isNotEmpty) {
      addressCtrl.text = selectedAddress['address'] ?? '';
      phoneCtrl.text = selectedAddress['phone'] ?? '';
    }
    update();
  }
  
  void selectAddressFromList(Map<String, dynamic> address) {
    selectedAddressId = address['id'];
    addressCtrl.text = address['address'] ?? '';
    phoneCtrl.text = address['phone'] ?? '';
    update();
  }
  
  // Generate unique order ID
  String generateOrderId() {
    // Generate a v4 UUID
    final uuid = _uuid.v4();
    
    // Create a custom order number format: ORD-{timestamp}-{uuid-short}
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final shortUuid = uuid.substring(0, 8).toUpperCase();
    final orderNumber = 'ORD-$timestamp-$shortUuid';
    
    return orderNumber;
  }
  
  // Validation methods
  bool validatePhone() {
    return phoneCtrl.text.trim().length == 10;
  }
  
  bool validateAddress() {
    if (useSavedAddress) {
      return selectedAddressId != null;
    } else {
      return addressCtrl.text.trim().isNotEmpty;
    }
  }
  
  // Get address data for order
  Map<String, dynamic> getAddressData() {
    if (useSavedAddress && selectedAddressId != null) {
      final selectedAddress = cartCtrl.addresses.firstWhere(
        (addr) => addr['id'] == selectedAddressId,
      );
      return {
        'title': selectedAddress['title'] ?? 'Address',
        'address': selectedAddress['address'],
        'type': selectedAddress['type'] ?? 'home',
        'latitude': selectedAddress['latitude'],
        'longitude': selectedAddress['longitude'],
      };
    } else {
      return {
        'title': 'New Address',
        'address': addressCtrl.text.trim(),
        'type': 'other',
      };
    }
  }
  
  // Prepare cart items for order
  List<Map<String, dynamic>> prepareOrderItems() {
    final List<Map<String, dynamic>> orderItems = [];
    
    for (final dynamic item in cartCtrl.cartItems) {
      Map<String, dynamic> itemMap;
      
      if (item is Map<String, dynamic>) {
        itemMap = item;
      } else if (item is Map) {
        itemMap = Map<String, dynamic>.from(item);
      } else if (item.runtimeType.toString().contains('CartItem')) {
        itemMap = _convertCartItemToMap(item);
      } else {
        continue;
      }
      
      // Generate unique item ID for each cart item
      final itemId = _uuid.v4();
      
      orderItems.add({
        'itemId': itemId,
        'productId': itemMap['id']?.toString() ??
            itemMap['productId']?.toString() ?? '',
        'productName': itemMap['name']?.toString() ??
            itemMap['productName']?.toString() ??
            itemMap['title']?.toString() ?? 'Service',
        'productImage': itemMap['image']?.toString() ??
            itemMap['productImage']?.toString() ??
            itemMap['imageUrl']?.toString(),
        'price': _getDoubleValue(itemMap, ['price', 'unitPrice', 'amount']),
        'quantity': _getIntValue(itemMap, ['quantity', 'qty', 'count']),
        'serviceType': itemMap['serviceType']?.toString() ?? 
            itemMap['type']?.toString(),
        'estimatedDuration': itemMap['estimatedDuration'],
        'addedAt': DateTime.now().toIso8601String(),
      });
    }
    
    return orderItems;
  }
  
  // Create order method
  Future<Map<String, dynamic>?> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required double subtotal,
    required double platformFee,
    required double shippingFee,
    required double gstAmount,
    required double discount,
    required double totalAmount,
    required Map<String, dynamic> address,
    required String phone,
    required String userId, // Add user ID parameter
  }) async {
    try {
      // Generate order data with UUID
      final orderId = _uuid.v4();
      final orderNumber = generateOrderId();
      final timestamp = DateTime.now();
      
      final orderData = {
        'orderId': orderId,
        'orderNumber': orderNumber,
        'userId': userId, // Add user ID
        'items': cartItems,
        'subtotal': subtotal,
        'platformFee': platformFee,
        'shippingFee': shippingFee,
        'gstAmount': gstAmount,
        'discount': discount,
        'totalAmount': totalAmount,
        'address': address,
        'phone': phone,
        'status': 'pending',
        'paymentMethod': 'cash_on_delivery',
        'paymentStatus': 'pending',
        'createdAt': Timestamp.fromDate(timestamp),
        'updatedAt': Timestamp.fromDate(timestamp),
        'expectedDelivery': Timestamp.fromDate(
          timestamp.add(const Duration(minutes: 45))
        ),
      };
      
      return {
        'orderData': orderData,
        'orderId': orderId,
        'orderNumber': orderNumber,
      };
    } catch (e) {
      print('Error creating order data: $e');
      return null;
    }
  }
  
  // Helper methods
  Map<String, dynamic> _convertCartItemToMap(dynamic cartItem) {
    try {
      if (cartItem.toJson != null) {
        return cartItem.toJson();
      } else if (cartItem.toMap != null) {
        return cartItem.toMap();
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
  
  double _getDoubleValue(Map<String, dynamic> item, List<String> keys) {
    for (var key in keys) {
      if (item.containsKey(key) && item[key] != null) {
        final value = item[key];
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
      }
    }
    return 0.0;
  }
  
  int _getIntValue(Map<String, dynamic> item, List<String> keys) {
    for (var key in keys) {
      if (item.containsKey(key) && item[key] != null) {
        final value = item[key];
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 1;
      }
    }
    return 1;
  }
  
  @override
  void onClose() {
    addressCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
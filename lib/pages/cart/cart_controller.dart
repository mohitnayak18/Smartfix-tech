import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/models/cart_model.dart';
import 'package:smartfixTech/api_calls/models/order_model.dart';
import 'package:smartfixTech/pages/cart/cart.dart';
import 'package:uuid/uuid.dart';

class CartController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observables
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  // Price observables
  final RxDouble subtotal = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxInt discountPercentage = 0.obs;

  // Fee observables loaded from Firebase
  final RxDouble platformFee = 0.0.obs;
  final RxDouble shippingFee = 0.0.obs;
  final RxDouble gstPercentage = 0.0.obs;
  final RxDouble gstAmount = 0.0.obs;
  // final RxDouble distanceInKm = 0.0.obs;
  final RxDouble totalPrice = 0.0.obs;

  // Address Management
  final RxList<Map<String, dynamic>> addresses = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> selectedAddress = <String, dynamic>{}.obs;
  final RxBool isLoadingAddresses = false.obs;
  final RxDouble distanceInKm = 0.0.obs;
  // final RxMap<String, dynamic> selectedAddress = <String, dynamic>{}.obs;
  // final RxList<Map<String, dynamic>> addresses = <Map<String, dynamic>>[].obs;

  // App configuration (loaded from Firebase)
  final RxMap<String, dynamic> appConfig = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> shippingConfig = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> discountConfig = <String, dynamic>{}.obs;

  String? modelId;
  String? brandId;

  // Collection references
  CollectionReference get userRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  CollectionReference get addressesRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  CollectionReference get savedCartsRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('saved_carts');
  }

  CollectionReference get ordersRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('orders');
  }

  DocumentReference get appConfigRef =>
      _firestore.collection('app_config').doc('settings');

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onReady() {
    super.onReady();
    // Load addresses after the first frame is built
    loadAddresses();
  }

  String? get selectedAddressText {
    if (selectedAddress.isNotEmpty && selectedAddress.containsKey('address')) {
      return selectedAddress['address']?.toString();
    }
    return null;
  }

  String? getSelectedAddressTitle() {
    if (selectedAddress.isNotEmpty && selectedAddress.containsKey('title')) {
      return selectedAddress['title']?.toString();
    }
    return null;
  }

  // double? getSelectedAddressDistance() {
  //   if (selectedAddress.isNotEmpty && selectedAddress.containsKey('distance')) {
  //     final distance = selectedAddress['distance'];
  //     if (distance is num) {
  //       return distance.toDouble();
  //     } else if (distance is String) {
  //       return double.tryParse(distance);
  //     }
  //   }
  //   return null;
  // }

  bool get hasSelectedAddress => selectedAddress.isNotEmpty;

  Future<void> loadAddresses() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      isLoadingAddresses.value = true;

      final snapshot = await addressesRef
          .orderBy('createdAt', descending: true)
          .get();

      addresses.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
          'lastUsedAt': (data['lastUsedAt'] as Timestamp?)?.toDate(),
        };
      }).toList();

      log('✅ Loaded ${addresses.length} addresses for user: ${user.uid}');

      // Auto-select default address
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhere(
          (addr) => addr['isDefault'] == true,
          orElse: () => addresses.first,
        );
        await selectAddress(defaultAddress);
      }

      isLoadingAddresses.value = false;
    } catch (e) {
      log('❌ Error loading addresses: $e');
      isLoadingAddresses.value = false;
      Get.snackbar(
        'Error',
        'Failed to load addresses',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    }
  }

  // ==================== ADDRESS CRUD OPERATIONS ====================

  Future<bool> saveAddress({
    required String title,
    required String address,
    required String type,
    double? lat,
    double? lng,
    Map<String, dynamic>? fullAddress,
    String? note,
    String? name,
    String? contactPhone,
    String? placeId,
    bool setAsDefault = false,
    String? phone,
    // double? distance,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final addressId = DateTime.now().millisecondsSinceEpoch.toString();
      final addressData = {
        'id': addressId,
        'userId': user.uid,
        // 'userEmail': user.email ?? '',
        'title': title,
        'address': address,
        'type': type,
        'lat': lat,
        'lng': lng,
        'fullAddress': fullAddress ?? {},
        // 'note': note ?? '',
        'contactPerson': name ?? '',
        'contactPhone': contactPhone ?? '',
        'placeId': placeId ?? '',
        'isDefault': setAsDefault,
        'phone': phone ?? '',
        // 'distance': distance ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastUsedAt': FieldValue.serverTimestamp(),
      };
      log('✅ Address data prepared for saving: $addressData');
      log('✅ Contact person name: $name');
      // If setting as default, update other addresses
      if (setAsDefault) {
        await _updateDefaultAddress(addressId);
      }

      await addressesRef.doc(addressId).set(addressData);

      // Add to local list
      addresses.insert(0, addressData);
      addresses.refresh();

      // Select the new address
      await selectAddress(addressData);

      // log('✅ Address saved successfully: $title');
      // Get.snackbar(
      //   'Success',
      //   'Address saved successfully',
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
      return true;
    } catch (e) {
      log('❌ Error saving address: $e');
      Get.snackbar(
        'Error',
        'Failed to save address',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
      return false;
    }
  }

  Future<bool> updateAddress({
    required String addressId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId);

      // Check if document exists
      final docSnapshot = await docRef.get();
      final updateData = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (docSnapshot.exists) {
        await docRef.update(updateData);
        log('✅ Address updated: $addressId');
      } else {
        // Try to find in local list
        final existingAddress = addresses.firstWhere(
          (addr) => addr['id'] == addressId,
          orElse: () => {},
        );

        if (existingAddress.isNotEmpty) {
          await docRef.set({
            ...existingAddress,
            ...updateData,
            'createdAt': FieldValue.serverTimestamp(),
          });
          log('✅ Address created: $addressId');
        } else {
          log('⚠️ Cannot create address: No existing data found');
          return false;
        }
      }

      // Update local list
      final index = addresses.indexWhere((addr) => addr['id'] == addressId);
      if (index != -1) {
        addresses[index] = {
          ...addresses[index],
          ...updates,
          'updatedAt': DateTime.now(),
        };
        addresses.refresh();
      }

      // Update selected address if it's the one being edited
      if (selectedAddress['id'] == addressId) {
        selectedAddress.value = {...selectedAddress, ...updates};
        selectedAddress.refresh();
      }

      Get.snackbar(
        'Success',
        'Address updated successfully',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return true;
    } catch (e) {
      log('❌ Error updating address: $e');
      Get.snackbar(
        'Error',
        'Failed to update address',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      final docRef = addressesRef.doc(addressId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        log('⚠️ Address $addressId does not exist');
        return false;
      }

      await docRef.delete();

      // Remove from local list
      addresses.removeWhere((addr) => addr['id'] == addressId);
      addresses.refresh();

      // If deleted address was selected, select another one
      if (selectedAddress['id'] == addressId) {
        if (addresses.isNotEmpty) {
          await selectAddress(addresses.first);
        } else {
          selectedAddress.value = {};
          distanceInKm.value = 0.0;
        }
      }

      Get.snackbar(
        'Deleted',
        'Address removed successfully',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return true;
    } catch (e) {
      log('❌ Error deleting address: $e');
      Get.snackbar(
        'Error',
        'Failed to delete address',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
      return false;
    }
  }

  Future<void> selectAddress(Map<String, dynamic> address) async {
    try {
      selectedAddress.value = address;

      // Update distance
      if (address['distance'] != null) {
        final distance = address['distance'];
        distanceInKm.value = distance is num ? distance.toDouble() : 0.0;
      }

      // Update last used timestamp
      if (address['id'] != null) {
        await _updateAddressLastUsed(address['id']);
      }

      // log('✅ Address selected: ${address['title']}');
    } catch (e) {
      // log('❌ Error selecting address: $e');
      rethrow;
    }
  }

  // ==================== DISTANCE MANAGEMENT ====================

  // Future<void> updateDistance(double distance) async {
  //   distanceInKm.value = distance;

  //   if (selectedAddress.isEmpty) return;

  //   // ⛔ DO NOT touch Firestore for current location
  //   if (selectedAddress['type'] == 'current') {
  //     selectedAddress['distance'] = distance;
  //     selectedAddress.refresh();
  //     return;
  //   }

  //   await _updateAddressDistance(selectedAddress['id'], distance);
  // }

  // Future<void> _updateAddressDistance(String addressId, double distance) async {
  //   // if (addressId == 'current') return;
  //   try {
  //     final userId = _auth.currentUser?.uid;
  //     if (userId == null) return;

  //     final docRef = addressesRef.doc(addressId);
  //     final docSnapshot = await docRef.get();

  //     if (docSnapshot.exists) {
  //       await docRef.update({
  //         'distance': distance,
  //         'updatedAt': FieldValue.serverTimestamp(),
  //       });

  //       // Update local selected address
  //       if (selectedAddress['id'] == addressId) {
  //         selectedAddress['distance'] = distance;
  //         selectedAddress.refresh();
  //       }

  //       // Update local addresses list
  //       final index = addresses.indexWhere((addr) => addr['id'] == addressId);
  //       if (index != -1) {
  //         addresses[index]['distance'] = distance;
  //         addresses.refresh();
  //       }
  //     } else {
  //       log('⚠️ Address document $addressId does not exist');
  //     }
  //   } catch (e) {
  //     log('❌ Error updating address distance: $e');
  //   }
  // }

  // ==================== PRIVATE HELPER METHODS ====================

  Future<void> _updateDefaultAddress(String newDefaultId) async {
    try {
      final snapshot = await addressesRef.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        final docRef = addressesRef.doc(doc.id);
        batch.update(docRef, {
          'isDefault': doc.id == newDefaultId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Update local list
      for (var i = 0; i < addresses.length; i++) {
        addresses[i]['isDefault'] = addresses[i]['id'] == newDefaultId;
      }
      addresses.refresh();
    } catch (e) {
      log('❌ Error updating default address: $e');
    }
  }

  Future<void> _updateAddressLastUsed(String addressId) async {
    try {
      final docRef = addressesRef.doc(addressId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({'lastUsedAt': FieldValue.serverTimestamp()});

        // Update local address
        final index = addresses.indexWhere((addr) => addr['id'] == addressId);
        if (index != -1) {
          addresses[index]['lastUsedAt'] = DateTime.now();
          addresses.refresh();
        }
      }
    } catch (e) {
      log('⚠️ Could not update last used timestamp: $e');
    }
  }

  // ==================== UI HELPER METHODS ====================

  IconData getAddressIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'current':
        return Icons.my_location_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  String formatAddressForDisplay(Map<String, dynamic> address) {
    final title = address['title']?.toString() ?? 'Address';
    final addr = address['address']?.toString() ?? '';
    // final note = address['note']?.toString();

    String display = '$title: $addr';
    // if (note != null && note.isNotEmpty) {
    //   display += '\nNote: $note';
    // }

    return display;
  }

  // ==================== INITIALIZATION ====================
  /// Used ONLY for "Current Location" (LOCAL, not Firestore)
  void setCurrentAddress(Map<String, dynamic> address) {
    selectedAddress.value = address;

    final distance = address['distance'];
    distanceInKm.value = distance is num ? distance.toDouble() : 0.0;

    log('📍 Current location set locally');
  }

  Future<void> _initializeController() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      isLoading.value = true;

      // Load app configuration from Firebase
      await loadAppConfig();

      // Load only cart data here (addresses moved to onReady)
      await Future.wait([
        loadCartFromFirebase(),
        // loadAddresses(), // REMOVED - now in onReady
        // loadOrdersFromFirestore(),
      ]);

      isLoading.value = false;
    } catch (e) {
      print('❌ Controller initialization error: $e');
      isLoading.value = false;
    }
  }

  Future<void> loadAppConfig() async {
    final snap = await FirebaseFirestore.instance
        .collection('settings')
        //.orderBy('price')
        .doc('price_details')
        .get();

    if (!snap.exists) return;

    final data = snap.data()!;
    // log('Fetched app config: ${data.toString()}');

    platformFee.value = (data['platform_fee'] as num?)?.toDouble() ?? 0;
    gstPercentage.value = (data['gst_percentage'] as num?)?.toDouble() ?? 0;
    discount.value = (data['discount_fee'] as num?)?.toDouble() ?? 0;
    shippingFee.value = (data['shipping_fee'] as num?)?.toDouble() ?? 0;

    // shippingConfig.value = data['shipping'] as Map<String, dynamic>? ?? {};
  }

  // ==================== QUANTITY CONTROL METHODS ====================

  Future<void> increaseQty(String cartId) async {
    final index = cartItems.indexWhere((e) => e.cartId == cartId);
    if (index == -1) return;

    cartItems[index].qty.value++;
    calculateTotals();

    await userRef.doc(cartId).update({'quantity': FieldValue.increment(1)});
  }

  Future<void> decreaseQty(String cartId) async {
    final index = cartItems.indexWhere((e) => e.cartId == cartId);
    if (index == -1) return;

    cartItems[index].qty.value--;
    calculateTotals();

    await userRef.doc(cartId).update({'quantity': FieldValue.increment(-1)});
  }

  Future<void> removeItem(String cartId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ User not logged in');
        return;
      }

      // Get the document reference for the specific cart item
      final cartDocRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(cartId)
          .delete();
      // log("Cart item removed: $cartId");
      // log("Cart item $cartDocRef removed from Firestore");
      print('✅ Cart item removed: $cartId');
      cartItems.removeWhere((item) => item.cartId == cartId);
      calculateTotals();
      loadCartFromFirebase();
      Get.snackbar(
        'Removed',
        'Item removed from cart',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } catch (e) {
      print('❌ Remove item error: $e');
      Get.snackbar(
        'Error',
        'Failed to remove item',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadCartFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      isLoading.value = true;
      cartItems.clear();

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final cartId = doc.id;
        // log('🔍 Fetching cart item details for cartId: $data');
        // ✅ Get IDs from cart
        // String productId = data['productId']?.toString() ?? '';
        String productId = data['productId']?.toString() ?? '';
        log('🔍 Fetching product details for productId: $productId');
        String serviceName = '';
        String finalproductId = productId;

        // ✅ If we have productId, fetch product details
        if (finalproductId.isNotEmpty) {
          final productDoc = await _firestore
              .collection('products')
              .doc(finalproductId)
              .get();

          log('🔍 Fetching product details for productId: $productDoc');
          if (productDoc.exists) {
            final productData = productDoc.data() as Map<String, dynamic>;
            finalproductId = productData['serviceId']?.toString() ?? '';
            log('🔍 Fetching service details for serviceId: $finalproductId');
            // ✅ Fetch service name
            if (finalproductId.isNotEmpty) {
              final serviceDoc = await _firestore
                  .collection('service')
                  .doc(finalproductId)
                  .get();

              if (serviceDoc.exists) {
                final serviceData = serviceDoc.data() as Map<String, dynamic>;
                serviceName = serviceData['name'] ?? '';
                log('🔍 Fetching service details for serviceId: $serviceName');
              }
            }
          } else {
            // ✅ If product not found, use serviceId from cart
            finalproductId = finalproductId.isNotEmpty
                ? finalproductId
                : data['serviceId']?.toString() ?? '';
            if (finalproductId.isNotEmpty) {
              final serviceDoc = await _firestore
                  .collection('service')
                  .doc(finalproductId)
                  .get();

              if (serviceDoc.exists) {
                final serviceData = serviceDoc.data() as Map<String, dynamic>;
                serviceName = serviceData['name'] ?? '';
              }
            }
          }
        } else if (finalproductId.isNotEmpty) {
          // ✅ If no productId, try to get service details directly
          final serviceDoc = await _firestore
              .collection('service')
              .doc(finalproductId)
              .get();

          if (serviceDoc.exists) {
            final serviceData = serviceDoc.data() as Map<String, dynamic>;
            serviceName = serviceData['name'] ?? '';
            finalproductId = finalproductId;
          }
        }

        // ✅ Add to cart list
        cartItems.add(
          CartItem(
            productId: finalproductId,
            serviceId: finalproductId,
            serviceName: serviceName,
            title: data['title'] ?? '',
            brand: data['brand'] ?? '',
            price: (data['price'] as num).toDouble(),
            model: data['model'] ?? '',
            image: data['image'] ?? '',
            qty: RxInt(data['quantity'] ?? 1),
            cartId: cartId,
            customerNote: data['customerNote'], 
            // notes: data['notes'],
          ),
        );
      }

      calculateTotals();
      isLoading.value = false;
    } catch (e) {
      print("❌ Load cart error: $e");
      isLoading.value = false;
    }
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    log("userid:${user.uid}");
    var uuid = Uuid();
    final cartId = uuid.v1();

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(cartId);

    await docRef
        .set({
          'cartId': cartId,
          'serviceName': product['serviceName'] ?? '',

          // 'serviceId': product['serviceId']?.toString() ?? '',
          'productId': product['serviceId']?.toString() ?? '',
          'title': product['title'] ?? '',
          'brand': product['brand'] ?? '',
          'model': product['model'] ?? '',
          'price': product['price'] ?? 0,
          'image': product['image'] ?? '',
          'brandId': product['brandId']?.toString(),
          'modelId': product['modelId']?.toString(),
          'quantity': product['quantity'] ?? 1,
          'createdAt': FieldValue.serverTimestamp(),
          'customerNote': product['customerNote'] ?? '',
        })
        .then((value) {
          Get.to(() => const CartView());
          loadCartFromFirebase();
        });
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;
    // log("userid:${user.uid}");
    // var uuid = Uuid();
    // final cartId = uuid.v1();

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart');
    // .doc(cartId)
    // .delete();
    try {
      final snapshot = await docRef.get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      cartItems.clear();
      calculateTotals();

      // Get.snackbar(
      //   "Cleared",
      //   "All cart cleared successfully",
      //   backgroundColor: Colors.white,
      //   colorText: Colors.black,
      //   icon: Icon(Icons.phone_android_sharp),
      // );
    } catch (e) {
      print("❌ Clear cart error: $e");
    }
  }

  // ==================== CALCULATION METHODS ====================

  void calculateTotals() {
    subtotal.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.qty.value,
    );
    //_calculateDiscount();
    //_calculateShipping();
    _calculateGST();
    _calculateTotal();
    log('TOTAL = ${totalPrice.value}');
  }

  void setSelectedAddress(Map<String, dynamic> address) {
    selectedAddress.value = address;
  }

  void _calculateGST() {
    // final taxable = subtotal.value - discount.value + platformFee.value;
    gstAmount.value = gstPercentage.value > 0 ? gstPercentage.value : 0;
  }

  void _calculateTotal() {
    totalPrice.value =
        subtotal.value -
        (discount.value -
            platformFee.value -
            shippingFee.value -
            gstAmount.value);
  }

  int get totalItemCount =>
      cartItems.fold(0, (sum, item) => sum + item.qty.value);

  bool get isCartEmpty => cartItems.isEmpty;

  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': totalItemCount,
      'subtotal': subtotal.value,
      'discount': discount.value,
      'shippingFee': shippingFee.value,
      'platformFee': platformFee.value,
      'gstAmount': gstAmount.value,
      'total': totalPrice.value,
    };
  }

  // Real-time cart stream
  // Real-time cart stream
  Stream<List<CartItem>> getCartStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return userRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // FIXED: Convert productId to String properly
        String? productIdValue;
        if (data['productId'] != null) {
          if (data['productId'] is Map) {
            productIdValue = data['productId']['name']?.toString();
          } else {
            productIdValue = data['productId'].toString();
          }
        } else if (data['id'] != null) {
          productIdValue = data['id'].toString();
        }

        return CartItem(
          productId: productIdValue,
          serviceName: data['serviceName'] ?? '',
          title: data['title'] ?? '',
          brand: data['brand'] ?? '',
          model: data['model'] ?? '',
          price: (data['price'] as num).toDouble(),
          image: data['image'] ?? '',
          qty: RxInt(data['quantity'] ?? 1),
          cartId: doc.id,
          customerNote: data['customerNote'], 
          // notes: data['notes'],
        );
      }).toList();
    });
  }

  // Real-time addresses stream
  Stream<List<Map<String, dynamic>>> getAddressesStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return addressesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
    });
  }
}

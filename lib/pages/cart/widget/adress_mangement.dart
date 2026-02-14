// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smartfixTech/api_calls/models/cart_model.dart';
// import 'package:smartfixTech/api_calls/models/order_model.dart';
// import 'package:smartfixTech/pages/cart/cart.dart';
// import 'package:uuid/uuid.dart';

// class CartController extends GetxController {
//   // Firebase instances
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Observables
//   final RxList<CartItem> cartItems = <CartItem>[].obs;
//   final RxList<OrderModel> orders = <OrderModel>[].obs;
//   final RxBool isLoading = false.obs;

//   // Price observables
//   final RxDouble subtotal = 0.0.obs;
//   final RxDouble discount = 0.0.obs;
//   final RxInt discountPercentage = 0.obs;

//   // Fee observables loaded from Firebase
//   final RxDouble platformFee = 0.0.obs;
//   final RxDouble shippingFee = 0.0.obs;
//   final RxDouble gstPercentage = 0.0.obs;
//   final RxDouble gstAmount = 0.0.obs;
//   // final RxDouble distanceInKm = 0.0.obs;
//   final RxDouble totalPrice = 0.0.obs;

//   // ============ MODIFIED: Address Management - Only Selected Address ============
//   final RxList<Map<String, dynamic>> addresses = <Map<String, dynamic>>[].obs;
//   final RxMap<String, dynamic> selectedAddress = <String, dynamic>{}.obs;
//   final RxBool isLoadingAddresses = false.obs;
//   final RxDouble distanceInKm = 0.0.obs;

//   // App configuration (loaded from Firebase)
//   final RxMap<String, dynamic> appConfig = <String, dynamic>{}.obs;
//   final RxMap<String, dynamic> shippingConfig = <String, dynamic>{}.obs;
//   final RxMap<String, dynamic> discountConfig = <String, dynamic>{}.obs;

//   // Collection references
//   CollectionReference get userRef {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) throw Exception('User not authenticated');
//     return _firestore.collection('users').doc(userId).collection('cart');
//   }

//   CollectionReference get addressesRef {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) throw Exception('User not authenticated');
//     return _firestore.collection('users').doc(userId).collection('addresses');
//   }

//   CollectionReference get savedCartsRef {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) throw Exception('User not authenticated');
//     return _firestore.collection('users').doc(userId).collection('saved_carts');
//   }

//   CollectionReference get ordersRef {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) throw Exception('User not authenticated');
//     return _firestore.collection('users').doc(userId).collection('orders');
//   }

//   DocumentReference get appConfigRef =>
//       _firestore.collection('app_config').doc('settings');
  
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeController();
//   }

//   String? get selectedAddressText {
//     if (selectedAddress.isNotEmpty && selectedAddress.containsKey('address')) {
//       return selectedAddress['address']?.toString();
//     }
//     return null;
//   }

//   String? getSelectedAddressTitle() {
//     if (selectedAddress.isNotEmpty && selectedAddress.containsKey('title')) {
//       return selectedAddress['title']?.toString();
//     }
//     return null;
//   }

//   double? getSelectedAddressDistance() {
//     if (selectedAddress.isNotEmpty && selectedAddress.containsKey('distance')) {
//       final distance = selectedAddress['distance'];
//       if (distance is num) {
//         return distance.toDouble();
//       } else if (distance is String) {
//         return double.tryParse(distance);
//       }
//     }
//     return null;
//   }

//   bool get hasSelectedAddress => selectedAddress.isNotEmpty;

//   // ============ MODIFIED: Load addresses but keep only selected ============
//   Future<void> loadAddresses() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       isLoadingAddresses.value = true;

//       final snapshot = await addressesRef
//           .orderBy('createdAt', descending: true)
//           .get();

//       addresses.value = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return {
//           'id': doc.id,
//           ...data,
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
//           'lastUsedAt': (data['lastUsedAt'] as Timestamp?)?.toDate(),
//         };
//       }).toList();

//       log('✅ Loaded ${addresses.length} addresses for user: ${user.uid}');

//       // Auto-select most recent address if exists
//       if (addresses.isNotEmpty && selectedAddress.isEmpty) {
//         final recentAddress = addresses.first;
//         await selectAddress(recentAddress);
//       }

//       isLoadingAddresses.value = false;
//     } catch (e) {
//       log('❌ Error loading addresses: $e');
//       isLoadingAddresses.value = false;
//     }
//   }

//   // ============ MODIFIED: Save address and set as selected only ============
//   Future<bool> saveAddress({
//     required String title,
//     required String address,
//     required String type,
//     double? lat,
//     double? lng,
//     Map<String, dynamic>? fullAddress,
//     String? note,
//     String? contactPerson,
//     String? contactPhone,
//     String? placeId,
//     bool setAsDefault = false,
//     String? phone,
//     double? distance,
//   }) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return false;

//       final addressId = const Uuid().v4();
//       final addressData = {
//         'id': addressId,
//         'userId': user.uid,
//         'userEmail': user.email ?? '',
//         'title': title,
//         'address': address,
//         'type': type,
//         'lat': lat,
//         'lng': lng,
//         'fullAddress': fullAddress ?? {},
//         'note': note ?? '',
//         'contactPerson': contactPerson ?? '',
//         'contactPhone': contactPhone ?? '',
//         'placeId': placeId ?? '',
//         'isDefault': setAsDefault,
//         'phone': phone ?? '',
//         'distance': distance ?? 0.0,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//         'lastUsedAt': FieldValue.serverTimestamp(),
//       };

//       await addressesRef.doc(addressId).set(addressData);

//       // Add to local list
//       addresses.insert(0, addressData);
//       addresses.refresh();

//       // Set as selected address
//       await selectAddress(addressData);

//       log('✅ Address saved successfully: $title');
//       return true;
//     } catch (e) {
//       log('❌ Error saving address: $e');
//       return false;
//     }
//   }

//   // ============ MODIFIED: Update address and keep selected if it's the same ============
//   Future<bool> updateAddress({
//     required String addressId,
//     required Map<String, dynamic> updates,
//   }) async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       final docRef = addressesRef.doc(addressId);
      
//       final updateData = {
//         ...updates,
//         'updatedAt': FieldValue.serverTimestamp(),
//       };

//       await docRef.update(updateData);

//       // Update local list
//       final index = addresses.indexWhere((addr) => addr['id'] == addressId);
//       if (index != -1) {
//         addresses[index] = {
//           ...addresses[index],
//           ...updates,
//           'updatedAt': DateTime.now(),
//         };
//         addresses.refresh();
//       }

//       // Update selected address if it's the one being edited
//       if (selectedAddress['id'] == addressId) {
//         selectedAddress.value = {...selectedAddress, ...updates};
//         selectedAddress.refresh();
//       }

//       return true;
//     } catch (e) {
//       log('❌ Error updating address: $e');
//       return false;
//     }
//   }

//   // ============ MODIFIED: Delete address and clear selection if deleted ============
//   Future<bool> deleteAddress(String addressId) async {
//     try {
//       final docRef = addressesRef.doc(addressId);
//       await docRef.delete();

//       // Remove from local list
//       addresses.removeWhere((addr) => addr['id'] == addressId);
//       addresses.refresh();

//       // If deleted address was selected, clear selection
//       if (selectedAddress['id'] == addressId) {
//         selectedAddress.value = {};
//         distanceInKm.value = 0.0;
//       }

//       return true;
//     } catch (e) {
//       log('❌ Error deleting address: $e');
//       return false;
//     }
//   }

//   // ============ MODIFIED: Select address and store as selected only ============
//   Future<void> selectAddress(Map<String, dynamic> address) async {
//     try {
//       selectedAddress.value = address;

//       // Update distance
//       if (address['distance'] != null) {
//         final distance = address['distance'];
//         distanceInKm.value = distance is num ? distance.toDouble() : 0.0;
//       }

//       // Update last used timestamp
//       if (address['id'] != null) {
//         await _updateAddressLastUsed(address['id']);
//       }

//       log('✅ Address selected: ${address['title']}');
//     } catch (e) {
//       log('❌ Error selecting address: $e');
//     }
//   }

//   // ============ NEW: Set address from GetLocationScreen ============
//   Future<void> setAddressFromLocation(Map<String, dynamic> locationData) async {
//     try {
//       final addressId = locationData['id'] ?? const Uuid().v4();
      
//       final addressData = {
//         'id': addressId,
//         'title': locationData['type'] ?? 'Home',
//         'address': locationData['address'],
//         'type': (locationData['type'] ?? 'home').toString().toLowerCase(),
//         'lat': locationData['lat'],
//         'lng': locationData['lng'],
//         'phone': locationData['phone'] ?? '',
//         'distance': locationData['distance'] ?? 0.0,
//         'isDefault': false,
//         'createdAt': DateTime.now(),
//         'updatedAt': DateTime.now(),
//         'lastUsedAt': DateTime.now(),
//       };

//       // Check if address already exists
//       final existingIndex = addresses.indexWhere(
//         (addr) => addr['address'] == locationData['address']
//       );

//       if (existingIndex == -1) {
//         // Save to Firestore
//         final user = _auth.currentUser;
//         if (user != null) {
//           await addressesRef.doc(addressId).set({
//             ...addressData,
//             'createdAt': FieldValue.serverTimestamp(),
//             'updatedAt': FieldValue.serverTimestamp(),
//             'lastUsedAt': FieldValue.serverTimestamp(),
//           });
//         }
        
//         // Add to local list
//         addresses.insert(0, addressData);
//         addresses.refresh();
//       }

//       // Select this address
//       await selectAddress(addressData);
      
//       log('✅ Address set from location: ${locationData['address']}');
//     } catch (e) {
//       log('❌ Error setting address from location: $e');
//     }
//   }

//   // ============ NEW: Clear selected address ============
//   void clearSelectedAddress() {
//     selectedAddress.value = {};
//     distanceInKm.value = 0.0;
//     log('✅ Selected address cleared');
//   }

//   // ============ MODIFIED: Update distance for selected address only ============
//   Future<void> updateDistance(double distance) async {
//     distanceInKm.value = distance;

//     if (selectedAddress.isEmpty) return;

//     // Update local selected address
//     selectedAddress['distance'] = distance;
//     selectedAddress.refresh();

//     // Update in Firestore if it's a saved address
//     if (selectedAddress['id'] != null) {
//       await _updateAddressDistance(selectedAddress['id'], distance);
//     }
//   }

//   Future<void> _updateAddressDistance(String addressId, double distance) async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;

//       final docRef = addressesRef.doc(addressId);
//       final docSnapshot = await docRef.get();

//       if (docSnapshot.exists) {
//         await docRef.update({
//           'distance': distance,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });

//         // Update local addresses list
//         final index = addresses.indexWhere((addr) => addr['id'] == addressId);
//         if (index != -1) {
//           addresses[index]['distance'] = distance;
//           addresses.refresh();
//         }
//       }
//     } catch (e) {
//       log('❌ Error updating address distance: $e');
//     }
//   }

//   // ============ PRIVATE HELPER METHODS ============
//   Future<void> _updateAddressLastUsed(String addressId) async {
//     try {
//       final docRef = addressesRef.doc(addressId);
//       final docSnapshot = await docRef.get();

//       if (docSnapshot.exists) {
//         await docRef.update({'lastUsedAt': FieldValue.serverTimestamp()});

//         // Update local address
//         final index = addresses.indexWhere((addr) => addr['id'] == addressId);
//         if (index != -1) {
//           addresses[index]['lastUsedAt'] = DateTime.now();
//           addresses.refresh();
//         }
//       }
//     } catch (e) {
//       log('⚠️ Could not update last used timestamp: $e');
//     }
//   }

//   // ==================== UI HELPER METHODS ====================
//   IconData getAddressIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'home':
//         return Icons.home_rounded;
//       case 'work':
//         return Icons.work_rounded;
//       case 'current':
//         return Icons.my_location_rounded;
//       default:
//         return Icons.location_on_rounded;
//     }
//   }

//   String formatAddressForDisplay(Map<String, dynamic> address) {
//     final title = address['title']?.toString() ?? 'Address';
//     final addr = address['address']?.toString() ?? '';
//     final note = address['note']?.toString();

//     String display = '$title: $addr';
//     if (note != null && note.isNotEmpty) {
//       display += '\nNote: $note';
//     }

//     return display;
//   }

//   // ==================== INITIALIZATION ====================
//   /// Used ONLY for "Current Location" (LOCAL, not Firestore)
//   void setCurrentAddress(Map<String, dynamic> address) {
//     selectedAddress.value = address;

//     final distance = address['distance'];
//     distanceInKm.value = distance is num ? distance.toDouble() : 0.0;

//     log('📍 Current location set locally');
//   }

//   Future<void> _initializeController() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       isLoading.value = true;

//       // Load app configuration from Firebase
//       await loadAppConfig();

//       // Load user data from Firebase
//       await Future.wait([
//         loadCartFromFirebase(),
//         loadAddresses(),
//       ]);

//       isLoading.value = false;
//     } catch (e) {
//       print('❌ Controller initialization error: $e');
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadAppConfig() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('settings')
//         .doc('price_details')
//         .get();

//     if (!snap.exists) return;

//     final data = snap.data()!;
//     log('Fetched app config: ${data.toString()}');

//     platformFee.value = (data['platform_fee'] as num?)?.toDouble() ?? 0;
//     gstPercentage.value = (data['gst_percentage'] as num?)?.toDouble() ?? 0;
//     discount.value = (data['discount_fee'] as num?)?.toDouble() ?? 0;
//     shippingFee.value = (data['shipping_fee'] as num?)?.toDouble() ?? 0;
//   }

//   // ==================== QUANTITY CONTROL METHODS ====================
//   Future<void> increaseQty(String cartId) async {
//     final index = cartItems.indexWhere((e) => e.cartId == cartId);
//     if (index == -1) return;

//     cartItems[index].qty.value++;
//     calculateTotals();

//     await userRef.doc(cartId).update({'quantity': FieldValue.increment(1)});
//   }

//   Future<void> decreaseQty(String cartId) async {
//     final index = cartItems.indexWhere((e) => e.cartId == cartId);
//     if (index == -1) return;

//     cartItems[index].qty.value--;
//     calculateTotals();

//     await userRef.doc(cartId).update({'quantity': FieldValue.increment(-1)});
//   }

//   Future<void> removeItem(String cartId) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('⚠️ User not logged in');
//         return;
//       }

//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('cart')
//           .doc(cartId)
//           .delete();
      
//       print('✅ Cart item removed: $cartId');
//       cartItems.removeWhere((item) => item.cartId == cartId);
//       calculateTotals();
//       loadCartFromFirebase();
//     } catch (e) {
//       print('❌ Remove item error: $e');
//     }
//   }

//   Future<void> loadCartFromFirebase() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
      
//       isLoading.value = true;
//       cartItems.clear();
      
//       QuerySnapshot querySnapshot = await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('cart')
//           .get();

//       for (var doc in querySnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         final cartId = doc.id;
//         cartItems.add(
//           CartItem(
//             id: data['id'] ?? 0,
//             title: data['title'] ?? '',
//             brand: data['brand'] ?? '',
//             price: (data['price'] as num).toDouble(),
//             model: data['model'] ?? '',
//             image: data['image'] ?? '',
//             qty: RxInt(data['quantity'] ?? 1),
//             cartId: cartId,
//           ),
//         );
//       }

//       calculateTotals();
//       isLoading.value = false;
//     } catch (e) {
//       print("❌ Load cart error: $e");
//       isLoading.value = false;
//     }
//   }

//   Future<void> addToCart(Map<String, dynamic> product) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
    
//     var uuid = Uuid();
//     final cartId = uuid.v1();

//     final docRef = _firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('cart')
//         .doc(cartId);

//     await docRef.set({
//       'cartId': cartId,
//       'productId': product['serviceId'],
//       'title': product['title'],
//       'brand': product['brand'],
//       'model': product['model'],
//       'price': product['price'],
//       'image': product['image'],
//       'quantity': product['quantity'],
//       'createdAt': FieldValue.serverTimestamp(),
//     }).then((value) {
//       Get.to(() => const CartView());
//       loadCartFromFirebase();
//     });
//   }

//   Future<void> clearCart() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     final docRef = _firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('cart');
    
//     try {
//       final snapshot = await docRef.get();
//       final batch = _firestore.batch();

//       for (var doc in snapshot.docs) {
//         batch.delete(doc.reference);
//       }

//       await batch.commit();
//       cartItems.clear();
//       calculateTotals();
//     } catch (e) {
//       print("❌ Clear cart error: $e");
//     }
//   }

//   // ==================== CALCULATION METHODS ====================
//   void calculateTotals() {
//     subtotal.value = cartItems.fold(
//       0.0,
//       (sum, item) => sum + item.price * item.qty.value,
//     );
//     _calculateGST();
//     _calculateTotal();
//   }

//   void _calculateGST() {
//     gstAmount.value = gstPercentage.value > 0 ? gstPercentage.value : 0;
//   }

//   void _calculateTotal() {
//     totalPrice.value =
//         subtotal.value -
//         discount.value +
//         platformFee.value +
//         shippingFee.value +
//         gstAmount.value;
//   }

//   Future<List<Map<String, dynamic>>> getSavedCarts() async {
//     try {
//       final snapshot = await savedCartsRef
//           .orderBy('createdAt', descending: true)
//           .get();
//       return snapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();
//     } catch (e) {
//       print('❌ Error loading saved carts: $e');
//       return [];
//     }
//   }

//   int get totalItemCount =>
//       cartItems.fold(0, (sum, item) => sum + item.qty.value);

//   bool get isCartEmpty => cartItems.isEmpty;

//   Map<String, dynamic> getCartSummary() {
//     return {
//       'itemCount': totalItemCount,
//       'subtotal': subtotal.value,
//       'discount': discount.value,
//       'shippingFee': shippingFee.value,
//       'platformFee': platformFee.value,
//       'gstAmount': gstAmount.value,
//       'total': totalPrice.value,
//     };
//   }

//   // Real-time cart stream
//   Stream<List<CartItem>> getCartStream() {
//     final user = _auth.currentUser;
//     if (user == null) return Stream.value([]);
//     return userRef.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return CartItem(
//           id: data['id'] ?? 0,
//           title: data['title'] ?? '',
//           brand: data['brand'] ?? '',
//           model: data['model'] ?? '',
//           price: (data['price'] as num).toDouble(),
//           image: data['image'] ?? '',
//           qty: RxInt(data['quantity'] ?? 1),
//           notes: data['notes'],
//         );
//       }).toList();
//     });
//   }

//   // Real-time addresses stream
//   Stream<List<Map<String, dynamic>>> getAddressesStream() {
//     final user = _auth.currentUser;
//     if (user == null) return Stream.value([]);

//     return addressesRef.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return {
//           'id': doc.id,
//           ...data,
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//         };
//       }).toList();
//     });
//   }
// }
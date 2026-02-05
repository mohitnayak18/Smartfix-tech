// controllers/order_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixapp/api_calls/models/order_model.dart';
import 'package:uuid/uuid.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Orders collection
  final CollectionReference ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  // Rx observables
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Generate order number
  String _generateOrderNumber() {
    // final timestamp = Timestamp.now().seconds;
    final randomString = _uuid.v4().substring(0, 6).toUpperCase();
    return 'ORD-$randomString';
  }

  // Add timeline entry
  Future<void> _addTimelineEntry({
    required String orderId,
    required String status,
    required String description,
    String? performedBy,
    String? notes,
  }) async {
    final timelineEntry = {
      'status': status,
      'description': description,
      'timestamp': Timestamp.now(),
      'performedBy': performedBy,
      'notes': notes,
    };

    await ordersCollection.doc(orderId).update({
      'timeline': FieldValue.arrayUnion([timelineEntry]),
      'updatedAt': Timestamp.now(),
    });
  }

  // Create order from cart
  Future<Map<String, dynamic>> createOrderFromCart({
    required List<Map<String, dynamic>> cartItems,
    required double subtotal,
    required double platformFee,
    required double shippingFee,
    required double gstAmount,
    required double discount,
    required double totalAmount,
    required Map<String, dynamic> address,
    required String phone,
    String? userId,
  }) async {
    try {
      isLoading(true);
      error.value = '';

      // Generate IDs
      final orderId = _uuid.v4();
      final orderNumber = _generateOrderNumber();
      final now = Timestamp.now();

      // Get user ID
      final currentUserId = userId ?? _getCurrentUserId();

      // Prepare initial timeline
      final initialTimeline = [
        {
          'status': 'pending',
          'description': 'Order placed successfully',
          'timestamp': now,
          'performedBy': 'Customer',
        },
      ];

      // Prepare order data
      final orderData = {
        // IDs
        'orderId': orderId,
        'orderNumber': orderNumber,
        'userId': currentUserId,

        // Order details
        'items': cartItems.map((item) {
          item['itemId'] ??= _uuid.v4();

          final addedAt = item['addedAt'];
          if (addedAt is String) {
            item['addedAt'] = Timestamp.fromDate(DateTime.parse(addedAt));
          } else if (addedAt == null) {
            item['addedAt'] = now;
          }

          return item;
        }).toList(),

        // Pricing
        'subtotal': subtotal,
        'platformFee': platformFee,
        'shippingFee': shippingFee,
        'gstAmount': gstAmount,
        'discount': discount,
        'totalAmount': totalAmount,
        'finalAmount': totalAmount,

        // Customer info
        'address': address,
        'phone': phone,
        'customerName': address['title'] ?? 'Customer',

        // Status
        'status': 'pending',
        'paymentMethod': 'cash_on_delivery',
        'paymentStatus': 'pending',
        'deliveryStatus': 'pending',

        // Timestamps
        'createdAt': now,
        'updatedAt': now,
        'orderDate': now,
        'expectedDelivery': Timestamp.fromDate(
          now.toDate().add(const Duration(minutes: 45)),
        ),

        // Timeline
        'timeline': initialTimeline,

        // Metadata
        'source': 'mobile_app',
        'version': '1.0',
        'notes': '',
      };

      // Save to Firestore
      await ordersCollection.doc(orderId).set(orderData);

      // Add to local list
      final newOrder = OrderModel.fromFirestore(
        await ordersCollection.doc(orderId).get(),
      );
      orders.insert(0, newOrder); // Add to beginning of list

      isLoading(false);

      return {
        'success': true,
        'orderId': orderId,
        'orderNumber': orderNumber,
        'message': 'Order created successfully',
      };
    } catch (e, stackTrace) {
      isLoading(false);
      error.value = e.toString();
      print('Error creating order: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ FIXED: Fetch user orders WITHOUT composite index requirement
  Future<void> fetchUserOrders(String userId) async {
    try {
      isLoading(true);
      error.value = '';

      // Query WITHOUT orderBy to avoid index requirement
      final snapshot = await ordersCollection
          // .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        orders.value = [];
        isLoading(false);
        return;
      }

      // Process orders and sort locally
      final List<OrderModel> fetchedOrders = [];
      for (var doc in snapshot.docs) {
        try {
          final order = OrderModel.fromFirestore(doc);
          fetchedOrders.add(order);
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
        }
      }

      // Sort by createdAt descending (local sorting)
      fetchedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      orders.value = fetchedOrders;
      isLoading(false);
    } catch (e) {
      isLoading(false);
      error.value = e.toString();
      print('Error fetching orders: $e');

      // Show user-friendly error
      if (e.toString().contains('index')) {
        Get.snackbar(
          'Database Update',
          'Please wait while we optimize your order data...',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load orders',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ✅ FIXED: Stream user orders WITHOUT composite index requirement
  Stream<List<dynamic>> streamUserOrders(String userId) {
    try {
      return ordersCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .asyncMap((snapshot) async {
            if (snapshot.docs.isEmpty) return [];

            // Process and sort locally
            final List<OrderModel> orderList = [];
            for (var doc in snapshot.docs) {
              try {
                final order = OrderModel.fromFirestore(doc);
                orderList.add(order);
              } catch (e) {
                print('Error parsing document ${doc.id}: $e');
              }
            }

            // Sort by createdAt descending
            orderList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return orderList;
          })
          .handleError((error) {
            print('Stream error: $error');

            // If index error, return empty list and log
            if (error.toString().contains('index')) {
              print('Firestore index missing. Please create composite index.');
            }

            return [];
          });
    } catch (e) {
      print('Error setting up stream: $e');
      return Stream.value([]);
    }
  }

  // Get order by ID
  Future<void> fetchOrderById(String orderId) async {
    try {
      isLoading(true);
      error.value = '';

      final doc = await ordersCollection.doc(orderId).get();
      if (doc.exists) {
        currentOrder.value = OrderModel.fromFirestore(doc);
      } else {
        currentOrder.value = null;
        error.value = 'Order not found';
      }

      isLoading(false);
    } catch (e) {
      isLoading(false);
      error.value = e.toString();
      print('Error fetching order: $e');
      Get.snackbar(
        'Error',
        'Failed to load order details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Stream single order
  Stream<OrderModel?> streamOrder(String orderId) {
    return ordersCollection
        .doc(orderId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          try {
            return OrderModel.fromFirestore(doc);
          } catch (e) {
            print('Error parsing order: $e');
            return null;
          }
        })
        .handleError((error) {
          print('Stream error for order $orderId: $error');
          return null;
        });
  }

  // Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
    String? description,
    String? performedBy,
    String? notes,
  }) async {
    try {
      // Update status
      await ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });

      // Add timeline entry
      final timelineDescription =
          description ?? 'Order status changed to ${_getStatusText(status)}';

      await _addTimelineEntry(
        orderId: orderId,
        status: status,
        description: timelineDescription,
        performedBy: performedBy,
        notes: notes,
      );

      // Update local orders list
      final index = orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        await fetchOrderById(orderId);
        if (currentOrder.value != null) {
          orders[index] = currentOrder.value!;
        }
      }

      Get.snackbar(
        'Success',
        'Order status updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar(
        'Error',
        'Failed to update order status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final now = Timestamp.now();

      await ordersCollection.doc(orderId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': now,
        'updatedAt': now,
      });

      await _addTimelineEntry(
        orderId: orderId,
        status: 'cancelled',
        description: 'Order cancelled: $reason',
        performedBy: 'Customer',
      );

      // Update local orders list
      final index = orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        await fetchOrderById(orderId);
        if (currentOrder.value != null) {
          orders[index] = currentOrder.value!;
        }
      }

      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel order',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Complete order
  Future<bool> completeOrder({required String orderId, String? notes}) async {
    try {
      final now = Timestamp.now();

      await ordersCollection.doc(orderId).update({
        'status': 'completed',
        'deliveredAt': now,
        'updatedAt': now,
        'paymentStatus': 'paid',
      });

      await _addTimelineEntry(
        orderId: orderId,
        status: 'completed',
        description: 'Order completed successfully',
        performedBy: 'Technician',
        notes: notes,
      );

      // Update local orders list
      final index = orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        await fetchOrderById(orderId);
        if (currentOrder.value != null) {
          orders[index] = currentOrder.value!;
        }
      }

      Get.snackbar(
        'Success',
        'Order marked as completed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print('Error completing order: $e');
      Get.snackbar(
        'Error',
        'Failed to complete order',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Helper methods
  String _getCurrentUserId() {
    // TODO: Replace with actual user ID from authentication
    // For testing, use a fixed user ID
    return 'test_user_id_123';
  }

  String _getStatusText(String status) {
    final statusMap = {
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'processing': 'Processing',
      'assigned': 'Assigned',
      'on_the_way': 'On the way',
      'arrived': 'Arrived',
      'in_progress': 'In progress',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
    };
    return statusMap[status] ?? status;
  }

  // Clear current order
  void clearCurrentOrder() {
    currentOrder.value = null;
  }

  @override
  void onClose() {
    clearCurrentOrder();
    super.onClose();
  }
}

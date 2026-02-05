// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:smartfixapp/api_calls/models/order_model.dart';
// import 'package:uuid/uuid.dart';

// class OrderRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   CollectionReference<Map<String, dynamic>> get _orders =>
//       _firestore.collection('orders');

//   String _generateOrderNumber() {
//     return 'ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}';
//   }

//   /// CREATE ORDER
//   Future<OrderModel> createOrder(OrderModel order) async {
//     try {
//       final orderNumber = _generateOrderNumber();

//       final docRef = _orders.doc();

//       final data = {
//         ...order.toMap(),
//         'orderNumber': orderNumber,
//         'userId': order.userId,
//         'orderDate': order.orderDate,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       };

//       await docRef.set(data);

//       return order.copyWith(
//         id: docRef.id,
//         orderNumber: orderNumber,
//       );
//     } catch (e) {
//       log('Create order error: $e');
//       rethrow;
//     }
//   }

//   /// STREAM USER ORDERS
//   Stream<List<OrderModel>> getOrdersByUser(String userId) {
//     return _orders
//         .where('userId', isEqualTo: userId)
//         .orderBy('orderDate', descending: true)
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map((doc) => OrderModel.fromMap(doc.data()).copyWith(id: doc.id))
//               .toList(),
//         );
//   }

//   /// LOAD ONCE
//   Future<List<OrderModel>> getOrdersOnce(String userId) async {
//     final snapshot = await _orders
//         .where('userId', isEqualTo: userId)
//         .orderBy('orderDate', descending: true)
//         .get();

//     return snapshot.docs
//         .map((doc) => OrderModel.fromMap(doc.data()).copyWith(id: doc.id))
//         .toList();
//   }

//   /// CANCEL ORDER
//   Future<void> cancelOrder(String orderId, String reason) async {
//     await _orders.doc(orderId).update({
//       'status': 'cancelled',
//       'cancellationReason': reason,
//       'cancelledAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   /// UPDATE STATUS
//   Future<void> updateOrderStatus(String orderId, String status) async {
//     await _orders.doc(orderId).update({
//       'status': status,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }
// }

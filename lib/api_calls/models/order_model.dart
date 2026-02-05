// models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderModel {
  final String orderId;
  final String orderNumber;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double platformFee;
  final double shippingFee;
  final double gstAmount;
  final double discount;
  final double totalAmount;
  final OrderAddress address;
  final String phone;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryStatus;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? expectedDelivery;
  final Timestamp? deliveredAt;
  final Timestamp? cancelledAt;
  final String? cancellationReason;
  final List<OrderTimeline> timeline;
  final String? assignedTechnicianId;
  final String? assignedTechnicianName;
  final String? notes;

  OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.platformFee,
    required this.shippingFee,
    required this.gstAmount,
    required this.discount,
    required this.totalAmount,
    required this.address,
    required this.phone,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.createdAt,
    required this.updatedAt,
    this.expectedDelivery,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    this.timeline = const [],
    this.assignedTechnicianId,
    this.assignedTechnicianName,
    this.notes,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse items
    final List<OrderItem> items = [];
    if (data['items'] != null && data['items'] is List) {
      for (var item in data['items']) {
        items.add(OrderItem.fromMap(item));
      }
    }
    
    // Parse address
    final address = OrderAddress.fromMap(data['address'] ?? {});
    
    // Parse timeline
    final List<OrderTimeline> timeline = [];
    if (data['timeline'] != null && data['timeline'] is List) {
      for (var timelineItem in data['timeline']) {
        timeline.add(OrderTimeline.fromMap(timelineItem));
      }
    }
    
    return OrderModel(
      orderId: data['orderId'] ?? doc.id,
      orderNumber: data['orderNumber'] ?? '',
      userId: data['userId'] ?? '',
      items: items,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      platformFee: (data['platformFee'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (data['gstAmount'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      address: address,
      phone: data['phone'] ?? '',
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'cash_on_delivery',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      deliveryStatus: data['deliveryStatus'] ?? 'pending',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      expectedDelivery: data['expectedDelivery'] as Timestamp?,
      deliveredAt: data['deliveredAt'] as Timestamp?,
      cancelledAt: data['cancelledAt'] as Timestamp?,
      cancellationReason: data['cancellationReason'],
      timeline: timeline,
      assignedTechnicianId: data['assignedTechnicianId'],
      assignedTechnicianName: data['assignedTechnicianName'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'platformFee': platformFee,
      'shippingFee': shippingFee,
      'gstAmount': gstAmount,
      'discount': discount,
      'totalAmount': totalAmount,
      'address': address.toMap(),
      'phone': phone,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'deliveryStatus': deliveryStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expectedDelivery': expectedDelivery,
      'deliveredAt': deliveredAt,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
      'timeline': timeline.map((item) => item.toMap()).toList(),
      'assignedTechnicianId': assignedTechnicianId,
      'assignedTechnicianName': assignedTechnicianName,
      'notes': notes,
    };
  }

  // Helper getters
  String get formattedDate => _formatTimestamp(createdAt);
  String get formattedUpdatedDate => _formatTimestamp(updatedAt);
  String get formattedExpectedDelivery => expectedDelivery != null 
      ? _formatTimestamp(expectedDelivery!) 
      : 'Not set';
  String get formattedDeliveredDate => deliveredAt != null 
      ? _formatTimestamp(deliveredAt!) 
      : 'Not delivered';
  String get formattedCancelledDate => cancelledAt != null 
      ? _formatTimestamp(cancelledAt!) 
      : 'Not cancelled';
  
  String get formattedAmount => '₹${NumberFormat('#,##0').format(totalAmount)}';
  String get itemCountText => '${items.length} ${items.length == 1 ? 'item' : 'items'}';
  
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'assigned':
        return Colors.indigo;
      case 'on_the_way':
        return Colors.teal;
      case 'arrived':
        return Colors.lightBlue;
      case 'in_progress':
        return Colors.deepPurple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'assigned':
        return 'Assigned to Technician';
      case 'on_the_way':
        return 'Technician on the way';
      case 'arrived':
        return 'Technician arrived';
      case 'in_progress':
        return 'Service in progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.refresh;
      case 'assigned':
        return Icons.person_add;
      case 'on_the_way':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
      case 'in_progress':
        return Icons.build;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }
}

class OrderItem {
  final String itemId;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final String? serviceType;
  final String? estimatedDuration;
  final Timestamp? addedAt;

  OrderItem({
    required this.itemId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.serviceType,
    this.estimatedDuration,
    this.addedAt,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: map['itemId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      serviceType: map['serviceType'],
      estimatedDuration: map['estimatedDuration'],
      addedAt: map['addedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'serviceType': serviceType,
      'estimatedDuration': estimatedDuration,
      'addedAt': addedAt,
    };
  }

  double get total => price * quantity;
  String get formattedPrice => '₹${NumberFormat('#,##0').format(price)}';
  String get formattedTotal => '₹${NumberFormat('#,##0').format(total)}';
  
  String get formattedAddedDate => addedAt != null 
      ? DateFormat('dd MMM yyyy').format(addedAt!.toDate())
      : '';
}

class OrderAddress {
  final String title;
  final String address;
  final String type;
  final double? latitude;
  final double? longitude;

  OrderAddress({
    required this.title,
    required this.address,
    required this.type,
    this.latitude,
    this.longitude,
  });

  factory OrderAddress.fromMap(Map<String, dynamic> map) {
    return OrderAddress(
      title: map['title'] ?? 'Address',
      address: map['address'] ?? '',
      type: map['type'] ?? 'other',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  IconData get icon {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}

class OrderTimeline {
  final String status;
  final String description;
  final Timestamp timestamp;
  final String? performedBy;
  final String? notes;

  OrderTimeline({
    required this.status,
    required this.description,
    required this.timestamp,
    this.performedBy,
    this.notes,
  });

  factory OrderTimeline.fromMap(Map<String, dynamic> map) {
    return OrderTimeline(
      status: map['status'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
      performedBy: map['performedBy'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'description': description,
      'timestamp': timestamp,
      'performedBy': performedBy,
      'notes': notes,
    };
  }

  String get formattedTime => DateFormat('hh:mm a').format(timestamp.toDate());
  String get formattedDate => DateFormat('dd MMM yyyy').format(timestamp.toDate());
  String get formattedDateTime => DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
}
import 'package:get/get.dart';

class CartItem {
  final String? serviceId;
  final String? serviceName;
  final String? productId;  // Changed from int to String? to match Firestore data
  final String title;
  final String brand;
  final String model;
  final double price;
  final String image;
  final String? customerNote;
  // final String? notes;
  final String? cartId;
  final RxInt qty;

  CartItem({
    this.serviceId,
    this.serviceName,
    this.productId,  // Now accepts String? instead of int
    required this.title,
    required this.brand,
    required this.model,
    required this.price,
    required this.image,
    // this.notes,
    this.customerNote,
    this.cartId,
    required this.qty, 
    // required String serviceId, 
    // required String productId, 
    // required String serviceName, 
    // required String servicename,
  });

  // Convert CartItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'serviceName': serviceName,
      'title': title,
      'brand': brand,
      'model': model,
      'price': price,
      'image': image,
      // 'notes': notes,
      'cartId': cartId,
      'quantity': qty.value,
      'customerNote': customerNote,
    };
  }

  // Create CartItem from Firestore document
  factory CartItem.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CartItem(
      serviceId: data['serviceId']?.toString(), // Convert to String safely
      serviceName: data['serviceName'] ?? '',
      productId: data['productId']?.toString(), // Convert to String safely
      title: data['title'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
      // notes: data['notes'],
      customerNote: data['customerNote'] ?? '',
      cartId: documentId,
      qty: RxInt(data['quantity'] ?? 1),
    );
  }

  // Copy with method for updating
  CartItem copyWith({
    String? serviceName,
    String? serviceId,
    String? title,
    String? brand,
    String? model,
    double? price,
    String? image,
    String? notes,
    String? cartId,
    int? qty,
  }) {
    return CartItem(
      serviceName: serviceName ?? this.serviceName,
      serviceId: serviceId ?? this.serviceId,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      price: price ?? this.price,
      image: image ?? this.image,
      // notes: notes ?? this.notes,
      cartId: cartId ?? this.cartId,
      qty: RxInt(qty ?? this.qty.value),
    );
  }
}
import 'package:get/get.dart';

class CartItem {
  final int id;
  final String? serviceId;
  final String model;
  final String title;
  final String brand;
  final double price;
  final String image;
  final String? cartId;
  RxInt qty;
  String? notes;

  CartItem({
    required this.model,
    this.serviceId,
    required this.id,
    required this.title,
    required this.brand,
    required this.price,
    required this.image,
    required this.qty,
    this.notes,
    this.cartId,
  });

  // Optional: Add copyWith method for easier updates
  CartItem copyWith({
    int? id,
    String? serviceId,
    String? title,
    String? brand,
    double? price,
    String? image,
    RxInt? qty,
    String? notes,
    String? model,
  }) {
    return CartItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      image: image ?? this.image,
      qty: qty ?? this.qty,
      notes: notes ?? this.notes,
      model: model ?? this.model,
    );
  }

  void operator [](String other) {}
}

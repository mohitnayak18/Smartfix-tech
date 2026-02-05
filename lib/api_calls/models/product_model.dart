// api_calls/models/product_model.dart
class ProductModel {
  final String id;
  final String title;
  final int price;
  final String imageUrl; // This will store img@clr1
  final String brandId;
  final bool isAvailable;
  final int cutOfferPrice;
  final int offerPercentage;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.brandId,
    this.isAvailable = true,
    this.cutOfferPrice = 0,
    this.offerPercentage = 0,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      title: data['name'] ?? '',
      price: _parsePrice(data['originalprice']),
      // Handle both possible field names
      imageUrl:  data['imageUrl'] ?? '',
      brandId: data['id'] ?? data['brandId'] ?? '',
      isAvailable: data['isAvailable']?.toString().toLowerCase() == 'true',
      cutOfferPrice: _parsePrice(data['cutofferprice']),
      offerPercentage: _parseInt(data['offerpercentage']),
    );
  }

  static int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.toInt();
    if (price is String) return int.tryParse(price) ?? 0;
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Get discounted price
  int get discountedPrice {
    if (offerPercentage > 0) {
      return price - (price * offerPercentage ~/ 100);
    }
    return price;
  }

  bool get hasOffer => offerPercentage > 0;

  Map<String, dynamic> toMap() {
    return {
      'name': title,
      'originalprice': price,
      
      'imageUrl': imageUrl,
      'brandId': brandId,
      'isAvailable': isAvailable,
      'cutofferprice': cutOfferPrice,
      'offerpercentage': offerPercentage,
    };
  }

}
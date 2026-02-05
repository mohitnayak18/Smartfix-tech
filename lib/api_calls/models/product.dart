import 'dart:convert';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  Product({
    this.id,
    this.subCatgoryId,
    this.name,
    this.price,
    this.discount,
    this.image,
  });

  int? id;
  String? subCatgoryId;
  String? name;
  String? price;
  String? discount;
  String? image;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"] as int? ?? 0,
        subCatgoryId: json["subCatgoryId"] as String? ?? '',
        name: json["name"] as String? ?? '',
        price: json["price"] as String? ?? '',
        discount: '${json["discount"]}',
        image: json["image"] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subCatgoryId": subCatgoryId,
        "name": name,
        "price": price,
        "discount": discount,
        "image": image,
      };
}

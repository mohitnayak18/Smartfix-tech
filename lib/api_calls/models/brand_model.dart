class BrandModel {
  final String id;
  final String name;
  final String imageUrl;
  final int orderIndex;

  BrandModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.orderIndex,
  });

  factory BrandModel.fromMap(Map<String, dynamic> data, String id) {
    return BrandModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      orderIndex: data['orderIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'orderIndex': orderIndex,
    };
  }
}
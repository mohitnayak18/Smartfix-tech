// models/service_model.dart
class ServiceModel {
  String id;
  String name;
  
  ServiceModel({
    required this.id,
    required this.name,
  });

  factory ServiceModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceModel(
      id: id,
      name: map['name'] ?? '',
    );
  }
}
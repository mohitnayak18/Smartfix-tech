// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔥 Replace with YOUR real API base URL
  static const String baseUrl =
      'https://66e8f91c87e41760944800e5.mockapi.io/api/v1/brands/1/models';

  // Fetch all mobile models
  static Future<List<MobileModel>> fetchModels() async {
    final url = Uri.parse('$baseUrl/mobile-models');
    print("API CALL: $url");

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final List data = json.decode(resp.body);
      return data.map((e) => MobileModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load models (${resp.statusCode})');
    }
  }

  // Fetch repair products for selected model
  static Future<List<RepairProduct>> fetchRepairsForModel(
    String modelId,
  ) async {
    final url = Uri.parse('$baseUrl/mobile-models/$modelId/repairs');
    print("API CALL: $url");

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final List data = json.decode(resp.body);
      return data.map((e) => RepairProduct.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load repairs (${resp.statusCode})');
    }
  }
}

// Simple data classes

class MobileModel {
  final String id;
  final String brand;
  final String name;
  final String? imageUrl;

  MobileModel({
    required this.id,
    required this.brand,
    required this.name,
    this.imageUrl,
  });

  factory MobileModel.fromJson(Map<String, dynamic> json) {
    return MobileModel(
      id: json['id'].toString(),
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? json['image'],
    );
  }
}

class RepairProduct {
  final String id;
  final String title;
  final String description;
  final String price;
  final String? imageUrl;

  RepairProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  factory RepairProduct.fromJson(Map<String, dynamic> json) {
    return RepairProduct(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '',
      imageUrl: json['image_url'] ?? json['image'],
    );
  }
}

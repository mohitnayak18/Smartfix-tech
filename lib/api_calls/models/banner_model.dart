import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

List<BannerModel> bannerFromJson(String str) =>
    List<BannerModel>.from(
      json.decode(str).map((x) => BannerModel.fromJson(x)),
    );

String bannerToJson(List<BannerModel> data) =>
    json.encode(
      List<dynamic>.from(data.map((x) => x.toJson())),
    );

class BannerModel {
  BannerModel({
    this.id,
    this.imagePath,
    this.status,
  });

  int? id;
  String? imagePath;
  bool? status;

  /// 🔥 Firestore constructor
  factory BannerModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BannerModel(
      id: data['id'] ?? 0,
      imagePath: data['imagePath'] ?? '',
      status: data['active'] ?? false,
    );
  }

  /// JSON constructor (API / local)
  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] ?? 0,
        imagePath: json['imagePath'] ?? '',
        status: json['status'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'status': status == true ? 1 : 0,
      };
}

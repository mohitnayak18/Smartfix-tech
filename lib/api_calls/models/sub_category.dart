// To parse this JSON data, do
//
//     final subCategory = subCategoryFromJson(jsonString);

import 'dart:convert';

import 'catagory_response.dart';

SubCategory subCategoryFromJson(String str) =>
    SubCategory.fromJson(json.decode(str));

String subCategoryToJson(SubCategory data) => json.encode(data.toJson());

class SubCategory {
  SubCategory({
    required this.data,
    required this.success,
    this.message,
  });

  List<SubCategoryData> data;
  bool success;
  dynamic message;

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        data: List<SubCategoryData>.from(
            json["data"].map((x) => SubCategoryData.fromJson(x))),
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "success": success,
        "message": message,
      };
}

class SubCategoryData {
  SubCategoryData({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.bannerPath,
    required this.status,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.categoryData,
  });

  String id;
  CategoryModel categoryData;
  String name;
  String imagePath;
  String bannerPath;
  String status;
  int displayOrder;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory SubCategoryData.fromJson(Map<String, dynamic> json) =>
      SubCategoryData(
        id: json["_id"],
        categoryData: CategoryModel.fromJson(json["categoryData"]),
        name: json["name"],
        imagePath: json["imagePath"],
        bannerPath: json["bannerPath"],
        status: json["status"],
        displayOrder: json["displayOrder"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "categoryData": categoryData,
        "imagePath": imagePath,
        "bannerPath": bannerPath,
        "status": status,
        "displayOrder": displayOrder,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

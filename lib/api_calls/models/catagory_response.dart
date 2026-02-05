// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

Category categoryListFromJson(String str) =>
    Category.fromJson(json.decode(str));

String categoryListToJson(Category data) => json.encode(data.toJson());

class Category {
  Category({
    this.data,
    this.message,
  });

  List<CategoryModel>? data;
  String? message;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        data: List<CategoryModel>.from(
            json["data"].map((x) => CategoryModel.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

CategoryModel categoryFromJson(String str) =>
    CategoryModel.fromJson(json.decode(str));

String categoryToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
  CategoryModel({
    this.name,
    this.imagePath,
    this.status,
    this.statusName,
    this.displayOrder,
    this.id,
    this.v,
  });

  String? name;
  String? imagePath;
  String? status;
  dynamic statusName;
  int? displayOrder;
  String? id;
  int? v;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        name: json["name"],
        imagePath: json["imagePath"],
        status: json["status"],
        statusName: json["statusName"],
        displayOrder: json["displayOrder"],
        id: json["_id"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "imagePath": imagePath,
        "status": status,
        "statusName": statusName,
        "displayOrder": displayOrder,
        "_id": id,
        "__v": v,
      };
}

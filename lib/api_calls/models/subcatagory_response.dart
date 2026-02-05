// To parse this JSON data, do
//
//     final subCategory = subCategoryFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

import 'catagory_response.dart';

SubCategory subCategoryFromJson(String str) =>
    SubCategory.fromJson(json.decode(str));

String subCategoryToJson(SubCategory data) => json.encode(data.toJson());

class SubCategory {
  SubCategory({
    this.data,
    this.success,
    this.message,
  });

  List<SubCategoryData>? data;
  bool? success;
  dynamic message;

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        data: List<SubCategoryData>.from(
            json["data"].map((x) => SubCategoryData.fromJson(x))),
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
        "message": message,
      };
}

class SubCategoryData {
  SubCategoryData({
    this.id,
    this.name,
    this.imagePath,
    this.bannerPath,
    this.status,
    this.displayOrder,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.categoryData,
    this.globalKey,
  });

  String? id;
  CategoryModel? categoryData;
  String? name;
  String? imagePath;
  String? bannerPath;
  String? status;
  int? displayOrder;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  GlobalKey? globalKey;

  factory SubCategoryData.fromJson(Map<String, dynamic> json) =>
      SubCategoryData(
        globalKey: GlobalKey(),
        id: json["_id"],
        categoryData: json["categoryData"] == null
            ? null
            : CategoryModel.fromJson(json["categoryData"]),
        name: json["name"],
        imagePath: json["imagePath"] ?? '',
        bannerPath: json["bannerPath"] ?? '',
        status: json["status"] ?? '',
        displayOrder: json["displayOrder"] ?? 0,
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
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

// To parse this JSON data, do
//
//     final service = serviceFromJson(jsonString);

import 'dart:convert';
import 'dart:developer';


import 'package:smartfixTech/api_calls/models/sub_category.dart';

Service serviceFromJson(String str) => Service.fromJson(json.decode(str));

String serviceToJson(Service data) => json.encode(data.toJson());

class Service {
  Service({
    this.data,
    this.success,
    this.message,
  });

  List<ServiceData>? data;
  bool? success;
  dynamic message;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        data: List<ServiceData>.from(
            json["data"].map((x) => ServiceData.fromJson(x))),
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from((data ?? []).map((x) => x.toJson())),
        "success": success,
        "message": message,
      };
}

class ServiceData {
  ServiceData({
    this.id,
    this.subCatgoryData,
    this.name,
    this.descriptions,
    this.note,
    this.price,
    this.discount,
    this.status,
    this.isBestSeller,
    this.noOfOrders,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.image,
  });

  String? id;
  SubCategoryData? subCatgoryData;
  String? name;
  String? descriptions;
  String? note;
  num? price;
  num? discount;
  String? status;
  bool? isBestSeller;
  int? noOfOrders;
  String? createdAt;
  String? updatedAt;
  List<String>? image;
  int? v;

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    log('QWERTY ${json["note"]}');
    return ServiceData(
      id: json["_id"] ?? '',
      subCatgoryData: SubCategoryData.fromJson(json["subCatgoryData"]),
      name: json["name"],
      descriptions: json["descriptions"] ?? '',
      note: json["note"] ?? '',
      image: List<String>.from(json["image"].map((x) => x)),
      price: json["price"] ?? 0.0,
      discount: json["discount"] ?? '',
      status: json["status"] ?? '',
      isBestSeller: json["isBestSeller"] ?? false,
      noOfOrders: json["noOfOrders"] ?? '',
      createdAt: json["createdAt"] ?? '',
      updatedAt: json["updatedAt"] ?? '',
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "subCatgoryData": subCatgoryData?.toJson(),
        "name": name,
        "descriptions": descriptions,
        "note": note,
        "price": price,
        "discount": discount,
        "status": status,
        "isBestSeller": isBestSeller,
        "noOfOrders": noOfOrders,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "image": image,
        "__v": v,
      };
}

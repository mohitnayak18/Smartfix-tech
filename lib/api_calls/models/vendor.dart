// To parse this JSON data, do
//
//     final vendorModel = vendorModelFromJson(jsonString);

import 'dart:convert';

VendorModel vendorModelFromJson(String str) =>
    VendorModel.fromJson(json.decode(str));

String vendorModelToJson(VendorModel data) => json.encode(data.toJson());

class VendorModel {
  VendorModel({
    this.data,
    this.success,
    this.message,
  });

  List<VendorData>? data;
  bool? success;
  dynamic message;

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
        data: List<VendorData>.from(
            json["data"].map((x) => VendorData.fromJson(x))),
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
        "message": message,
      };
}

class VendorData {
  VendorData({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.aadharcardupload,
    this.pancardupload,
    required this.phone,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  String id;
  String name;
  String email;
  String? profileImage;
  String? aadharcardupload;
  String? pancardupload;
  String phone;
  String password;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory VendorData.fromJson(Map<String, dynamic> json) => VendorData(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        profileImage: json["profileImage"],
        aadharcardupload: json["aadharcardupload"],
        pancardupload: json["pancardupload"],
        phone: json["phone"],
        password: json["password"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "profileImage": profileImage,
        "aadharcardupload": aadharcardupload,
        "pancardupload": pancardupload,
        "phone": phone,
        "password": password,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}

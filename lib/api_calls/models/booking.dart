// To parse this JSON data, do
//
//     final booking = bookingFromJson(jsonString);

import 'dart:convert';

import 'package:smartfixTech/api_calls/models/location_response_model.dart';
import 'package:smartfixTech/api_calls/models/models.dart';

Booking bookingFromJson(String str) => Booking.fromJson(json.decode(str));

String bookingToJson(Booking data) => json.encode(data.toJson());

class Booking {
  Booking({
    this.data,
    this.success,
    this.message,
  });

  List<BookingData>? data;
  bool? success;
  dynamic message;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        data: List<BookingData>.from(
            json["data"].map((x) => BookingData.fromJson(x))).reversed.toList(),
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
        "message": message,
      };
}

class BookingData {
  BookingData({
    this.id,
    this.userId,
    this.serviceData,
    this.cityData,
    this.name,
    this.phone,
    this.bookingTime,
    this.address,
    this.orderStatus,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
    this.otp,
    this.v,
    this.vendorData,
  });

  String? id;
  String? userId;
  ServiceData? serviceData;
  CityData? cityData;
  String? name;
  String? phone;
  String? bookingTime;
  VendorData? vendorData;
  String? address;
  String? orderStatus;
  String? orderDate;
  String? createdAt;
  String? updatedAt;
  String? otp;
  int? v;

  factory BookingData.fromJson(Map<String, dynamic> json) => BookingData(
        id: json["_id"],
        userId: json["userId"],
        serviceData: ServiceData.fromJson(json["ServiceData"]),
        cityData: CityData.fromJson(json["cityData"]),
        vendorData: json["vendorData"] == null
            ? null
            : VendorData.fromJson(json["vendorData"]),
        name: json["name"],
        phone: json["phone"],
        bookingTime: json["bookingTime"],
        address: json["address"],
        orderStatus: json["orderStatus"],
        orderDate: json["orderDate"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        otp: json["otp"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "ServiceData": serviceData?.toJson(),
        "cityData": cityData?.toJson(),
        "vendorData": vendorData?.toJson(),
        "name": name,
        "phone": phone,
        "bookingTime": bookingTime,
        "address": address,
        "orderStatus": orderStatus,
        "orderDate": orderDate,
        "createdAt": createdAt,
        "otp": otp,
        "updatedAt": updatedAt,
        "__v": v,
      };
}

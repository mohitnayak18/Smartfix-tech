// To parse this JSON data, do
//
//     final cityModel = cityModelFromJson(jsonString);

import 'dart:convert';

CityModel cityModelFromJson(String str) => CityModel.fromJson(json.decode(str));

String cityModelToJson(CityModel data) => json.encode(data.toJson());

class CityModel {
  CityModel({
    this.data,
    this.success,
    this.message,
  });

  List<CityData>? data;
  bool? success;
  String? message;

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        data:
            List<CityData>.from(json["data"].map((x) => CityData.fromJson(x))),
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
        "message": message,
      };
}

class CityData {
  CityData({
    this.id,
    this.city,
    this.state,
    this.v,
  });

  String? id;
  String? city;
  String? state;
  int? v;

  factory CityData.fromJson(Map<String, dynamic> json) => CityData(
        id: json["_id"],
        city: json["city"],
        state: json["state"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "city": city,
        "state": state,
        "__v": v,
      };
}

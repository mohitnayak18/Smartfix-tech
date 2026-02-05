// To parse this JSON data, do
//
//     final serviceDetail = serviceDetailFromJson(jsonString);

import 'dart:convert';

ServiceDetail serviceDetailFromJson(String str) =>
    ServiceDetail.fromJson(json.decode(str));

String serviceDetailToJson(ServiceDetail data) => json.encode(data.toJson());

class ServiceDetail {
  ServiceDetail({
    this.data,
    this.status,
    this.message,
  });

  ServiceDetailData? data;
  bool? status;
  String? message;

  factory ServiceDetail.fromJson(Map<String, dynamic> json) => ServiceDetail(
        data: ServiceDetailData.fromJson(json["data"]),
        status: json["status"] as bool? ?? false,
        message: json["message"] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        "data": data!.toJson(),
        "status": status,
        "message": message,
      };
}

class ServiceDetailData {
  ServiceDetailData({
    this.id,
    this.subCatgoryId,
    this.name,
    this.descriptions,
    this.note,
    this.price,
    this.discount,
    this.status,
    this.serviceImage,
    this.absoluteServicePath,
  });

  int? id;
  String? subCatgoryId;
  String? name;
  String? descriptions;
  String? note;
  String? price;
  String? discount;
  int? status;
  List<String>? serviceImage;
  List<String>? absoluteServicePath;

  factory ServiceDetailData.fromJson(Map<String, dynamic> json) => ServiceDetailData(
        id: json["id"] as int? ?? 0,
        subCatgoryId: json["subCatgoryId"] as String? ?? '',
        name: json["name"] as String? ?? '',
        descriptions: json["descriptions"] as String? ?? '',
        note: json["note"] as String? ?? '',
        price: json["price"] as String? ?? '',
        discount: json["discount"] as String? ?? '',
        status: json["status"] as int? ?? 0,
        serviceImage: List<String>.from(json["serviceImage"].map((x) => x)),
        absoluteServicePath:
            List<String>.from(json["absoluteServicePath"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subCatgoryId": subCatgoryId,
        "name": name,
        "descriptions": descriptions,
        "note": note,
        "price": price,
        "discount": discount,
        "status": status,
        "serviceImage": List<dynamic>.from(serviceImage!.map((x) => x)),
        "absoluteServicePath":
            List<dynamic>.from(absoluteServicePath!.map((x) => x)),
      };
}

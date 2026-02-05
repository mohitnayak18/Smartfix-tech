// To parse this JSON data, do
//
//     final tImeSlot = tImeSlotFromJson(jsonString);

import 'dart:convert';

TImeSlot tImeSlotFromJson(String str) => TImeSlot.fromJson(json.decode(str));

String tImeSlotToJson(TImeSlot data) => json.encode(data.toJson());

class TImeSlot {
  TImeSlot({
    this.data,
    this.status,
    this.message,
  });

  List<TImeSlotData>? data;
  bool? status;
  String? message;

  factory TImeSlot.fromJson(Map<String, dynamic> json) => TImeSlot(
        data: List<TImeSlotData>.from(json["data"].map((x) => TImeSlotData.fromJson(x))),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class TImeSlotData {
  TImeSlotData({
    this.value,
    this.text,
  });

  String? value;
  String? text;

  factory TImeSlotData.fromJson(Map<String, dynamic> json) => TImeSlotData(
        value: json["value"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "text": text,
      };
}

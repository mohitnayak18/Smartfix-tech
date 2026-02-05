// To parse this JSON data, do
//
//     final event = eventFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

Event eventFromJson(String str) => Event.fromJson(json.decode(str));

String eventToJson(Event data) => json.encode(data.toJson());

class Event {
  Event({
    this.fromTime,
    this.toTime,
    this.event,
    required this.id,
    required this.key,
  });

  int? fromTime;
  int? toTime;
  String? event;
  String id;
  GlobalKey key;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        fromTime: json["from_time"],
        toTime: json["to_time"],
        event: json["event"],
        key: json["key"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "from_time": fromTime,
        "to_time": toTime,
        "event": event,
        "key": key,
      };
}

// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  Profile({
    this.coverImageFullPath,
    this.profileImage,
    this.userId,
    this.coverImage,
    this.email,
    this.fullName,
    this.profileImageFullPath,
    this.phoneNumber,
  });

  String? coverImageFullPath;
  String? profileImage;
  String? userId;
  String? coverImage;
  String? email;
  String? fullName;
  String? profileImageFullPath;
  String? phoneNumber;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        coverImageFullPath: json["coverImageFullPath"],
        profileImage: json["profileImage"],
        userId: json["userId"],
        coverImage: json["coverImage"],
        email: json["email"],
        fullName: json["fullName"],
        profileImageFullPath: json["profileImageFullPath"],
        phoneNumber: json["phoneNumber"],
      );

  Map<String, dynamic> toJson() => {
        "coverImageFullPath": coverImageFullPath,
        "profileImage": profileImage,
        "userId": userId,
        "coverImage": coverImage,
        "email": email,
        "fullName": fullName,
        "profileImageFullPath": profileImageFullPath,
        "phoneNumber": phoneNumber,
      };
}

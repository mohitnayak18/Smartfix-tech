// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

UserProfile userProfileFromJson(String str) =>
    UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  UserProfile({
    this.userId,
    this.profileImageFullPath,
    this.phoneNumber,
    this.coverImage,
    this.profileImage,
    this.fullName,
    this.coverImageFullPath,
    this.email,
  });

  String? profileImageFullPath;
  String? phoneNumber;
  String? coverImage;
  String? profileImage;
  String? fullName;
  String? coverImageFullPath;
  String? email;
  String? userId;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        userId: json["userId"] as String? ?? '',
        profileImageFullPath: json["profileImageFullPath"] as String? ?? '',
        phoneNumber: json["phoneNumber"] as String? ?? '',
        coverImage: json["coverImage"] as String? ?? '',
        profileImage: json["profileImage"] as String? ?? '',
        fullName: json["fullName"] as String? ?? '',
        coverImageFullPath: json["coverImageFullPath"] as String? ?? '',
        email: json["email"] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        "userId": '$userId',
        "profileImageFullPath": '$profileImageFullPath',
        "phoneNumber": '$phoneNumber',
        "coverImage": '$coverImage',
        "profileImage": '$profileImage',
        "fullName": '$fullName',
        "coverImageFullPath": '$coverImageFullPath',
        "email": '$email',
      };
}

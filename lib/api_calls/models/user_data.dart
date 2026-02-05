import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
    int status;
    String message;
    String token;
    User user;

    UserData({
        required this.status,
        required this.message,
        required this.token,
        required this.user,
    });

    factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        status: json["status"]?? 0,
        message: json["message"]?? '',
        token: json["token"]?? '',
        user: User.fromJson(json["user"]?? {}),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "token": token,
        "user": user.toJson(),
    };
}

class User {
    int id;
    String name;
    String email;
    String mobile;
    DateTime createdAt;
    dynamic profile;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.mobile,
        required this.createdAt,
        required this.profile,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"]?? 0,
        name: json["name"]?? '',
        email: json["email"]?? '',
        mobile: json["mobile"]?? '',
        createdAt: DateTime.parse(json["created_at"]),
        profile: json["profile"]?? {},
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "created_at": createdAt.toIso8601String(),
        "profile": profile,
    };
}
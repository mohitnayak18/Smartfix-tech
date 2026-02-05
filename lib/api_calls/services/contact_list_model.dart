// To parse this JSON data, do
//
//     final contactList = contactListFromJson(jsonString);

import 'dart:convert';

ContactList contactListFromJson(String str) => ContactList.fromJson(json.decode(str));

String contactListToJson(ContactList data) => json.encode(data.toJson());

class ContactList {
    ContactList({
        this.contacts,
    });

    List<Contact>? contacts;

    factory ContactList.fromJson(Map<String, dynamic> json) => ContactList(
        contacts: List<Contact>.from(json["contacts"].map((x) => Contact.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "contacts": List<dynamic>.from(contacts!.map<dynamic>((x) => x.toJson())),
    };
}

class Contact {
    Contact({
        this.name,
        this.username,
        this.profilePicture,
        this.email,
        this.mobile,
        this.userType,
        this.designation,
        this.company,
        this.linkedinProfile,
    });

    String? name;
    String? username;
    String? profilePicture;
    String? email;
    String? mobile;
    String? userType;
    String? designation;
    String? company;
    String? linkedinProfile;

    factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        name: json["name"],
        username: json["username"],
        profilePicture: json["profile_picture"],
        email: json["email"],
        mobile: json["mobile"],
        userType: json["user_type"],
        designation: json["designation"],
        company: json["company"],
        linkedinProfile: json["linkedin_profile"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "username": username,
        "profile_picture": profilePicture,
        "email": email,
        "mobile": mobile,
        "user_type": userType,
        "designation": designation,
        "company": company,
        "linkedin_profile": linkedinProfile,
    };
}

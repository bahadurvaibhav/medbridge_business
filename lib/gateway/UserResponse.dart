import 'dart:convert';

import 'package:medbridge_business/gateway/StatusMsg.dart';

UserResponse userResponseFromJson(String str) =>
    UserResponse.fromJson(json.decode(str));

String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  StatusMsg response;
  User user;

  UserResponse({
    this.response,
    this.user,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        response: StatusMsg.fromJson(json["response"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "user": user.toJson(),
      };
}

class User {
  int id;
  String name;
  String email;
  int isAdmin;
  dynamic mobile;
  dynamic gender;
  dynamic address;
  dynamic country;
  dynamic rewardPercentage;

  User({
    this.id,
    this.name,
    this.email,
    this.isAdmin,
    this.mobile,
    this.gender,
    this.address,
    this.country,
    this.rewardPercentage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        isAdmin: json["isAdmin"],
        mobile: json["mobile"],
        gender: json["gender"],
        address: json["address"],
        country: json["country"],
        rewardPercentage: json["rewardPercentage"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "isAdmin": isAdmin,
        "mobile": mobile,
        "gender": gender,
        "address": address,
        "country": country,
        "rewardPercentage": rewardPercentage,
      };
}

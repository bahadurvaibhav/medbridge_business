import 'dart:convert';

FacebookLoginResponse facebookLoginResponseFromJson(String str) =>
    FacebookLoginResponse.fromJson(json.decode(str));

class FacebookLoginResponse {
  String name;
  String email;
  String id;

  FacebookLoginResponse({
    this.name,
    this.email,
    this.id,
  });

  factory FacebookLoginResponse.fromJson(Map<String, dynamic> json) =>
      FacebookLoginResponse(
        name: json["name"],
        email: json["email"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "id": id,
      };
}

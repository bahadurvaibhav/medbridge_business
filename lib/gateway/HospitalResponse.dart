import 'dart:convert';

List<HospitalResponse> hospitalResponseFromJson(String str) =>
    List<HospitalResponse>.from(
        json.decode(str).map((x) => HospitalResponse.fromJson(x)));

String hospitalResponseToJson(List<HospitalResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HospitalResponse {
  String id;
  String hospitalName;

  HospitalResponse({
    this.id,
    this.hospitalName,
  });

  factory HospitalResponse.fromJson(Map<String, dynamic> json) =>
      HospitalResponse(
        id: json["id"],
        hospitalName: json["hospital_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "hospital_name": hospitalName,
      };
}

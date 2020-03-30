import 'dart:convert';

List<PatientResponse> patientResponseFromJson(String str) =>
    List<PatientResponse>.from(
        json.decode(str).map((x) => PatientResponse.fromJson(x)));

String patientResponseToJson(List<PatientResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PatientResponse {
  String id;
  String userId;
  String patientName;
  String patientPhone;
  String patientEmail;
  String patientCountry;
  String patientProblem;
  String patientPreferredDestination;
  String patientTravelAssist;
  String patientAccommodationAssist;
  String preferredHospitalId;
  DateTime created;

  PatientResponse({
    this.id,
    this.userId,
    this.patientName,
    this.patientPhone,
    this.patientEmail,
    this.patientCountry,
    this.patientProblem,
    this.patientPreferredDestination,
    this.patientTravelAssist,
    this.patientAccommodationAssist,
    this.preferredHospitalId,
    this.created,
  });

  factory PatientResponse.fromJson(Map<String, dynamic> json) =>
      PatientResponse(
        id: json["id"],
        userId: json["userId"],
        patientName: json["patientName"],
        patientPhone: json["patientPhone"],
        patientEmail: json["patientEmail"],
        patientCountry: json["patientCountry"],
        patientProblem: json["patientProblem"],
        patientPreferredDestination: json["patientPreferredDestination"],
        patientTravelAssist: json["patientTravelAssist"],
        patientAccommodationAssist: json["patientAccommodationAssist"],
        preferredHospitalId: json["preferredHospitalId"],
        created: DateTime.parse(json["created"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "patientName": patientName,
        "patientPhone": patientPhone,
        "patientEmail": patientEmail,
        "patientCountry": patientCountry,
        "patientProblem": patientProblem,
        "patientPreferredDestination": patientPreferredDestination,
        "patientTravelAssist": patientTravelAssist,
        "patientAccommodationAssist": patientAccommodationAssist,
        "preferredHospitalId": preferredHospitalId,
        "created": created.toIso8601String(),
      };
}

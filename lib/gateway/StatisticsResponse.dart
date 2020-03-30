import 'dart:convert';

StatisticsResponse statsResponseFromJson(String str) =>
    StatisticsResponse.fromJson(json.decode(str));

String statsResponseToJson(StatisticsResponse data) =>
    json.encode(data.toJson());

class StatisticsResponse {
  String totalPatients;
  String treatmentsOngoing;
  String treatmentsCompleted;

  StatisticsResponse({
    this.totalPatients,
    this.treatmentsOngoing,
    this.treatmentsCompleted,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) =>
      StatisticsResponse(
        totalPatients: json["TOTAL_PATIENTS"].toString(),
        treatmentsOngoing: json["TREATMENTS_ONGOING"].toString(),
        treatmentsCompleted: json["TREATMENTS_COMPLETED"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "TOTAL_PATIENTS": totalPatients,
        "TREATMENTS_ONGOING": treatmentsOngoing,
        "TREATMENTS_COMPLETED": treatmentsCompleted,
      };
}

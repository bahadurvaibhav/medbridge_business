import 'dart:convert';

StatsResponse statsResponseFromJson(String str) =>
    StatsResponse.fromJson(json.decode(str));

String statsResponseToJson(StatsResponse data) => json.encode(data.toJson());

class StatsResponse {
  int totalPatients;
  int treatmentsOngoing;
  int treatmentsCompleted;

  StatsResponse({
    this.totalPatients,
    this.treatmentsOngoing,
    this.treatmentsCompleted,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) => StatsResponse(
        totalPatients: json["TOTAL_PATIENTS"],
        treatmentsOngoing: json["TREATMENTS_ONGOING"],
        treatmentsCompleted: json["TREATMENTS_COMPLETED"],
      );

  Map<String, dynamic> toJson() => {
        "TOTAL_PATIENTS": totalPatients,
        "TREATMENTS_ONGOING": treatmentsOngoing,
        "TREATMENTS_COMPLETED": treatmentsCompleted,
      };
}

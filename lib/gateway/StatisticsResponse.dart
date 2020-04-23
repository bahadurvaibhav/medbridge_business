import 'dart:convert';

StatisticsResponse statsResponseFromJson(String str) =>
    StatisticsResponse.fromJson(json.decode(str));

String statsResponseToJson(StatisticsResponse data) =>
    json.encode(data.toJson());

class StatisticsResponse {
  String totalPatients;
  String treatmentsOngoing;
  String treatmentsCompleted;
  String rewardDue;
  String rewardCollected;

  StatisticsResponse({
    this.totalPatients,
    this.treatmentsOngoing,
    this.treatmentsCompleted,
    this.rewardDue,
    this.rewardCollected,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) =>
      StatisticsResponse(
        totalPatients: json["TOTAL_PATIENTS"].toString(),
        treatmentsOngoing: json["TREATMENTS_ONGOING"].toString(),
        treatmentsCompleted: json["TREATMENTS_COMPLETED"].toString(),
        rewardDue: json["REWARD_DUE"].toString(),
        rewardCollected: json["REWARD_COLLECTED"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "TOTAL_PATIENTS": totalPatients,
        "TREATMENTS_ONGOING": treatmentsOngoing,
        "TREATMENTS_COMPLETED": treatmentsCompleted,
        "REWARD_DUE": rewardDue,
        "REWARD_COLLECTED": rewardCollected,
      };
}

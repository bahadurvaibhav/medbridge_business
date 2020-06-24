import 'dart:convert';

import 'package:medbridge_business/gateway/StatusMsg.dart';
import 'package:medbridge_business/gateway/TravelStatusResponse.dart';

TravelStatusConfirmedResponse travelStatusConfirmedResponseFromJson(
        String str) =>
    TravelStatusConfirmedResponse.fromJson(json.decode(str));

String travelStatusConfirmedResponseToJson(
        TravelStatusConfirmedResponse data) =>
    json.encode(data.toJson());

class TravelStatusConfirmedResponse {
  TravelStatusConfirmedResponse({
    this.response,
    this.travelStatus,
  });

  StatusMsg response;
  TravelStatus travelStatus;

  factory TravelStatusConfirmedResponse.fromJson(Map<String, dynamic> json) =>
      TravelStatusConfirmedResponse(
        response: StatusMsg.fromJson(json["response"]),
        travelStatus: TravelStatus.fromJson(json["travelStatus"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "travelStatus": travelStatus.toJson(),
      };
}

class TravelStatus {
  TravelStatus({
    this.id,
    this.patientId,
    this.pickUpRequested,
    this.flightTicketDocuments,
    this.created,
  });

  String id;
  String patientId;
  String pickUpRequested;
  List<Document> flightTicketDocuments;
  DateTime created;

  factory TravelStatus.fromJson(Map<String, dynamic> json) => TravelStatus(
        id: json["id"],
        patientId: json["patientId"],
        pickUpRequested: json["pickUpRequested"],
        flightTicketDocuments: List<Document>.from(
            json["flightTicketDocuments"].map((x) => Document.fromJson(x))),
        created: DateTime.parse(json["created"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patientId": patientId,
        "pickUpRequested": pickUpRequested,
        "flightTicketDocuments":
            List<dynamic>.from(flightTicketDocuments.map((x) => x.toJson())),
        "created": created.toIso8601String(),
      };
}

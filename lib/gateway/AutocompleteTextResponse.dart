import 'dart:convert';

import 'package:medbridge_business/gateway/IdNameResponse.dart';

AutocompleteTextResponse autocompleteTextResponseFromJson(String str) =>
    AutocompleteTextResponse.fromJson(json.decode(str));

String autocompleteTextResponseToJson(AutocompleteTextResponse data) =>
    json.encode(data.toJson());

class AutocompleteTextResponse {
  List<IdNameResponse> hospitals;
  List<IdNameResponse> doctors;
  List<IdNameResponse> treatments;
  List<IdNameResponse> destinations;

  AutocompleteTextResponse({
    this.hospitals,
    this.doctors,
    this.treatments,
    this.destinations,
  });

  factory AutocompleteTextResponse.fromJson(Map<String, dynamic> json) =>
      AutocompleteTextResponse(
        hospitals: List<IdNameResponse>.from(
            json["hospitals"].map((x) => IdNameResponse.fromJson(x))),
        doctors: List<IdNameResponse>.from(
            json["doctors"].map((x) => IdNameResponse.fromJson(x))),
        treatments: List<IdNameResponse>.from(
            json["treatments"].map((x) => IdNameResponse.fromJson(x))),
        destinations: List<IdNameResponse>.from(
            json["destinations"].map((x) => IdNameResponse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "hospitals": List<dynamic>.from(hospitals.map((x) => x.toJson())),
        "doctors": List<dynamic>.from(doctors.map((x) => x.toJson())),
        "treatments": List<dynamic>.from(treatments.map((x) => x.toJson())),
        "destinations": List<dynamic>.from(destinations.map((x) => x.toJson())),
      };
}

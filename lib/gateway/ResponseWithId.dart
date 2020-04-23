import 'dart:convert';

import 'package:medbridge_business/gateway/StatusMsg.dart';

ResponseWithId responseWithIdFromJson(String str) =>
    ResponseWithId.fromJson(json.decode(str));

String responseWithIdToJson(ResponseWithId data) => json.encode(data.toJson());

class ResponseWithId {
  StatusMsg response;
  int referenceId;

  ResponseWithId({
    this.response,
    this.referenceId,
  });

  factory ResponseWithId.fromJson(Map<String, dynamic> json) => ResponseWithId(
        response: StatusMsg.fromJson(json["response"]),
        referenceId: json["referenceId"],
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "referenceId": referenceId,
      };
}

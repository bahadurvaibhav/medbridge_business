import 'dart:convert';

StatusMsg responseFromJson(String str) => StatusMsg.fromJson(json.decode(str));

String responseToJson(StatusMsg data) => json.encode(data.toJson());

class StatusMsg {
  int status;
  String msg;

  StatusMsg({
    this.status,
    this.msg,
  });

  factory StatusMsg.fromJson(Map<String, dynamic> json) => StatusMsg(
        status: json["status"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "msg": msg,
      };
}

class Response {
  int status;
  String msg;

  Response({
    this.status,
    this.msg,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        status: json["status"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "msg": msg,
      };
}

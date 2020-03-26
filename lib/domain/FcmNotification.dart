class FcmNotification {
  String title;
  String body;

  FcmNotification(this.title, this.body);
}

FcmNotification getNotification(Map<String, dynamic> message) {
  var data = message['notification'];
  var title = data['title'];
  var body = data['body'];
  return new FcmNotification(title, body);
}

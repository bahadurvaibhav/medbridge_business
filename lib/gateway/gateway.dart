import 'package:http/http.dart' as http;

Future<dynamic> post(String url, var body) async {
  return http.post(
    url,
    body: body,
    headers: {"Accept": "application/json"},
  );
}

import 'package:http/http.dart' as http;

Future<dynamic> post(String url, var body) async {
  print('API: ' + url);
  return http.post(
    url,
    body: body,
    headers: {"Accept": "application/json"},
  );
}

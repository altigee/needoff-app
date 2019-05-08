import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:needoff/api/config.dart' as config;

Future post(String url, {Map<String, String> body, Map<String, String> headers}) {
  print('[LOG][REQUEST]: $url');
  return http.post('${config.apiUrl}$url', body: json.encode(body), headers: headers);
}

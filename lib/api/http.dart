import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:needoff/config.dart' show appConfig;
import 'package:needoff/api/storage.dart' as storage;


Future post(String path, {Map<String, String> body, Map<String, String> headers}) async {
  print('[LOG][POST REQUEST]: $path');
  var token = await storage.getToken();
  String baseUrl = appConfig.get('apiUrl');
  return http.post('$baseUrl$path', body: json.encode(body), headers: headers);
}

Future get(String path, {Map<String, String> headers}) async {
  print('[LOG][GET REQUEST]: $path');
  var token = await storage.getToken();
  String baseUrl = appConfig.get('apiUrl');
  return http.get('$baseUrl$path', headers: headers);
}

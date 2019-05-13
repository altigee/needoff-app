import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:needoff/api/config.dart' as config;
import 'package:needoff/api/storage.dart' as storage;


Future post(String path, {Map<String, String> body, Map<String, String> headers}) async {
  print('[LOG][POST REQUEST]: $path');
  var token = await storage.getToken();
  return http.post('${config.apiUrl}$path', body: json.encode(body), headers: headers);
}

Future get(String path, {Map<String, String> headers}) async {
  print('[LOG][GET REQUEST]: $path');
  var token = await storage.getToken();
  return http.get('${config.apiUrl}$path', headers: headers);
}

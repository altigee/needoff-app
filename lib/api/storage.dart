import 'package:shared_preferences/shared_preferences.dart';

const _tokenKey = 'jwt_access';
Future get _ref {
  return SharedPreferences.getInstance();
}
Future getToken() async {
  return (await _ref).getString(_tokenKey);
}

Future setToken(token) async {
  return (await _ref).setString(_tokenKey, token);
}

Future removeToken() async {
  return (await _ref).remove(_tokenKey);
}
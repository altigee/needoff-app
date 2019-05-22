import 'package:shared_preferences/shared_preferences.dart';

const _tokenKey = 'jwt_access';
const _wsKey = 'workspace_id';
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

Future getWorkspace() async {
  return (await _ref).getInt(_wsKey);
}

Future setWorkspace(int wsId) async {
  return (await _ref).setInt(_wsKey, wsId);
}
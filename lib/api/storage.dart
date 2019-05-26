import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageChangeNotifier extends ChangeNotifier {
  notify() {
    notifyListeners();
  }
}

const _tokenKey = 'jwt_access';
const _wsKey = 'workspace_id';
final _changes = StorageChangeNotifier();

ChangeNotifier get changes => _changes;

Future get _ref {
  return SharedPreferences.getInstance();
}
Future getToken() async {
  return (await _ref).getString(_tokenKey);
}

Future setToken(token) async {
  bool res = await (await _ref).setString(_tokenKey, token);
  if (res) _changes.notify();
  return res;
}

Future removeToken() async {
  bool res = await (await _ref).remove(_tokenKey);
  if (res) _changes.notify();
  return res;
}

Future getWorkspace() async {
  return (await _ref).getInt(_wsKey);
}

Future setWorkspace(int wsId) async {
  bool res = await  await (await _ref).setInt(_wsKey, wsId);
  if (res) _changes.notify();
  return res;
}

Future removeWorkspace() async {
  bool res = await (await _ref).remove(_wsKey);
  if (res) _changes.notify();
  return res;
}
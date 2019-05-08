import 'dart:convert';

class _Config {
  var _cfgObj;
  _Config();
  get env {
    return _cfgObj['env'];
  }
  void setJson(String cfgJson) {
    _cfgObj = json.decode(cfgJson);
  }
}
final _Config cfg = _Config();

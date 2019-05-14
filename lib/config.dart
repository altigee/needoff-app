class _Config {
  var _data = {};
  _Config();
  void setData(Map data) {
    _data = data;
  }
  Map get data {
    return _data;
  }

  get(String field) {
    return _data[field];
  }
}
final _Config appConfig = _Config();

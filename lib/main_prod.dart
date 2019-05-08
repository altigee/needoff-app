import 'package:needoff/env/prod.dart' as env;
import 'package:needoff/config.dart' show cfg;
import 'main.dart' as mainEntry;

void main() {
  cfg.setJson(env.json);
  print(env.json);
  mainEntry.main();
}
import 'package:needoff/env/prod.dart' show config;
import 'package:needoff/config.dart' show appConfig;
import 'main.dart' as mainEntry;

void main() {
  appConfig.setData(config);
  print(appConfig.get('env'));
  mainEntry.main();
}
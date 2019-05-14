import 'package:needoff/env/dev.dart' show config;
import 'package:needoff/config.dart' show appConfig;
import 'main.dart' as mainEntry;

void main() {
  appConfig.setData(config);
  print(appConfig.data);
  print(appConfig.get('env'));
  mainEntry.main();
}
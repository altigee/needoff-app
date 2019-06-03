import 'package:intl/intl.dart' as intl;

intl.DateFormat _df = intl.DateFormat.yMMMd();
formatDate(DateTime date) {
  return _df.format(date);
}

parseFormatted(String formatted) {
  return _df.parse(formatted);
}

formatForGQL(DateTime date) {
  return intl.DateFormat('y-MM-dd').format(date);
}
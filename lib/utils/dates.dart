import 'package:intl/intl.dart' as intl;

formatDate(DateTime date) {
  return intl.DateFormat.yMMMd().format(date);
}
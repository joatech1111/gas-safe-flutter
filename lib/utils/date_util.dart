import 'package:intl/intl.dart';

class DateUtil {
  static const String formatYyyyMmDd = 'yyyy-MM-dd';
  static const String formatYyyymmdd = 'yyyyMMdd';
  static const String formatMmDd = 'MM-dd';
  static const String formatYyMmDd = 'yy-MM-dd';

  static String today({String format = formatYyyymmdd}) {
    return DateFormat(format).format(DateTime.now());
  }

  static String beforeDays(int days, {String format = formatYyyymmdd}) {
    return DateFormat(format).format(DateTime.now().subtract(Duration(days: days)));
  }

  static String afterDays(int days, {String format = formatYyyymmdd}) {
    return DateFormat(format).format(DateTime.now().add(Duration(days: days)));
  }

  static String convertFormat(String date, String fromFormat, String toFormat) {
    try {
      final dt = DateFormat(fromFormat).parse(date);
      return DateFormat(toFormat).format(dt);
    } catch (_) {
      return date;
    }
  }

  static String toDisplay(String? yyyymmdd) {
    if (yyyymmdd == null || yyyymmdd.length < 8) return yyyymmdd ?? '';
    return '${yyyymmdd.substring(0, 4)}-${yyyymmdd.substring(4, 6)}-${yyyymmdd.substring(6, 8)}';
  }

  static String fromDisplay(String? displayDate) {
    if (displayDate == null) return '';
    return displayDate.replaceAll('-', '');
  }

  static int dayDiff(String date1, String date2) {
    try {
      final d1 = DateFormat(formatYyyymmdd).parse(date1);
      final d2 = DateFormat(formatYyyymmdd).parse(date2);
      return d2.difference(d1).inDays;
    } catch (_) {
      return 0;
    }
  }
}

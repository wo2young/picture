// lib/utils/formatters.dart
import 'package:intl/intl.dart';

// 날짜, 텍스트 포맷터 모음
class Formatters {
  static final DateFormat _date = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) {
    return _date.format(date);
  }
}

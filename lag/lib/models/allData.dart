import 'package:intl/intl.dart';

abstract class AllData {
  final DateTime day;

  AllData({required this.day});

  // Method to format the date
  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(day);
  }

}

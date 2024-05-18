
import 'package:intl/intl.dart';

// Heart rate at rest data
class HeartRateData{
  final DateTime day;
  final double value;

  HeartRateData({required this.day, required this.value});

  HeartRateData.empty(String day, Map<String, dynamic> json) :
    day = DateFormat('yyyy-MM-dd').parse(json["date"]),
    value = 0;

  HeartRateData.fromJson(String day, Map<String, dynamic> json) :
      day = DateFormat('yyyy-MM-dd').parse(json["date"]),
      value = double.parse((json["data"]["value"]).toStringAsFixed(1));

  @override
  String toString() {
    return 'HeartRateData(day: $day, value: $value)';
  }//toString
}//SleepData

import 'package:intl/intl.dart';
import 'dart:math' as math;

// model to store data from server in a dedicated object type
class SleepData{
  final DateTime day;
  final double value;
  SleepData({required this.day, required this.value});

  SleepData.empty(String day, Map<String, dynamic> json) :
      day = DateFormat('yyyy-MM-dd').parse(json["date"]),
      value = 0;

  SleepData.fromJson(String day, Map<String, dynamic> json) :
      day = DateFormat('yyyy-MM-dd').parse(json["date"]),
      value = double.parse((
          json["data"] is List ? json["data"][0]["duration"] * math.pow(10, -3)/3600 : json["data"]["duration"] * math.pow(10, -3)/3600
        ).toStringAsFixed(1));

  @override
  String toString() {
    return 'SleepData(day: $day, value: $value)';
  }//toString
}//SleepData
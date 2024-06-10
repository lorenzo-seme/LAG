import 'package:lag/models/allData.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// model to store data from server in a dedicated object type

class ExerciseData extends AllData {
  final int avgHR; // average heart rate
  final double duration;

  ExerciseData({
    required DateTime day,
    required this.avgHR,
    required this.duration,
  }) : super(day: day);

  ExerciseData.empty(String day, Map<String, dynamic> json)
      : avgHR = 0,
        duration = 0,
        super(day: DateFormat('yyyy-MM-dd').parse(json["date"]));

  factory ExerciseData.fromJson(String date, Map<String, dynamic> json) {
    return ExerciseData(
      day: DateFormat('yyyy-MM-dd').parse(date),
      avgHR: json["data"][0]["averageHeartRate"],
      duration: _obtainTotalDuration(json),
    );
  }

  static double _obtainTotalDuration(Map<String, dynamic> json) {
    double totalDuration = 0.0;
    if (json["data"] is List) {
      totalDuration = (json["data"] as List).fold(0.0, (sum, item) {
        return sum + item["duration"] * math.pow(10, -3) / 60;
      });
    } else {
      totalDuration = double.parse(
          (json["data"][0]["duration"] * math.pow(10, -3) / 60)
              .toStringAsFixed(1));
    }
    return totalDuration;
  }

  @override
  String toString() {
    return 'day: $day, avgHR: $avgHR, duration: $duration';
  }
}


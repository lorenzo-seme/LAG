import 'package:lag/models/allData.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// model to store data from server in a dedicated object type
class ExerciseData extends AllData {
  //final DateTime day;
  final int avgHR; // average heart rate
  final double duration;

  //ExerciseData({required this.day, required this.avgHR, required this.duration});
  ExerciseData({required DateTime day, required this.avgHR, required this.duration}): super(day: day);

  ExerciseData.empty(String day, Map<String, dynamic> json) :
  avgHR = 0,
  duration = 0, super(day : DateFormat('yyyy-MM-dd').parse(json["date"]));

  factory ExerciseData.fromJson(Map<String, dynamic> json, data) {
    double totalDuration = json["data"].fold(0.0, (sum, item) => sum + item["duration"] * math.pow(10, -3) / 60);
    return ExerciseData(
      day: DateFormat('yyyy-MM-dd').parse(json["date"]),
      avgHR: json["data"][0]["averageHeartRate"],
      duration: totalDuration,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "day": getFormattedDate(),
      "avg": avgHR,
      "duration": duration,
    };
  }//toString
}//SleepData
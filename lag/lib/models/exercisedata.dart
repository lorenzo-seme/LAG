
import 'package:intl/intl.dart';
import 'dart:math' as math;

// model to store data from server in a dedicated object type
class ExerciseData{
  final DateTime day;
  final int avgHR; // average heart rate
  final double duration;

  ExerciseData({required this.day, required this.avgHR, required this.duration});

  ExerciseData.empty(String day, Map<String, dynamic> json) :
  day = DateFormat('yyyy-MM-dd').parse(json["date"]),
  avgHR = 0,
  duration = 0;

  ExerciseData.fromJson(String day, Map<String, dynamic> json) :
      day = DateFormat('yyyy-MM-dd').parse(json["date"]),
      // per ora ritorno soltanto i dati del primo esercizio della giornata. Magari dovremmo fare somma di tutte le attività
      // della giornata
      avgHR = json["data"][0]["averageHeartRate"],
      duration = _calculateTotalDuration(json);
      
  static double _calculateTotalDuration(Map<String, dynamic> json) {
    double totalDuration = 0;
    int dataLength = json["data"].length;
    for (int i = 0; i < dataLength; i++) {
      totalDuration += double.parse((json["data"][i]["duration"] * math.pow(10, -3)/60));
    }
    return totalDuration;
  }

  @override
  String toString() {
    return 'ExerciseData(day: $day, averageHeartRate: $avgHR, duration: $duration)';
  }//toString
}//SleepData

import 'package:intl/intl.dart';
import 'dart:math' as math;

// model to store data from server in a dedicated object type
class ExerciseData{
  final DateTime day;
  final int avgHR; // average heart rate
  final double duration;

  ExerciseData({required this.day, required this.avgHR, required this.duration});

  ExerciseData.fromJson(String day, Map<String, dynamic> json) :
      day = DateFormat('yyyy-MM-dd').parse(json["date"]),
      // per ora ritorno soltanto i dati del primo esercizio della giornata. Magari dovremmo fare somma di tutte le attività
      // della giornata
      avgHR = json["data"][0]["averageHeartRate"],
      duration = double.parse((json["data"][0]["duration"] * math.pow(10, -3)/60).toStringAsFixed(1));

  @override
  String toString() {
    return 'ExerciseData(day: $day, averageHeartRate: $avgHR, duration: $duration)';
  }//toString
}//SleepData
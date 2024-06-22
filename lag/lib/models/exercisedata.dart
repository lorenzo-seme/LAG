import 'package:lag/models/allData.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math; 

// model to store data from server in a dedicated object type

class ExerciseData extends AllData {
  final int avgHR; // average heart rate
  final double duration; // unit of measurement: ms
  final double distance;
  final Map<String, List<double>>
      activities; // {activityName: [duration, distance]}

  ExerciseData(
      {required DateTime day,
      required this.avgHR,
      required this.duration,
      required this.distance,
      required this.activities})
      : super(day: day);

  ExerciseData.empty(String day, Map<String, dynamic> json)
      : avgHR = 0,
        duration = 0,
        distance = 0,
        activities = {
          "Corsa": [0, 0],
          "Bici": [0, 0],
          "Camminata": [0, 0],
        },
        super(day: DateFormat('yyyy-MM-dd').parse(json["date"]));

  
  factory ExerciseData.fromJson(String date, Map<String, dynamic> json) {
    return ExerciseData(
        day: DateFormat('yyyy-MM-dd').parse(date),
        avgHR: json["data"][0]["averageHeartRate"],
        duration: _obtainTotalDuration(json),
        distance: _obtainTotalDistance(json),
        activities: _obtainActivities(json));
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

  static double _obtainTotalDistance(Map<String, dynamic> json) {
    double totalDistance = 0.0;

    if (json["data"] is List) {
      totalDistance = (json["data"] as List).fold(0.0, (sum, item) {
        final distance = item["distance"];
        return sum + (distance ?? 0.0);
      });
    } else {
      final distance = json["data"][0]["distance"];
      totalDistance = double.parse((distance ?? 0.0).toStringAsFixed(1));
    }

    return totalDistance;
  }

  static Map<String, List<double>> _obtainActivities(Map<String, dynamic> json) {
    Map<String, List<double>> allActivities = {
      "Corsa": [0, 0],
      "Bici": [0, 0],
      "Camminata": [0, 0]
    };

    /*
    if (json["data"] is List) {
    for (var item in json["data"]) {
      if (item.containsKey("data")) {
        for (var subItem in item["data"]) {
          if (subItem.containsKey("activityName")) {
            String activityName = subItem["activityName"];
            if (allActivities.containsKey(activityName)) {
              if (subItem.containsKey("duration")) {
                allActivities[activityName]?[0] += subItem["duration"];
              }
              if (subItem.containsKey("distance")) {
                allActivities[activityName]?[1] += subItem["distance"];
              }
            }
          }
        }
      }
    }
  }
  */

    
    if (json["data"] is List) {
      for (var act in ["Corsa", "Bici", "Camminata"]) {
        for (var item in json["data"]) {
          if (item.containsKey("activityName")) {
            if (act == item["activityName"]) {
              if (item.containsKey("duration")) {
                allActivities[act]?[0] += item["duration"];
              }
              if (item.containsKey("distance")) {
                allActivities[act]?[1] += item["distance"];
              }
            }
          }
        }
      }
    }
    return allActivities;
  }

  @override
  String toString() {
    return 'day: $day, avgHR: $avgHR, duration: $duration, activities: $activities';
  }
}
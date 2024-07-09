import 'package:lag/models/allData.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math; 

// model to store data from server in a dedicated object type

class ExerciseData extends AllData {
  final int avgHR; // average heart rate
  final double duration; // unit of measurement: ms
  final double distance;
  final Map<String, List<double>> activities; // {activityName: [duration, distance]}
  final List<String> actNames;

  ExerciseData(
      {required DateTime day,
      required this.avgHR,
      required this.duration,
      required this.distance,
      required this.activities, 
      required this.actNames})
      : super(day: day);

  ExerciseData.empty(String day, Map<String, dynamic> json)
      : avgHR = 0,
        duration = 0,
        distance = 0,
        activities = {},
        actNames = [],
        super(day: DateFormat('yyyy-MM-dd').parse(json["date"]));

  
  factory ExerciseData.fromJson(String date, Map<String, dynamic> json) {
    return ExerciseData(
        day: DateFormat('yyyy-MM-dd').parse(date),
        avgHR: _obtainAvgHR(json), 
        duration: _obtainTotalDuration(json),
        distance: _obtainTotalDistance(json),
        activities: _obtainActivities(json),
        actNames: _obtainActNames(json));
  }

  static int _obtainAvgHR(Map<String, dynamic> json) {
  int totalHR = 0;
  int count = 0;

  if (json["data"] is List) {
    List<dynamic> dataList = json["data"] as List;
    if (dataList.isNotEmpty) {
      totalHR = dataList.fold(0, (sum, item) {
        return sum + (item["averageHeartRate"] as int? ?? 0);
      });
      count = dataList.length;
    }
  } else if (json["data"] is Map && json["data"].containsKey("averageHeartRate")) {
    totalHR = json["data"]["averageHeartRate"] as int;
    count = 1;
  }
  if (count == 0) {
    return 0;
  }
  return (totalHR / count).round();
}

  static List<String> _obtainActNames(Map<String, dynamic> json) {
    List<String> actNames = [];
    if (json["data"] is List && json["data"].isNotEmpty) {
      for (var item in json["data"]) {
          if (item.containsKey("activityName") && !actNames.contains(item["activityName"])) {
            actNames.add(item["activityName"]);
          }
    }
  } 
  return actNames;
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
    List<String> actNames = _obtainActNames(json);
    Map<String, List<double>> allActivities = {};
    if (actNames.isNotEmpty) {
      for (String act in actNames) {
        allActivities[act] = [0, 0];
      }
    } else {
      allActivities = {'Null' : [0, 0]};
    }

    if (json["data"] is List) {
      for (var act in actNames) {
        for (var item in json["data"]) {
          if (item.containsKey("activityName")) {
            if (act == item["activityName"]) {
              if (item.containsKey("duration")) {
                double d = item["duration"]* math.pow(10, -3) / 60;
                allActivities[act]?[0] += double.parse(d.toStringAsFixed(2));
              }
              if (item.containsKey("distance")) {
                double d = item["distance"];
                allActivities[act]?[1] += double.parse(d.toStringAsFixed(2));
              } else if (item.containsKey("steps")) {
                double s = item["steps"]*0.762/1000;  // converte il numero di step in km
                allActivities[act]?[1] += double.parse(s.toStringAsFixed(2));
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

import 'package:intl/intl.dart';
import 'dart:math' as math;

// model to store data from server in a dedicated object type
class SleepData{
  final DateTime day;
  final duration;
  final minutesAsleep;
  final efficiency;
  final minutesToFallAsleep;
  final levels;
  SleepData({required this.day, required this.duration, required this.minutesAsleep, required this.efficiency,
    required this.minutesToFallAsleep, required this.levels});

  SleepData.empty(String day, Map<String, dynamic> json) :
      day = DateFormat('yyyy-MM-dd').parse(json["date"]),
      duration = null,
      minutesAsleep = null,
      efficiency = null,
      minutesToFallAsleep = null,
      levels = null;

  SleepData.fromJson(String day, Map<String, dynamic> json) :
      day = DateFormat('yyyy-MM-dd').parse(json["date"]),
      duration = double.parse((
          json["data"] is List ? json["data"][0]["duration"] * math.pow(10, -3)/3600 : json["data"]["duration"] * math.pow(10, -3)/3600
        ).toStringAsFixed(1)),
      minutesAsleep = double.parse((
          json["data"] is List ? json["data"][0]["minutesAsleep"] : json["data"]["minutesAsleep"]
          ).toStringAsFixed(1)),
      efficiency = double.parse((
          json["data"] is List ? json["data"][0]["efficiency"] : json["data"]["efficiency"]
          ).toStringAsFixed(1)),      
      minutesToFallAsleep = double.parse((
          json["data"] is List ? json["data"][0]["minutesToFallAsleep"] : json["data"]["minutesToFallAsleep"]
          ).toStringAsFixed(1)),
      levels = (json["data"] is List ? {"deep": double.parse((json["data"][0]["levels"]["summary"]["deep"]["minutes"]).toStringAsFixed(1)),
                                                            "wake": double.parse((json["data"][0]["levels"]["summary"]["wake"]["minutes"]).toStringAsFixed(1)),
                                                            "light": double.parse((json["data"][0]["levels"]["summary"]["light"]["minutes"]).toStringAsFixed(1)),
                                                            "rem": double.parse((json["data"][0]["levels"]["summary"]["rem"]["minutes"]).toStringAsFixed(1)),
                                                            } : {
                                                            "deep": double.parse((json["data"]["levels"]["summary"]["deep"]["minutes"]).toStringAsFixed(1)),
                                                            "wake": double.parse((json["data"]["levels"]["summary"]["wake"]["minutes"]).toStringAsFixed(1)),
                                                            "light": double.parse((json["data"]["levels"]["summary"]["light"]["minutes"]).toStringAsFixed(1)),
                                                            "rem": double.parse((json["data"]["levels"]["summary"]["rem"]["minutes"]).toStringAsFixed(1))});        
  
  // nota che in alcuni (rari) giorni, il contenuto di json["data"] è una lista di un solo elemento (problema del server probabilmente)
  // gestiamo questa possibilità con l'operatore ternario

  @override
  String toString() {
    return 'SleepData(day: $day, duration: $duration, minutesAsleep: $minutesAsleep, minutesToFallAsleep: $minutesToFallAsleep,efficiency: $efficiency)';
  }//toString
}//SleepData
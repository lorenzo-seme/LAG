
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:lag/models/allData.dart';


// model to store data from server in a dedicated object type
class SleepData extends AllData{
  //final DateTime day;
  final duration;
  final minutesAsleep;
  final efficiency;
  final minutesToFallAsleep;
  final levels;

  SleepData({required DateTime day, required this.duration, required this.minutesAsleep, required this.efficiency,
    required this.minutesToFallAsleep, required this.levels}) : super(day: day);

  SleepData.empty(String day, Map<String, dynamic> json) :
      duration = null,
      minutesAsleep = null,
      efficiency = null,
      minutesToFallAsleep = null,
      levels = null,
      super(day : DateFormat('yyyy-MM-dd').parse(json["date"]));

  
  SleepData.fromJson(String day, Map<String, dynamic> json)
      : duration = double.parse(((json["data"] is List ? json["data"][0]["duration"] : json["data"]["duration"]) * math.pow(10, -3) / 3600).toStringAsFixed(1)),
        minutesAsleep = double.parse((json["data"] is List ? json["data"][0]["minutesAsleep"] : json["data"]["minutesAsleep"]).toStringAsFixed(1)),
        efficiency = double.parse((json["data"] is List ? json["data"][0]["efficiency"] : json["data"]["efficiency"]).toStringAsFixed(1)),
        minutesToFallAsleep = double.parse((json["data"] is List ? json["data"][0]["minutesToFallAsleep"] : json["data"]["minutesToFallAsleep"]).toStringAsFixed(1)),
        levels = {
          "deep": double.parse((json["data"] is List ? json["data"][0]["levels"]["summary"]["deep"]["minutes"] : json["data"]["levels"]["summary"]["deep"]["minutes"]).toStringAsFixed(1)),
          "wake": double.parse((json["data"] is List ? json["data"][0]["levels"]["summary"]["wake"]["minutes"]: json["data"]["levels"]["summary"]["wake"]["minutes"]).toStringAsFixed(1)),
          "light": double.parse((json["data"] is List ? json["data"][0]["levels"]["summary"]["light"]["minutes"] : json["data"]["levels"]["summary"]["light"]["minutes"]).toStringAsFixed(1)),
          "rem": double.parse((json["data"] is List ? json["data"][0]["levels"]["summary"]["rem"]["minutes"] : json["data"]["levels"]["summary"]["rem"]["minutes"]).toStringAsFixed(1)),
        },
        super(day: DateFormat('yyyy-MM-dd').parse(json["date"]));       
  
  // nota che in alcuni (rari) giorni, il contenuto di json["data"] è una lista di un solo elemento (problema del server probabilmente)
  // gestiamo questa possibilità con l'operatore ternario

  @override
  String toString() {
    return 'day: $day, duration: $duration, minutesAsleep: $minutesAsleep, efficiency: $efficiency, minutesToFallAsleep: $minutesToFallAsleep, levels: $levels';
  }//toString
}//SleepData
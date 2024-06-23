
import 'package:intl/intl.dart';
import 'package:lag/models/allData.dart';

// Heart rate at rest data
class HeartRateData extends AllData{
  //final DateTime day;
  final value;
 
  HeartRateData({required super.day, required this.value});

  HeartRateData.empty(String day, Map<String, dynamic> json)
      : value = null,
        super(day: DateFormat('yyyy-MM-dd').parse(json["date"]));

  HeartRateData.fromJson(String day, Map<String, dynamic> json)
      : value = double.parse(json["data"]["value"].toStringAsFixed(1)),
        super(day: DateFormat('yyyy-MM-dd').parse(json["date"]));

  @override
  String toString() {
    return 'day: $day, value: $value';
    }
}
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/allData.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/heartratedata.dart';
import 'package:lag/models/sleepdata.dart';

class CustomPlot extends StatelessWidget {
  const CustomPlot({
    Key? key,
    required this.data}) : super(key: key);

  final List<AllData> data;

  @override
  Widget build(BuildContext context) {
      List<Map<String, dynamic>> chartData = _parseData(data);
      return Chart(
        rebuild: true,
        data: chartData,
        variables: {
          'date': Variable(
            accessor: (Map map) => map['date'] as String,
            scale: OrdinalScale(tickCount: 5),
          ),
          'points': Variable(
            accessor: (Map map) => map['points'] as num,
          ),
          'type': Variable(
            accessor: (Map map) => map['type'] as String,
          ),
        },
        marks: <Mark<Shape>>[
          LineMark(
            position: Varset('date') * Varset('points'),
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            size: SizeEncode(value: 2),
            color: ColorEncode(
              values: [const Color(0xFF326F5E), const Color(0xFF89453C)],
              variable: 'type',
            ),
          ),
          AreaMark(
            gradient: GradientEncode(
              value: LinearGradient(
                begin: const Alignment(0, 0),
                end: const Alignment(0, 1),
                colors: [
                  const Color(0xFF326F5E).withOpacity(0.6),
                  const Color(0xFFFFFFFF).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
        selections: {'tap': PointSelection(dim: Dim.x)},
      );
    }
  }

List<Map<String, dynamic>> _parseData(List<AllData> data) {
  return data.map((e) {
    String type;
    double points;
    if (e is SleepData) {
      type = 'sleep';
      points = (e.duration == null) ? 0 : e.duration!;
    } else if (e is ExerciseData) {
      type = 'exercise';
      points = e.duration;
    } else if (e is HeartRateData) {
      type = 'heart_rate';
      points = e.value;
    } else {
      // Handle other types of data if needed
      type = 'unknown';
      points = 0;
    }
    return {
      'date': DateFormat('EEEE').format(e.day),
      'points': points,
      'type': type,
    };
  }).toList();
}



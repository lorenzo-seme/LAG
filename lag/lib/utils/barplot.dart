import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lag/algorithms/sleep_score.dart';

class BarChartSample7 extends StatefulWidget {
  const BarChartSample7({super.key, required this.yValues, required this.ageFlag});
  
  final List<double> yValues;
  final List<double> ageFlag;

  @override
  State<BarChartSample7> createState() => _BarChartSample7State();
}

class _BarChartSample7State extends State<BarChartSample7> {
  final List<String> weekDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

  BarChartGroupData generateBarGroup(
    int x,
    Color color,
    double value,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 10,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxDataValue = widget.yValues.isNotEmpty ? widget.yValues.reduce((a, b) => a > b ? a : b) : 0;
    double maxY = maxDataValue != 0 ? maxDataValue * 1.2 + 1 : 10;
    String ageGroup = determineAgeGroup(widget.ageFlag[0].toInt());
    Map<String, List<double>> sleepScoreTable = {
      // legend: minIdeal, maxIdeal, minAcceptable, maxAcceptable
      "School-age": [9, 11, 7, 12],
      "Teen": [8, 10, 7, 11],
      "Young Adult": [7, 9, 6, 11],
      "Adult" : [7, 9, 6, 10],
      "Older Adult" :[7, 8, 5, 9]
    };

    return Padding(
      padding: const EdgeInsets.all(15),
      child: AspectRatio(
        aspectRatio: 1.4,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            borderData: FlBorderData(
              show: true,
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                drawBelowEverything: true,
                
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.black, fontSize: 10)
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(weekDays[index],
                        style: const TextStyle(color: Colors.black, fontSize: 11),
                      )
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                if (value == (sleepScoreTable[ageGroup]!)[0] || value == (sleepScoreTable[ageGroup]!)[1]) {
                  return FlLine(
                    color: Colors.black.withOpacity(0.4),
                    strokeWidth: 2, 
                  );
                } else {
                  return FlLine(
                    color: Colors.black.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                }
              },
            ),
            barGroups: widget.yValues.asMap().entries.map((e) {
              final index = e.key;
              final data = e.value;
              return generateBarGroup(
                index,
                const Color.fromARGB(202, 97, 20, 169),
                data
              );
            }).toList(),
            maxY: (maxY.toInt()).toDouble(),
            
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.transparent,
                tooltipMargin: 0,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  int hours = rod.toY.toInt();
                  int minutes = ((rod.toY - hours) * 60).toInt();
                  return BarTooltipItem(
                    '$hours hours and \n$minutes minutes',
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 10,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 227, 211, 244),
                          blurRadius: 20,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
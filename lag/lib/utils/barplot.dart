import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lag/algorithms/sleep_score.dart';

class BarChartSample7 extends StatefulWidget {
  const BarChartSample7({super.key, required this.yValues, required this.age, required this.minToFall, required this.pieCharts, required this.legend});
  
  final List<double> yValues; // hours slept per night
  final int age; 
  final List<double> minToFall; // minutes to fall asleep per night
  final List<PieChart?> pieCharts; // pieCharts with sleep phases distribution per night
  final List<String?> legend; // percentages of sleep phases

  @override
  State<BarChartSample7> createState() => _BarChartSample7State();
}

class _BarChartSample7State extends State<BarChartSample7> {
  final List<String> weekDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]; // to be used in the bottom titles

  BarChartGroupData generateBarGroup(int x, Color color, double value) {
    return BarChartGroupData(
      x: x, // indexes of the bars (from 0 to 6)
      barRods: [
        BarChartRodData(
          toY: value, // hours slept
          color: color,
          width: 10, 
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // compute the max of hours slept to set the max amplitude of the plot
    double maxDataValue = widget.yValues.isNotEmpty ? widget.yValues.reduce((a, b) => a > b ? a : b) : 0; 
    double maxY = maxDataValue != 0 ? maxDataValue * 1.2 + 1 : 10;
    // determine age group to highlight healthy range
    String ageGroup = determineAgeGroup(widget.age);
    Map<String, List<double>> sleepScoreTable = {
      // legend: minIdeal, maxIdeal
      "School-age": [9, 11],
      "Teen": [8, 10],
      "Young Adult": [7, 9],
      "Adult" : [7, 9],
      "Older Adult" :[7, 8]
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
              
              // as lefttitles: hours
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

              // as bottom titles: days
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

              // right and top titles: null
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                // to distinguish healthy range
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
              return generateBarGroup(index, const Color.fromARGB(202, 97, 20, 169), data); // generate bar plot
            }).toList(),
            maxY: (maxY.toInt()).toDouble(), // set the max heigh of the plot
            
            // set what happens when bar are touched
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: false, 
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                if (event.isInterestedForInteractions &&
                    barTouchResponse != null &&
                    barTouchResponse.spot != null) {
                  final spot = barTouchResponse.spot!;
                  int hours = spot.touchedRodData.toY.toInt();
                  int minutes = ((spot.touchedRodData.toY - hours) * 60).toInt();
                  int minToFallAsleep = widget.minToFall[spot.touchedBarGroupIndex].toInt();
                  PieChart? pie = widget.pieCharts[spot.touchedBarGroupIndex];
                  String? legend = widget.legend[spot.touchedBarGroupIndex];

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        //title: Text('Sleep Data'),
                        content: SizedBox(height: 380, width: 250,
                          child: Column(
                          children: [const Text('Time asleep:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('$hours hours and $minutes minutes'),
                                    const SizedBox(height: 10),
                                    const Text('Time to fall asleep:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('$minToFallAsleep minutes'),
                                    const SizedBox(height: 10),
                                    const Text('Sleep phases distribution:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 200, // Height of the PieChart
                                          width: 200, // Width of the PieChart
                                          child: pie ?? const SizedBox(height: 1),
                                        ),
                                        const SizedBox(height: 1),
                                        legend!=null 
                                          ? Text(legend) 
                                          : const SizedBox(height: 1),
                                      ],),
                            ])),
                        actions: [
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:lag/algorithms/sleep_score.dart';

class BarChartSample7 extends StatefulWidget {
  const BarChartSample7(
      {super.key,
      required this.yValues,
      //required this.pieCharts,
      //required this.legend,
      required this.date});

  final DateTime date;
  final List<double> yValues;
  //final List<PieChart?> pieCharts;
  //final List<String?> legend;

  @override
  State<BarChartSample7> createState() => _BarChartSample7State();
}

class _BarChartSample7State extends State<BarChartSample7> {

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
          width: 15,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

  List<String> getPreviousSixMonths(DateTime date) {
    List<String> months = [];
    DateFormat monthFormat = DateFormat.MMMM();

    for (int i = 5; i >= 0; i--) {
      DateTime previousMonth = DateTime(date.year, date.month - i, date.day);
      String monthName = monthFormat.format(previousMonth);
      months.add(monthName);
    }
    return months;
  }
  final List<String> months = getPreviousSixMonths(widget.date);

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
                    return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${value.toInt()}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                        ));
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
                        child: Text(
                          months[index],
                          style: const TextStyle(
                              color: Colors.black, fontSize: 11),
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
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.black.withOpacity(0.4),
                strokeWidth: 0.5,
              ),
            ),
            barGroups: widget.yValues.asMap().entries.map((e) {
              final index = e.key;
              final data = e.value;
              return generateBarGroup(
                  index, const Color.fromARGB(202, 97, 20, 169), data);
            }).toList(),
            maxY: (widget.yValues).reduce(max),
            //maxY: (maxY.toInt()).toDouble(),
            /*
            barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: false, // Disable built-in tooltip
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (event.isInterestedForInteractions &&
                      barTouchResponse != null &&
                      barTouchResponse.spot != null) {
                    final spot = barTouchResponse.spot!;
                    int hours = spot.touchedRodData.toY.toInt();
                    int minutes =
                        ((spot.touchedRodData.toY - hours) * 60).toInt();

                    PieChart? pie = widget.pieCharts[spot.touchedBarGroupIndex];
                    String? legend = widget.legend[spot.touchedBarGroupIndex];

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height: 380,
                              width: 250,
                              child: Column(
                                children: [
                                  const Text('Today\'s workout time:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('$hours hours and $minutes minutes'),
                                  const SizedBox(height: 10),
                                  const Text('Exercise phase distribution: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: pie ?? const SizedBox(height: 1),
                                      ),
                                      const SizedBox(height: 1),
                                      legend != null
                                          ? Text(legend)
                                          : const SizedBox(height: 1),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }
                }),*/
          ),
        ),
      ),
    );
  }
}

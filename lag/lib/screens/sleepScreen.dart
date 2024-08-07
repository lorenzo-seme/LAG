import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/algorithms/sleep_score.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lag/screens/personal_info.dart';
import 'package:lag/utils/barplot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;
  
  const SleepScreen({super.key, required this.startDate, required this.endDate, required this.provider});

  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool _isPhasesCardExpanded = false;
  bool _isSleepHoursCardExpanded = false;
  bool _isMinutesToFallCardExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    String dataCheckMessage = checkData(widget.provider.sleepData);
    bool noDataAvailable = dataCheckMessage == "No data available";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bedtime),
            const SizedBox(width: 10),
            (widget.provider.start.year == widget.provider.end.year &&
                    widget.provider.start.month == widget.provider.end.month &&
                    widget.provider.start.day == widget.provider.end.day)
                ? Text(DateFormat('EEE, d MMM').format(widget.provider.start), 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold))
                : Text('${DateFormat('EEE, d MMM').format(widget.provider.start)} - ${DateFormat('EEE, d MMM').format(widget.provider.end)}', 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color.fromARGB(255, 227, 211, 244), 
      ),
      body: noDataAvailable
        ? _buildNoDataMessage()
        : SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Text("How many hours did you sleep each night?", 
                    style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                  Text(dataCheckMessage,
                    style: const TextStyle(fontSize: 10)),
                  const Text('Tap on bars to discover more details',
                    style: TextStyle(fontSize: 10,
                    color: Color.fromARGB(202, 97, 20, 169))),
                  SizedBox(
                    height: 230,
                    width: 330,
                    child: _buildBarPlot(widget.provider.sleepData),
                  ),
                  const SizedBox(height: 10),
                  const Text("Explore each quantity on average", style: TextStyle(fontSize: 12.0)),
                  _buildSleepHoursDataCard(widget.provider.sleepData),
                  _buildMinutesToFallDataCard(widget.provider.sleepData),
                  _buildPhasesDataCard(widget.provider.sleepData),
                ],
              ),
          ),
        ),
      ),
    ); 
  }

Widget _buildNoDataMessage() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error, size: 50),
        SizedBox(height: 10),
        Text("No data available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}


Widget _buildSleepHoursDataCard(List<SleepData> sleepData) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    child: Card(
      color: const Color.fromARGB(255, 242, 239, 245),
      elevation: 5,
      child: InkWell(
        onTap: () {
          setState(() {
            _isSleepHoursCardExpanded = !_isSleepHoursCardExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.hotel),
              trailing: SizedBox(
                width: 10,
                child: getScoreIcon(widget.provider.sleepScores["sleepHoursScores"]!),
              ),
              title: Text(
                "${getFormattedDuration(sleepData, 1)} slept",
                style: const TextStyle(fontSize: 14.0),
              ),
              subtitle: !_isSleepHoursCardExpanded
                  ? const Text('Tap to learn more', style: TextStyle(fontSize: 10.0))
                  : null,
            ),
            if (_isSleepHoursCardExpanded)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _sleepHoursAdvice(widget.provider.ageInserted, widget.provider.showAlertForAge, widget.provider.age),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMinutesToFallDataCard(List<SleepData> sleepData) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    child: Card(
      color: const Color.fromARGB(255, 242, 239, 245),
      elevation: 5,
      child: InkWell(
        onTap: () {
          setState(() {
            _isMinutesToFallCardExpanded = !_isMinutesToFallCardExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const SizedBox(width: 10, child: Icon(Icons.hourglass_bottom)),
              trailing: SizedBox(
                width: 10,
                child: getScoreIcon(widget.provider.sleepScores["minutesToFallAsleepScores"]!),
              ),
              title: Text(
                "${getFormattedDuration(sleepData, 2)} to fall asleep",
                style: const TextStyle(fontSize: 14.0),
              ),
              subtitle: !_isMinutesToFallCardExpanded
                  ? const Text('Tap to learn more', style: TextStyle(fontSize: 10.0))
                  : null,
            ),
            if (_isMinutesToFallCardExpanded)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "A normal sleep latency typically takes between 10 and 20 minutes to fall asleep. \nFalling asleep in less than 5 minutes is a sign of sleep deprivation, but it could also be a sign of a sleep disorder.\nRegularly taking more than 20-30 minutes to fall asleep is often a sign of insomnia. Among the causes are stress, anxiety, and depression",
                      style: TextStyle(fontSize: 11.0),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildPhasesDataCard(List<SleepData> sleepData) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPhasesCardExpanded = !_isPhasesCardExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeInOut,
        child: Card(
          color: const Color.fromARGB(255, 242, 239, 245),
          elevation: 5,
          child: Column(
            children: [
              ListTile(
                leading: SizedBox(
                    width: _isPhasesCardExpanded ? 10 : 70,
                    height: _isPhasesCardExpanded ? 100 : 50,
                    child: _isPhasesCardExpanded 
                        ? const Icon(Icons.nightlight)
                        : (calculatePercentage(sleepData) == null)
                          ? const Icon(Icons.nightlight)
                          : _buildPieChart(sleepData, _isPhasesCardExpanded)
                  ),
                
                trailing: _isPhasesCardExpanded 
                          ? SizedBox(
                            width: 10, 
                            child: getScoreIcon(widget.provider.sleepScores["combinedPhaseScores"]!),
                            ) 
                          : null,
                title: const Text(
                  "Sleep phases distribution",
                  style: TextStyle(fontSize: 14.0),
                  textAlign: TextAlign.left,
                  ),
                subtitle: !_isPhasesCardExpanded
                          ? const Text('Tap to learn more', style: TextStyle(fontSize: 10.0))
                          : null,
              ),
              if (_isPhasesCardExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: 140, height: 140,
                            child: _buildPieChart(sleepData, _isPhasesCardExpanded),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 140, height: 40,
                            child: Column(
                              children: [Text("DEEP: ${((calculatePercentage(sleepData)!)["deep"]!).toStringAsFixed(1)}%",
                                              style: const TextStyle(fontSize: 11),),
                                         Text("REM: ${((calculatePercentage(sleepData)!)["rem"]!).toStringAsFixed(1)}%",
                                              style: const TextStyle(fontSize: 11),)],
                            )
                          )
                        ],),
                      const SizedBox(width: 20),
                      const SizedBox(
                        width: 135, height: 200,
                        child: Text("To maintain your health and wellbeing, you need approximately \n20-25% REM sleep and 10-20% DEEP sleep. \nAn unusually large amount of REM sleep in a single night often indicates sleep deprivation",
                                    style: TextStyle(fontSize: 11.0),)
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _sleepHoursAdvice(bool ageInserted, bool showAlertForAge, int age) {
    if (!ageInserted && showAlertForAge) {
      return Column(
        children: [
          const Text("Estimates were made assuming that your age is 25. \nAdd your personal information for a customized advice!",
            style: TextStyle(fontSize: 11.0, fontStyle: FontStyle.italic),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('To Personal Info',
                  style: TextStyle(fontSize: 11.0)),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PersonalInfo())
                  );
                  final sp = await SharedPreferences.getInstance();
                  final name = sp.getString('name');
                  final userAge = sp.getString('userAge');
                  setState(() {
                    widget.provider.showAlertForAge = false;
                    if (userAge != null && name != null) {
                      widget.provider.nick = name;
                      widget.provider.age = int.parse(userAge);
                    } 
                  });
                },
              ),

              TextButton(
                child: const Text('Do not ask again',
                  style: TextStyle(fontSize: 11.0)),
                onPressed: () {
                  setState(() {
                    widget.provider.showAlertForAge = false;
                  });
                },
              )
            ],
          )
        ],
      );
    } else {
      String ageGroup = determineAgeGroup(age);
      String message = "";
      if (ageGroup == "School-age") {
        message = "If you are in the School-age range (between 6 and 13 years old), it is recommended to sleep between 9 and 11 hours, with less than 7 and more than 12 hours being discouraged";
      } else if (ageGroup == "Teen") {
        message = "If you are in the Teen-age range (between 14 and 17 years old), it is recommended to sleep between 8 and 10 hours, with less than 7 and more than 11 hours being discouraged";
      } else if (ageGroup == "Young Adult") {
        message = "If you are in the Young-Adult-age range (between 18 and 25 years old), it is recommended to sleep between 7 and 9 hours, with less than 6 and more than 11 hours being discouraged";
      } else if (ageGroup == "Adult") {
        message = "If you are in the Adult-age range (between 26 and 65 years old), it is recommended to sleep between 7 and 9 hours, with less than 6 and more than 10 hours being discouraged";
      } else if (ageGroup == "Older Adult") {
        message = "If you are in the Older-Adult-age range (more than 65 years old), it is recommended to sleep between 7 and 8 hours, with less than 5 and more than 9 hours being discouraged";
      } 
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(message, style: const TextStyle(fontSize: 11.0)),
          const Text("- National Sleep Foundation",
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11.0))
        ]
      );
    }
  }
  
  
  _buildBarPlot(List<SleepData> sleepData) {
    List<double> hoursList = [];
    List<double> minToFallList = [];
    List<PieChart?> pieList = [];
    List<String?> legend = [];
    for (SleepData data in sleepData) {
      if (data.minutesAsleep != null) {
        hoursList.add(data.minutesAsleep/60);
        minToFallList.add(data.minutesToFallAsleep);
        pieList.add(_buildPieChart([data], true));
        legend.add("DEEP: ${((calculatePercentage([data])!)["deep"]!).toStringAsFixed(1)}% \nREM: ${((calculatePercentage([data])!)["rem"]!).toStringAsFixed(1)}%");
      } else {
        hoursList.add(0);
        minToFallList.add(0);
        pieList.add(null);
        legend.add(null);
      }
    }
    while (hoursList.length < 7) {
      hoursList.add(0);
      minToFallList.add(0);
      pieList.add(null);
      legend.add(null);
    }
    return BarChartSample7(yValues: hoursList, age: widget.provider.age, minToFall: minToFallList, pieCharts: pieList, legend: legend);    
  }

}

// GENERAL FUNCTIONS

double? calculateAverage(List<SleepData> sleepDataList, int n) {
  double sum = 0;
  int count = 0;
  for (SleepData data in sleepDataList) {
    if (n == 1 && data.minutesAsleep != null) {
      sum += data.minutesAsleep!;
      count++;
    }
    if (n == 2 && data.minutesToFallAsleep != null) {
      sum += data.minutesToFallAsleep!;
      count++;
    }
  }
  if (count == 0) {
    return null; // Handles the case where all entries are null (no data available for this 7 days)
  }
  double average = sum / count;
  return average;
}

Widget getScoreIcon(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return const Icon(Icons.error); // if no valid scores
  }
  double averageScore = validScores.reduce((a, b) => a + b) / validScores.length;
  if (averageScore >= 90) {
    return const Icon(Icons.sentiment_very_satisfied); // average score above 80
  } else if (averageScore >= 80) {
    return const Icon(Icons.sentiment_satisfied); // average score between 60 and 80
  } else if (averageScore >= 70) {
    return const Icon(Icons.sentiment_neutral); // average score between 60 and 80
  } else if (averageScore >= 60) {
    return const Icon(Icons.sentiment_dissatisfied); // average score between 60 and 80
  } else {
    return const Icon(Icons.sentiment_very_dissatisfied); // average score below 60
  }
}

String formatDuration(double totalMinutes) {
  int hours = (totalMinutes / 60).floor();
  int minutes = (totalMinutes % 60).round();
  if (hours == 0) {
    return "$minutes minutes";
  } else {
    return "$hours hours and $minutes minutes";
  }
}

String getFormattedDuration(List<SleepData> sleepData, int n) {
  double? average = calculateAverage(sleepData, n);
  if (average == null) {
    return "No data available";
  } else {
    return formatDuration(average);
  }
}

Map<String, double>? calculatePercentage(List<SleepData> sleepDataList) {
  double totalDeepSleep = 0;
  double totalRemSleep = 0;
  double totalLightSleep = 0;
  double totalAwake = 0;
  int count = 0; // to keep trace of days without data
  for (var data in sleepDataList) {
    if (!(data.levels == null)) {
      totalDeepSleep += data.levels["deep"];
      totalRemSleep += data.levels["rem"];
      totalLightSleep += data.levels["light"];
      totalAwake += data.levels["wake"];
      count++;
    }
  }
  if (count==0) {
    return null; // sleepDataList has only days without recordings
  } else {
    double total = totalDeepSleep + totalRemSleep + totalLightSleep + totalAwake;
    Map<String, double> percentages = {
      'deep': (totalDeepSleep / total) * 100,
      'rem': (totalRemSleep / total) * 100,
      'light': (totalLightSleep / total) * 100,
      'wake': (totalAwake / total) * 100,
    };
    return percentages;
  }
}

PieChart _buildPieChart(List<SleepData> sleepData, bool _isPhasesCardExpanded) {
  double radius = 30;
  bool title = false;  
  (_isPhasesCardExpanded) ? radius=75 : radius=30;
  (_isPhasesCardExpanded) ? title=true : title=false;
  return PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["deep"],
                  color: const Color(0xFF8A2BE2),
                  title: "DEEP", titlePositionPercentageOffset: 0.7, titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  showTitle: title,
                  radius: radius,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["rem"],
                  color: const Color(0xFFBA55D3),
                  title: "REM", titlePositionPercentageOffset: 0.7, titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  showTitle: title,
                  radius: radius,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["light"],
                  color: const Color(0xFF9370DB),
                  title: "LIGHT", titlePositionPercentageOffset: 0.7, titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  showTitle: title,
                  radius: radius,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["wake"],
                  color: const Color.fromARGB(255, 216, 158, 216),
                  title: "WAKE", titlePositionPercentageOffset: 0.7, titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  showTitle: title,
                  radius: radius,
                ),
              ],
              centerSpaceColor: Colors.transparent,
              centerSpaceRadius: 0.01,
              sectionsSpace: 2,
            ),
          );
}

String checkData(List<SleepData> sleepData) {
  List<String> noDataDays = [];
  bool noDataFlag = true;
  for (SleepData data in sleepData) {
    if (data.efficiency == null) {
      String formattedDay = DateFormat('EEEE', 'en_US').format(data.day);
      noDataDays.add(formattedDay);
    } else {
      noDataFlag = false;
    }
  }
  if (noDataDays.isEmpty) {
    return "All days have data";
  } else if (noDataFlag) {
    return "No data available";
  } else if (noDataDays.length == 1) {
    return "${noDataDays[0]}: No data available";
  } else {
    return "${noDataDays.join(' ,')}: No data available";
  }
}
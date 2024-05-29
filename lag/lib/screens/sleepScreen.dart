import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/algorithms/sleep_score.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lag/utils/custom_plot.dart';

class SleepScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;

  const SleepScreen({super.key, required this.startDate, required this.endDate, required this.provider});

  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sleep Data',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                (widget.provider.start.year == widget.provider.end.year &&
                        widget.provider.start.month == widget.provider.end.month &&
                        widget.provider.start.day == widget.provider.end.day)
                    ? Text(DateFormat('EEE, d MMM').format(widget.provider.start))
                    : Text('${DateFormat('EEE, d MMM').format(widget.provider.start)} - ${DateFormat('EEE, d MMM').format(widget.provider.end)}'),
                const SizedBox(height: 5),
                Container(
                  height: 100,
                  child: CustomPlot(data: widget.provider.sleepData),
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

  Widget _buildSleepHoursDataCard(List<SleepData> sleepData) {
    return Card(
      elevation: 5,
      child: ExpansionTile(
        leading: const Icon(Icons.hotel),
        trailing: SizedBox(
          width: 10,
          child: getScoreIcon(widget.provider.sleepScores["sleepHoursScores"]!),
        ),
        title: Text(
          "${getFormattedDuration(sleepData, 1)} slept",
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text('Tap to learn more', style: TextStyle(fontSize: 10.0)),
        children: [ Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_sleepHoursAdvice(widget.provider.sleepScores["ageFlag"]!),
                       const Text("- National Sleep Foundation",
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11.0))],
            ),
          ), ],
      ),
    );
  }

  Widget _buildMinutesToFallDataCard(List<SleepData> sleepData) {
    return Card(
      elevation: 5,
      child: ExpansionTile(
        leading: const Icon(Icons.hourglass_bottom),
        trailing: SizedBox(
          width: 10,
          child: getScoreIcon(widget.provider.sleepScores["minutesToFallAsleepScores"]!),
        ),
        title: Text(
          "${getFormattedDuration(sleepData, 2)} to fall asleep",
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text('Tap to learn more', style: TextStyle(fontSize: 10.0)),
        children: const [ Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("A normal sleep latency typically takes between 10 and 20 minutes to fall asleep. \nFalling asleep in less than 5 minutes is a sign of sleep deprivation, but it could also be a sign of a sleep disorder.\nRegularly taking more than 20-30 minutes to fall asleep is often a sign of insomnia. Among the causes are stress, anxiety, and depression",
                       style: TextStyle(fontSize: 11.0),)],
            ),
          ), ],
      ),
    );
  }

  Widget _buildPhasesDataCard(List<SleepData> sleepData) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: SizedBox(
          width: 50, // Larghezza del grafico a torta
          height: 50, // Altezza del grafico a torta
          child: (calculatePercentage(sleepData)==null) ?
            const Icon(Icons.nightlight) :
            _buildPieChart(sleepData),
          ),
        trailing: SizedBox(
          width: 10,
          child: getScoreIcon(widget.provider.sleepScores["combinedPhaseScores"]!),
        ),
        title: Text(
          "${getFormattedDuration(sleepData, 2)} to fall asleep", // NECESSARIO MODIFICARE A PARTIRE DA QUI
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text('Tap to learn more', style: TextStyle(fontSize: 10.0)),
      ),
    );
  }
  
  Text _sleepHoursAdvice(List<double> list) {
    if (list[0] == -1) {
      return const Text("Estimates were made assuming that your age is 25. \n Add your birth year in the Personal Information section for a customized advice!",
        style: TextStyle(fontSize: 11.0, fontStyle: FontStyle.italic),);
    } else {
      String ageGroup = determineAgeGroup(list[0].toInt());
      if (ageGroup == "School-age") {
        return const Text("If you are in the School-age range (between 6 and 13 years old), it is recommended to sleep between 9 and 11 hours, with less than 7 and more than 12 hours being discouraged",
          style: TextStyle(fontSize: 11.0),);
      } else if (ageGroup == "Teen") {
        return const Text("If you are in the Teen-age range (between 14 and 17 years old), it is recommended to sleep between 8 and 10 hours, with less than 7 and more than 11 hours being discouraged",
          style: TextStyle(fontSize: 11.0),);
      } else if (ageGroup == "Young Adult") {
        return const Text("If you are in the Young-Adult-age range (between 18 and 25 years old), it is recommended to sleep between 7 and 9 hours, with less than 6 and more than 11 hours being discouraged",
          style: TextStyle(fontSize: 11.0));
      } else if (ageGroup == "Adult") {
        return const Text("If you are in the Adult-age range (between 26 and 65 years old), it is recommended to sleep between 7 and 9 hours, with less than 6 and more than 10 hours being discouraged",
          style: TextStyle(fontSize: 11.0),);
      } else if (ageGroup == "Older Adult") {
        return const Text("If you are in the Older-Adult-age range (more than 65 years old), it is recommended to sleep between 7 and 8 hours, with less than 5 and more than 9 hours being discouraged",
          style: TextStyle(fontSize: 11.0),);
      } else {return const Text("");}
    }
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

PieChart _buildPieChart(sleepData) {
  return PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["deep"],
                  color: const Color(0xFF8A2BE2), // Viola scuro per Deep Sleep
                  title: '',
                  radius: 30,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["rem"],
                  color: const Color(0xFFBA55D3), // Viola medio per REM Sleep
                  title: '',
                  radius: 30,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["light"],
                  color: const Color(0xFF9370DB), // Viola chiaro per Light Sleep
                  title: '',
                  radius: 30,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(sleepData)!)["wake"],
                  color: const Color.fromARGB(255, 216, 158, 216), // Viola chiaro per Awake
                  title: '',
                  radius: 30,
                ),
              ],
              centerSpaceColor: Colors.transparent,
              centerSpaceRadius: 0.01,
              sectionsSpace: 2, // Rimuove lo spazio tra le sezioni
              // Altre opzioni come angolo di inizio, ecc.
            ),
          );
}
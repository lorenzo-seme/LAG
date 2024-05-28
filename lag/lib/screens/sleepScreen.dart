import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lag/utils/custom_plot.dart';
// import 'package:lag/utils/custom_plot.dart';


// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class SleepScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;

  const SleepScreen({super.key, required this.startDate, required this.endDate, required this.provider});
  
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
              (provider.start.year == provider.end.year && provider.start.month == provider.end.month && provider.start.day == provider.end.day) ?
                  Text(DateFormat('EEE, d MMM').format(provider.start)):
                  Text('${DateFormat('EEE, d MMM').format(provider.start)} - ${DateFormat('EEE, d MMM').format(provider.end)}'),              const SizedBox(height: 5),
              //const Text("PLOT DAYS VS SCORE", style: TextStyle(fontSize: 32)),
              Container(
                      height: 100,
                      child:CustomPlot(data: provider.sleepData)),
              const SizedBox(height: 10,),
              const Text("Explore each quantity on average", style: TextStyle(fontSize: 12.0)),
              _buildSleepHoursDataCard(provider.sleepData),
              _buildMinutesToFallDataCard(provider.sleepData),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 20,
                      child: PieChart(
                      PieChartData(
                        sections: [ // QUI MODIFICA
                          PieChartSectionData(value: 40, color: Colors.blue, title: 'Deep Sleep'),
                          PieChartSectionData(value: 30, color: Colors.red, title: 'REM Sleep'),
                          PieChartSectionData(value: 30, color: Colors.green, title: 'Light Sleep'),
                        ],
                      ),
                    ),
                    )
                  ),
                  Expanded(child: _buildPhasesDataCard(provider.sleepData)),
                ],
              ),
            ],
          ),
        ),
      ),
    )
  );
}

// PROVA AD IMPLEMENTARE UNA COSA TIPO CHE QUANDO CLICCHI LA CARD PER MORE INFO LA CARD SI ESPANDE E FA VEDERE IL TESTO
  Widget _buildSleepHoursDataCard(List<SleepData> sleepData) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.hotel),
        trailing: SizedBox(
          width: 10,
          child: getScoreIcon(provider.sleepScores["sleepHoursScores"]!),
        ),
        title: Text("${getFormattedDuration(sleepData, 1)} slept",
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text('Tap to learn more', style: TextStyle(fontSize: 10.0)),
      ),
    );
  }

  Widget _buildMinutesToFallDataCard(List<SleepData> sleepData) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.hourglass_bottom),
        trailing: SizedBox(
          width: 10,
          child: getScoreIcon(provider.sleepScores["minutesToFallAsleepScores"]!),
        ),
        title: Text("${getFormattedDuration(sleepData, 2)} to fall asleep",
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text('Tap to learn more', style: TextStyle(fontSize: 10.0)),
      ),
    );
  }

  Widget _buildPhasesDataCard(List<SleepData> sleepData) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.nightlight_round),
        trailing: SizedBox(
          width: 10,
          child: getScoreIcon(provider.sleepScores["combinedPhaseScores"]!),
        ), 
        title: Text("${getFormattedDuration(sleepData, 2)} to fall asleep", // QUI MODIFICA
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text('Tap to learn more', style: TextStyle(fontSize: 10.0)),
      ),
    );
  }
}


// GENERAL FUNCTIONS

double? calculateAverage(List<SleepData> sleepDataList, int n) {
  double sum = 0;
  int count = 0;
  for (SleepData data in sleepDataList) {
    if (n==1 && data.minutesAsleep != null) {
      sum += data.minutesAsleep!;
      count++;
    }
    if (n==2 && data.minutesToFallAsleep != null) {
      sum += data.minutesToFallAsleep!;
      count++;
    }
  }
  if (count == 0) {return null;} // Handles the case where all entries are null (no data available for this 7 days)
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
  if (hours==0) {return "$minutes minutes";
  } else {return "$hours hours and $minutes minutes";
  }
}

String getFormattedDuration(List<SleepData> sleepData, int n) {
  double? average= calculateAverage(sleepData, n);
  if (average== null) {
    return "No data available";
  } else {
    return formatDuration(average);
  }
}
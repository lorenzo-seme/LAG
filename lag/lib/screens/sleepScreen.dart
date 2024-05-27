import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/providers/homeProvider.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text('${DateFormat('EEE, d MMM').format(startDate)} - ${DateFormat('EEE, d MMM').format(endDate)}'),
              const SizedBox(height: 5),
              const Text("PLOT DAYS VS SCORE", style: TextStyle(fontSize: 32)),
              const SizedBox(height: 10,),
              const Text("Explore each quantity on average", style: TextStyle(fontSize: 12.0)),
              _buildSleepDataCard(provider.sleepData),
              const Text("1. SCORES VA MA NON L'ALTRA CHIAVE NO?? VERIFICA L'IMPLEMENTAZIONE IN SLEEP SCORE QUALCOSA NON VA \n 2. HO NOTATO CHE SE DALLA HOME PASSIAMO AL PROFILO E POI TORNIAMO INDIETRO, LA DATA SI INIZIALIZZA DI NUOVO!!"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepDataCard(List<SleepData> sleepData) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.hotel),
        trailing: SizedBox(
          width: 10,
          child: getSleepScoreIcon(provider.sleepScores["sleepHoursScores"]!),
        ),
        title: Text(
          calculateAverageSleepMinutes(sleepData) == null
              ? "No data available"
              : "${double.parse((calculateAverageSleepMinutes(sleepData)! / 60).toStringAsFixed(1))} hours slept",
          style: const TextStyle(fontSize: 14.0),
        ),
        subtitle: const Text('Tap to learn more', style: TextStyle(fontSize: 10.0)),
      ),
    );
  }
}

double? calculateAverageSleepMinutes(List<SleepData> sleepDataList) {
  double sum = 0;
  int count = 0;
  for (SleepData data in sleepDataList) {
    if (data.minutesAsleep != null) {
      sum += data.minutesAsleep!;
      count++;
    }
  }
  if (count == 0) {return null;} // Handles the case where all entries are null (no data available for this 7 days)
  double average = sum / count;
  return average;
}

Widget getSleepScoreIcon(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return const Icon(Icons.error); // if no valid scores
  }
  double averageScore = validScores.reduce((a, b) => a + b) / validScores.length; 
  if (averageScore >= 80) {
    return const Icon(Icons.sentiment_satisfied); // average score above 80
  } else if (averageScore >= 60) {
    return const Icon(Icons.sentiment_neutral); // average score between 60 and 80
  } else {
    return const Icon(Icons.sentiment_dissatisfied); // average score below 60
  }
}

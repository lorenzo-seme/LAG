import 'package:lag/models/exercisedata.dart';

List<double> calculateExerciseScore(List<ExerciseData> exerciseDataList, int age, bool ageInserted) {
  Map<String, double> weights = {};
  Map<String, int> activityScores = {};
  List<double> durations = [];
  double frequency = 0;
  List<double> frequencies = [];
  List<double> base = [];

  if (exerciseDataList.isNotEmpty) {
    for (int i = 0; i < exerciseDataList.length; i++) {
      ExerciseData data = exerciseDataList[i];
      durations.add(data.duration);
      if (data.duration > 0) {
        frequency += 1;
        frequencies.add(frequency);
      } else {
        frequencies.add(0);
      }
      if (age < 17) {
        weights = {'duration': 0.3, 'distance': 0.3, 'frequency': 0.1, 'age': 0.2, 'activityType': 0.1};
        activityScores = {'Corsa': 8, 'Camminata': 6, 'Bici': 7, 'Nuoto': 9, 'Sport': 8};
        if (durations[i] > 60) {
          base.add(60);
        } else if (durations[i] > 30) {
          base.add(50);
        } else {
          base.add(20); // Ensure base has a value for all counters
        }
      } else if (age <= 64 || !ageInserted) {
        weights = {'duration': 0.3, 'distance': 0.3, 'frequency': 0.1, 'age': 0.1, 'activityType': 0.2};
        activityScores = {'Corsa': 10, 'Camminata': 5, 'Bici': 7, 'Nuoto': 8, 'Sport': 7};
        if (durations[i] > 40) {
          base.add(70);
        } else if (durations[i] > 25) {
          base.add(60);
        } else {
          base.add(20); // Ensure base has a value for all counters
        }
      } else {
        weights = {'duration': 0.2, 'distance': 0.3, 'frequency': 0.1, 'age': 0.2, 'activityType': 0.2};
        activityScores = {'Corsa': 7, 'Camminata': 6, 'Bici': 7, 'Nuoto': 9, 'Sport': 8};
        if (durations[i] > 25) {
          base.add(60);
        } else {
          base.add(20); // Ensure base has a value for all counters
        }
      }
    }
  } else {
    return [];
  }

  double ageScore = (10 - (age ~/ 10)).clamp(0, 10).toDouble();
  List<double> frequencyScore = List.filled(frequencies.length, 0.0);
  for (int i = 0; i < frequencies.length; i++) {
    frequencyScore[i] = frequencies[i] * (10 / (i + 1));
  }

  List<double> scores = List.filled(durations.length, 0.0);
  if (exerciseDataList.isNotEmpty) {
    for (int i = 0; i < exerciseDataList.length; i++) {
      scores[i] = base[i] + frequencyScore[i] * (weights["frequency"] ?? 0) + ageScore * (weights["age"] ?? 0);
      if (exerciseDataList[i].actNames.isNotEmpty) {
        for (var act in exerciseDataList[i].actNames) {
          if (exerciseDataList[i].activities.containsKey(act)) {
            scores[i] += (activityScores[act] ?? 0) +
                ((exerciseDataList[i].activities[act]![0]) / 10) * (weights["duration"] ?? 0) * (activityScores[act] ?? 0) +
                ((exerciseDataList[i].activities[act]![1]) / 10) * (weights["distance"] ?? 0) * (activityScores[act] ?? 0);
          }
        }
      }
    }
  }

  List<double> finalScores = scores.map((score) {
    return double.parse(score.clamp(0, 100).toStringAsFixed(1));
  }).toList();
  return finalScores;
}

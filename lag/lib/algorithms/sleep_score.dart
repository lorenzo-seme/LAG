import 'dart:math';
import 'package:lag/models/sleepdata.dart';
 
Future<Map<String, List<double>>> getSleepScore(List<SleepData> sleeplist, int age, bool ageInserted) async {
  List<double> scores = [];
  List<double> sleepHoursScores = [];
  List<double> minutesToFallAsleepScores = [];
  List<double> combinedPhaseScores = [];
  String ageGroup = determineAgeGroup(age);

  for (var sleepData in sleeplist) {
    double score = -1; // -1 to distinguish days without data
    double sleepHoursScore = -1;
    double minutesToFallAsleepScore = -1;
    double combinedPhaseScore = -1;
    
    // ordered according decreasing weigth
    // EFFICIENCY
    if (sleepData.efficiency != null) {
      score = sleepData.efficiency * 0.4; // higher weigth for efficiency
    }
    // MINUTE ASLEEP
    if (sleepData.minutesAsleep != null) {
      double sleepHours = sleepData.minutesAsleep / 60;
      sleepHoursScore = calculateSleepHoursScore(sleepHours, ageGroup);
      score += sleepHoursScore * 0.35; 
    }
    // MINUTES TO FALL ASLEEP
    if (sleepData.minutesToFallAsleep != null) {
      minutesToFallAsleepScore = calculateMinutesToFallAsleepScore(sleepData.minutesToFallAsleep);
      score += minutesToFallAsleepScore * 0.05; // very low weight since we noticed that this quantity is always zero (maybe is due to Fitbit)
    }
    // LEVELS
    if (sleepData.levels != null) {
      double remMinutes = sleepData.levels['rem'];
      double deepMinutes = sleepData.levels['deep'];
      double totalMinutes = sleepData.levels['rem'] + sleepData.levels['deep'] + sleepData.levels['light'] + sleepData.levels['wake'];

      double remScore = calculatePhaseScore(remMinutes, totalMinutes, 20, 25); // 20%-25% for REM
      double deepScore = calculatePhaseScore(deepMinutes, totalMinutes, 10, 20); // 10%-20% for deep

      combinedPhaseScore = (remScore + deepScore) / 2.0; // average of the two phases
      score += combinedPhaseScore * 0.2; 
    }
    if (score!=-1) {
      score = score.clamp(0, 100); // final score, between 0 and 100
    }
    scores.add(score);
    sleepHoursScores.add(sleepHoursScore); // to be returned
    minutesToFallAsleepScores.add(minutesToFallAsleepScore);
    combinedPhaseScores.add(combinedPhaseScore);
  }
  Map<String, List<double>> output = {
    "sleepHoursScores" : sleepHoursScores,
    "scores" : scores,
    "minutesToFallAsleepScores" : minutesToFallAsleepScores,
    "combinedPhaseScores" : combinedPhaseScores,
  };
  return output;
}

double calculateMinutesToFallAsleepScore(double minutes) {
  if (minutes <= 5) { return 50; // sign of sleep deprivation
  } else if (minutes <= 10) { return 75; 
  } else if (minutes <= 20) { return 100; // between 10 and 20 minutes = normal healthy latency
  } else if (minutes <= 30) { return 75.0; 
  } else if (minutes <= 60) { return 50.0; // sign of insomnia (caused by stress, anxiety or depression)
  } else { return 25.0; 
  }
}

double calculatePhaseScore(double phaseMinutes, double totalMinutes, double minPercent, double maxPercent) {
  double phasePercent = (phaseMinutes / totalMinutes) * 100;
  if (phasePercent >= minPercent && phasePercent <= maxPercent) {
    return 100.0; // healthy range
  } else if (phasePercent < minPercent) {
    double deficit = minPercent - phasePercent;
    return max(100.0 - (deficit * 7),0); // -7 points for every % less 
  } else {
    double surplus = phasePercent - maxPercent;
    return max(100.0 - (surplus * 7),0); // -7 points for every % more
  }
}

String determineAgeGroup(int age) {
  if (age>=6 && age<=13) {return "School-age"; // supposing <5 y.o. children do not use this app
  } else if (age<=17) {return "Teen";
  } else if (age<=25) {return "Young Adult";
  } else if (age<=65) {return "Adult";
  } else {return "Older Adult";
  }
}

double calculateSleepHoursScore(double sleepHours, String ageGroup) {
  Map<String, List<double>> sleepScoreTable = {
    // legend: minIdeal, maxIdeal, minAcceptable, maxAcceptable
    "School-age": [9, 11, 7, 12],
    "Teen": [8, 10, 7, 11],
    "Young Adult": [7, 9, 6, 11],
    "Adult" : [7, 9, 6, 10],
    "Older Adult" :[7, 8, 5, 9]
  };
  List<double> scoreData = sleepScoreTable[ageGroup]!;
  double minIdeal = scoreData[0];
  double maxIdeal = scoreData[1];
  double minAcceptable = scoreData[2];
  double maxAcceptable = scoreData[3];

  if (sleepHours >= minIdeal && sleepHours <= maxIdeal) {return 100;
  } else if (sleepHours >= minAcceptable && sleepHours <= maxAcceptable) {return 75;
  } else {return 25;
  }
}
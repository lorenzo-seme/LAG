import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, List<double>>> getSleepScore(List sleeplist) async {
  List<double> scores = [];
  List<double> sleepHoursScores = [];

  SharedPreferences sp = await SharedPreferences.getInstance();
  int userAge = sp.getInt('userAge') ?? 25; // Default at 25 if not specified
  String ageGroup = determineAgeGroup(userAge);
  for (var sleepData in sleeplist) {
    double score = -1; // -1 to distinguish days without data
    double sleepHoursScore = -1;
    
    // ordered according decreasing weigth
    // EFFICIENCY
    if (sleepData.efficiency != null) {
      score = sleepData.efficiency * 0.4; // higher weigth for efficiency
    }
    // MINUTE ASLEEP
    if (sleepData.minutesAsleep != null) {
      double sleepHours = sleepData.minutesAsleep / 60;
      double sleepHoursScore = calculateSleepHoursScore(sleepHours, ageGroup);
      score += sleepHoursScore * 0.3; 
    }
    sleepHoursScores.add(sleepHoursScore); // to be returned
    // MINUTES TO FALL ASLEEP
    if (sleepData.minutesToFallAsleep != null) {
      double minutesToFallAsleepScore = calculateMinutesToFallAsleepScore(sleepData.minutesToFallAsleep);
      score += minutesToFallAsleepScore * 0.2; 
    }
    // LEVELS
    if (sleepData.levels != null) {
      double remMinutes = sleepData.levels['rem'];
      double deepMinutes = sleepData.levels['deep'];
      double totalMinutes = sleepData.minutesAsleep * 60;

      double remScore = calculatePhaseScore(remMinutes, totalMinutes, 20, 25); // 20%-25% for REM
      double deepScore = calculatePhaseScore(deepMinutes, totalMinutes, 10, 20); // 10%-20% for deep

      double combinedPhaseScore = (remScore + deepScore) / 2.0; // average of the two phases
      score += combinedPhaseScore * 0.1; 
    }
    
    if (score!=-1) {
      score = score.clamp(0, 100); // final score, between 0 and 100
    }
    scores.add(score);
  }
  Map<String, List<double>> output = {
    "sleepHoursScores" : sleepHoursScores,
    "scores" : scores,
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
    return 100.0 - (deficit * 5); // -5 points for every % less 
  } else {
    double surplus = phasePercent - maxPercent;
    return 100.0 - (surplus * 5); // -5 points for every % more
  }
}

String determineAgeGroup(int age) {
  if (age>=5 && age<=12) {return "School-age"; // supposing <5 y.o. children do not use this app
  } else if (age<=18) {return "Teen";
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
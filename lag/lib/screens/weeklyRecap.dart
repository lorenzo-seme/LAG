import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/InfoRHR.dart';
import 'package:lag/screens/exerciseScreen.dart';
import 'package:lag/screens/infoExercise.dart';
import 'package:lag/screens/infoSleep.dart';
import 'package:lag/screens/sleepScreen.dart';
import 'package:provider/provider.dart';


// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class WeeklyRecap extends StatelessWidget {
  const WeeklyRecap({super.key});


  //Future<double> sleepAvg = calculateAverageSleepScore(BuildContext context, Future<List<double>> sleepDataFuture); 
  String getCurrentWeekIdentifier(DateTime dateToday) {
    DateTime firstDayOfYear = DateTime(dateToday.year, 1, 1);
    int daysDifference = dateToday.difference(firstDayOfYear).inDays;
    int weekNumber = (daysDifference / 7).ceil() + 1;
    return "$weekNumber";
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: /*ChangeNotifierProvider(
            create: (context) => HomeProvider(),
            builder: (context, child) => */Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, top: 10, bottom: 20),
              child: Consumer<HomeProvider>(builder: (context, provider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, ${provider.nick}",style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    const Text('Weekly Personal Recap',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(onTap: () async {
                        if(provider.isReady){
                          await provider.dateSubtractor(provider.start);
                          await provider.getDataOfWeek(provider.start, provider.end);
                          //ScaffoldMessenger.of(context).clearSnackBars();
                        }
                        else{
                          ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.blue,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(8),
                                      duration: Duration(seconds: 1),
                                      content: Text(
                                          "Still loading... Keep calm!"),
                                    ),
                                  );
                        }
                      },
                      child: const Icon(Icons.navigate_before),
                    ),
                  ),
                  (provider.start.year == provider.end.year && provider.start.month == provider.end.month && provider.start.day == provider.end.day) ?
                  Text(DateFormat('EEE, d MMM').format(provider.start)):
                  Text('${DateFormat('EEE, d MMM').format(provider.start)} - ${DateFormat('EEE, d MMM').format(provider.end)}'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: (provider.end.year == provider.showDate.year && provider.end.month == provider.showDate.month && provider.end.day == provider.showDate.day) ?
                      const Icon(Icons.stop) :
                      InkWell(
                        onTap: () async {
                          if(provider.isReady){
                              await provider.dateAdder(provider.start);
                              await provider.getDataOfWeek(provider.start, provider.end);
                              //ScaffoldMessenger.of(context).clearSnackBars();
                          }
                          else{
                            ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.blue,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(8),
                                      duration: Duration(seconds: 1),
                                      content: Text(
                                          "Still loading... Keep calm!"),
                                    ),
                                  );
                          }
                        },
                        child: const Icon(Icons.navigate_next),
                      ), 
                  ),
                ]),
                const Text("Cumulative Score",style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                const Text("Descriptive index of the quality of your week",
                    style: TextStyle(fontSize: 12,color: Colors.black45),
                    ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (provider.score.toInt()).toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(provider.score / 100 < 0.33
                            ? "Low"
                            : provider.score / 100 > 0.33 &&
                                    provider.score / 100 < 0.66
                                ? "Medium"
                                : "High",
                        style:const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        height: 15,
                        child: ClipRRect(
                          borderRadius:const BorderRadius.all(Radius.circular(10)),
                          child: LinearProgressIndicator(
                            value: provider.score / 100,
                            backgroundColor: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Explore Daily Trends in each parameter",
                  style: TextStyle(fontSize: 16),
                ), 
                const SizedBox(height: 5),
                const Text("See how much you’ve been striving throughout the week",
                    style: TextStyle(fontSize: 12,color: Colors.black45),
                    ),
                const SizedBox(height: 10),
                const Text('Sleep Data'),
                (provider.sleepData.isEmpty) 
                  ? const CircularProgressIndicator.adaptive() 
                  : Card(
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(Icons.bedtime),
                      trailing: Container(
                        child: getScoreIcon((provider.sleepScores)["scores"]!) // funzione definita in sleepScreen
                      ),
                      title: Text(calculateAverageSleepScore((provider.sleepScores)["scores"]!)), // funzione definita sotto
                      subtitle: const Text('about quality of your sleep this week',
                                          style: TextStyle(fontSize: 11),),
                      onTap: () => _toSleepPage(context, provider.start, provider.end, provider),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text('Exercise Data'),
                  (provider.exerciseData.isEmpty) 
                  ? const CircularProgressIndicator.adaptive() 
                  :
                  Card(
                    elevation: 5,
                    child: ListTile(
                      leading: Icon(Icons.directions_run),
                      trailing: Container(
                        child: getIconScore(calculateExerciseScore(provider, provider.start, provider.end, provider.age, provider.ageInserted)),
                        ),
                      title: Text('Exercise score: ${calculateExerciseScore(provider, provider.start, provider.end, provider.age, provider.ageInserted)}%'),
                      subtitle: const Text('about your exercise activity of this week',
                                          style: TextStyle(fontSize: 11),),
                      onTap: () {
                        print(getCurrentWeekIdentifier(provider.start));
                        bool current;
                        if (getCurrentWeekIdentifier(provider.start) == getCurrentWeekIdentifier(DateTime.now())) {
                          current = true;
                        } else {
                          current = false;
                        }
                        _toExercisePage(context, provider.start, provider.end, provider, getCurrentWeekIdentifier(provider.start), current);
                      } ,
                              ),
                      ),
                const SizedBox(height: 20), 
                const Text(
                  "Learn Something More",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 250,
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                            width: 300,
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => InfoSleep())),
                                  child: Hero(transitionOnUserGestures: true,
                                    tag: 'sleep',
                                    child: Container(
                                      width: 300,
                                      height: 200,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15.0),
                                            bottomLeft: Radius.circular(15.0),
                                            bottomRight: Radius.circular(15.0),
                                            topRight: Radius.circular(15.0)),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              'assets/sleep.jpg'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "How does sleep affect my health?",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                        ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                            width: 300,
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => InfoExercise())),
                                  child: Hero(
                                    tag: 'exercise',
                                    child: Container(
                                    width: 300,
                                    height: 200,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15.0),
                                          bottomLeft: Radius.circular(15.0),
                                          bottomRight: Radius.circular(15.0),
                                          topRight: Radius.circular(15.0)),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/exercise.jpg'),
                                      ),
                                    ),
                                  ),),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "How does exercise affect my health?",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                        ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                            width: 300,
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => InfoRHR())),
                                  child: Hero(
                                    tag: 'rhr',
                                    child: Container(
                                    width: 300,
                                    height: 200,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15.0),
                                          bottomLeft: Radius.circular(15.0),
                                          bottomRight: Radius.circular(15.0),
                                          topRight: Radius.circular(15.0)),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/rhr.png'),
                                      ),
                                    ),
                                  ),),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Why RHR reflects my health status?",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                        ),
                    ],
                  ),
                )
              ],
            );
          }),
        ),
      )
    //)
    );
  }
  
  // Method for navigation weeklyRecap -> sleepScreen
  void _toSleepPage(BuildContext context, DateTime start, DateTime end, HomeProvider provider) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SleepScreen(startDate: start, endDate: end, provider: provider)
    ));
  }
  
  // Method for navigation weeklyRecap -> exerciseScreen
  void _toExercisePage(BuildContext context, DateTime start, DateTime end, HomeProvider provider, String week, bool current) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ExerciseScreen(startDate: start, endDate: end, provider: provider, week: week, current : current)));
  }
} 


String calculateAverageSleepScore(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return "No data available"; // if no valid scores
  } else {
    double averageScore = validScores.reduce((a, b) => a + b) / validScores.length;
    return "Sleep score: ${averageScore.toStringAsFixed(1)}%";
  }
}

double calculateExerciseScore(HomeProvider provider, DateTime start, DateTime end, int age, bool ageInserted) {
  List<ExerciseData>? exerciseDataList = provider.exerciseData; // Ensure exerciseDataList is nullable
  Map<String, double>? weights;
  Map<String, int>? activityScores;
  double d = provider.exerciseDuration();
  int frequency = 0;
  double base = 0;
  if (exerciseDataList.isNotEmpty) {
    for (var data in exerciseDataList) {
      if (data.duration > 0) {
        frequency += 1;
      }
    }
  }

  if (ageInserted) {
    if (age < 17) {
      weights = {'duration': 0.2, 'distance': 0.3, 'frequency': 0.2, 'age': 0.3, 'activityType': 0.0};
      activityScores = {'Corsa': 8, 'Camminata': 6, 'Bici': 7, 'Nuoto': 9, 'Sport': 8};
      if (d > 60) {
        base = 40;
      }
      if (frequency > 3) {
        base += 5;
      }
    } else if (age <= 64) {
      weights = {'duration': 0.2, 'distance': 0.3, 'frequency': 0.2, 'age': 0.1, 'activityType': 0.2};
      activityScores = {'Corsa': 10, 'Camminata': 5, 'Bici': 7, 'Nuoto': 8, 'Sport': 7};
      if (d > 300) {
        base = 45;
      } else if (d > 180) {
        base = 40;
      } 
      if (frequency > 2) {
        base += 5;
      }
    } else {
      weights = {'duration': 0.2, 'distance': 0.2, 'frequency': 0.3, 'age': 0.2, 'activityType': 0.1};
      activityScores = {'Corsa': 7, 'Camminata': 8, 'Bici': 6, 'Nuoto': 9, 'Sport': 8};
      if (d > 150) {
        base = 40;
      }
      if (frequency > 3) {
        base += 5;
      }
    }
  } else {
    age = 25;
    weights = {'duration': 0.2, 'distance': 0.3, 'frequency': 0.2, 'age': 0.1, 'activityType': 0.2};
    activityScores = {'Corsa': 10, 'Camminata': 5, 'Bici': 7, 'Nuoto': 8, 'Sport': 7};
    if (d > 300) {
        base = 45;
      } else if (d > 180) {
        base = 40;
      } 
      if (frequency > 2) {
        base += 5;
      }
  }
  
  int ageScore = (10 - (age ~/ 10)).clamp(0, 10);
  double frequencyScore = (frequency) * (10 / 7); // Use null-aware operators to handle exerciseDataList being null
  //print("agescore $ageScore");
  //print("freqscore $frequencyScore");
  //print('frequency $frequency');

  double score = base + frequencyScore * (weights["frequency"] ?? 0) + ageScore * (weights["age"] ?? 0);

  if (exerciseDataList.isNotEmpty) {
    for (var data in exerciseDataList) {
      if (data.actNames.isNotEmpty) {
        for (var act in data.actNames) {
          if (data.activities.containsKey(act)) {
            double distanceWeight = (act == 'Bici') ? (weights["distance"] ?? 0 - 0.1) : (weights["distance"] ?? 0);
           score += (activityScores[act] ?? 0) +
                ((data.activities[act]![0]) ~/ 10) * (weights["duration"] ?? 0) * (activityScores[act] ?? 0) +
                ((data.activities[act]![1]) ~/ 10) * distanceWeight * (activityScores[act] ?? 0);
          }
        }
      }
    }
  }

  double final_score = double.parse(score.clamp(0, 100).toStringAsFixed(1));
  return final_score;
}

Widget getIconScore(double score) {
  if (score >= 75) {
    return Icon(Icons.sentiment_very_satisfied); // average score above 80
  } else if (score >= 45) {
    return Icon(Icons.sentiment_neutral); // average score between 60 and 80
  } else { 
    return Icon(Icons.sentiment_very_dissatisfied); // average score below 60
  }
}



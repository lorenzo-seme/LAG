import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/InfoRHR.dart';
import 'package:lag/screens/exerciseScreen.dart';
import 'package:lag/screens/infoScore.dart';
import 'package:lag/screens/moodScreen.dart';
import 'package:lag/screens/sleepScreen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class WeeklyRecap extends StatelessWidget {
  const WeeklyRecap({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, top: 10, bottom: 20),
              child: Consumer<HomeProvider>(builder: (context, provider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, ${provider.nick}!", 
                      style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 25),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 204, 149, 248),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(onTap: () async {
                                if(provider.isReady){
                                  await provider.dateSubtractor(provider.start);
                                  await provider.getDataOfWeek(provider.start, provider.end, false);
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
                          (provider.start.year == provider.end.year && provider.start.month == provider.end.month && provider.start.day == provider.end.day)
                          ? Text(DateFormat('EEE, d MMM').format(provider.start))
                          : Text('${DateFormat('EEE, d MMM').format(provider.start)} - ${DateFormat('EEE, d MMM').format(provider.end)}'),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (provider.end.year == provider.showDate.year && provider.end.month == provider.showDate.month && provider.end.day == provider.showDate.day) ?
                              const Icon(Icons.stop) :
                              InkWell(
                                onTap: () async {
                                  if(provider.isReady){
                                      await provider.dateAdder(provider.start);
                                      await provider.getDataOfWeek(provider.start, provider.end, false);
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
                        ]
                      ),
                    ),
                    Gamification(provider),
                    const Center(child: Text('Take care of yourself as you would take care of the plant', style: TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic),)),
                    const SizedBox(height: 10),
                    Container(
                      width: 370,
                      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 204, 149, 248),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      child: Column(
                        children: [
                          const Text("Your scores for the selected week",
                            style: TextStyle(fontSize: 19),
                          ), 
                          const SizedBox(height: 10),
                          Container(
                            width: 350, 
                            child: (provider.sleepData.isEmpty) 
                              ? const Card(
                                  elevation: 5,
                                  child: ListTile(
                                    leading: Icon(Icons.bedtime),
                                    trailing: CircularProgressIndicator.adaptive(),
                                    title: Text('Sleep score: loading...'), 
                                    subtitle: Text('    '),
                                  ),
                                )
                              : Card(
                                  elevation: 5,
                                  child: ListTile(
                                    leading: const Icon(Icons.bedtime),
                                    trailing: Container(
                                      child: getScoreIcon((provider.sleepScores)["scores"]!)
                                    ),
                                    title: 
                                      calculateAverageSleepScore((provider.sleepScores)["scores"]!) != null
                                      ? Text("Sleep score: ${calculateAverageSleepScore((provider.sleepScores)["scores"]!)!.toStringAsFixed(1)}%")
                                      : const Text("No sleep data available"),
                                    subtitle: const Text('about quality of your sleep this week',
                                                        style: TextStyle(fontSize: 11),),
                                    onTap: () => _toSleepPage(context, provider.start, provider.end, provider),
                                  ),
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              width: 350, 
                              child: (provider.sleepData.isEmpty) 
                              ? const Card(
                                  elevation: 5,
                                  child: ListTile(
                                    leading: Icon(Icons.directions_run),
                                    trailing: CircularProgressIndicator.adaptive(),
                                    title: Text('Exercise score: loading...'), 
                                    subtitle: Text('    '),
                                  ),
                                )
                              : Card(
                                elevation: 5,
                                child: ListTile(
                                  leading: const Icon(Icons.directions_run),
                                  trailing: Container(
                                    child: getIconScore(calculateAverageExerciseScore(provider.exerciseScores)),
                                    ),
                                  title: 
                                  calculateAverageExerciseScore(provider.exerciseScores) != 0
                                  ? Text('Exercise score: ${calculateAverageExerciseScore(provider.exerciseScores)}%')
                                  : const Text('No exercise data available'),
                                  subtitle: const Text('about your exercise activity of this week',
                                                      style: TextStyle(fontSize: 11),),
                                  onTap: () {
                                    bool current;
                                    if (getCurrentWeekIdentifier(provider.start) == getCurrentWeekIdentifier(DateTime.now())) {
                                      current = true;
                                    } else {
                                      current = false;
                                    }
                                    _toExercisePage(context, provider.start, provider.end, provider, getCurrentWeekIdentifier(provider.start), current);
                                  },
                                ),
                              ),
                            ), 
                        ],
                      )
                    ),
                    (DateTime.now().subtract(const Duration(days: 1)).year == provider.end.year && DateTime.now().subtract(const Duration(days: 1)).month == provider.end.month && DateTime.now().subtract(const Duration(days: 1)).day == provider.end.day)
                    ? Card(
                          elevation: 5,
                          child: ListTile(
                            leading: const Icon(Icons.wb_cloudy),
                            title: const Text("Today's mood"), 
                            subtitle: const Text("Track today's feeling to provide sun to your little plant!", style: TextStyle(fontSize: 11),),
                            onTap: () => _toMoodPage(context, provider),
                          ),
                      )
                    : const SizedBox(height: 10,),
                    const SizedBox(height: 20), 
                    const Text(
                      "Learn Something More",
                      style: TextStyle(fontSize: 22),
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
                                      onTap: () {
                                        if(provider.monthlyHeartRateData.length==1)
                                        {
                                          //fetch starts in background
                                          provider.fetchMonthlyHeartRateData(DateFormat("yyyy-MM-dd").format(provider.yesterday), false);
                                        }
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => InfoRHR(provider: provider,)));
                                      },
                                      child: Hero(
                                        tag: 'rhr',
                                        child: Container(
                                        width: 280,
                                        height: 180,
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
                                        "Check your heart rate at rest now!",
                                        style: TextStyle(fontSize: 16),
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
                                              builder: (_) => const InfoScore())),
                                      child: Hero(
                                        tag: 'score',
                                        child: Container(
                                        width: 280,
                                        height: 180,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15.0),
                                              bottomLeft: Radius.circular(15.0),
                                              bottomRight: Radius.circular(15.0),
                                              topRight: Radius.circular(15.0)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                                'assets/info_score.png'),
                                          ),
                                        ),
                                      ),),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "How do we calculate your score?",
                                        style: TextStyle(fontSize: 16),
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

  String getCurrentWeekIdentifier(DateTime dateToday) {
    DateTime firstDayOfYear = DateTime(dateToday.year, 1, 1);
    int daysDifference = dateToday.difference(firstDayOfYear).inDays;
    int weekNumber = (daysDifference / 7).ceil() + 1;
    return "$weekNumber";
  } //getCurrentWeekIdentifier
  
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

  // Method for navigation weeklyRecap -> moodScreen
  void _toMoodPage(BuildContext context, HomeProvider provider) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MoodScreen(provider: provider)));
  }
  
  Widget Gamification(HomeProvider provider) {

  final Map<int, String> fromIntToImg = {
    0: 'rew1.jpeg',
    1: 'rew1.jpeg',
    2: 'rew2.jpeg',
    3: 'rew3.jpeg',
    4: 'rew4.jpeg',
    5: 'rew5.jpeg',
    6: 'rew6.jpeg',
    7: 'rew7.jpeg',
    8: 'rew8.jpeg',
    9: 'rew9.jpeg',
    10: 'rew10.jpeg',
  };

  return SizedBox(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // First Column (left)
          Column(
            children: [
              ((provider.sleepScores)["scores"] != null)
                  ? CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 8,
                      center: Icon(
                        MdiIcons.wateringCan,
                        size: 35.0,
                        color: Colors.blue,
                      ),
                      progressColor: const Color(0xFF4e50bf),
                      animation: true,
                      animationDuration: 1000,
                      footer: const Text('Sleep', style: TextStyle(fontSize: 10)),
                      percent: calculateAverageSleepScore((provider.sleepScores)["scores"]!) != null
                          ? calculateAverageSleepScore((provider.sleepScores)["scores"]!)! / 100
                          : 0,
                      circularStrokeCap: CircularStrokeCap.round,
                    )
                  : const CircularProgressIndicator(),
              const SizedBox(height: 40),
              // ignore: unnecessary_null_comparison
              (provider.exerciseScores != null)
                  ? CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 8,
                      center:
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage('assets/fertilizer.png'),
                            ),
                          ),
                        ),
                      progressColor: const Color(0xFF4e50bf),
                      animation: true,
                      animationDuration: 1000,
                      footer: const Text('Exercise', style: TextStyle(fontSize: 10)),
                      percent: calculateAverageExerciseScore(provider.exerciseScores) / 100,
                      circularStrokeCap: CircularStrokeCap.round,
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
          
          // Spacer to push second column to center
          const Spacer(),

          // Second Column (center)
          Column(
              children: [
                // ignore: unnecessary_null_comparison
                ((provider.plantScore) != null)
                    ? Container(
                        width: 160,
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0),
                            topRight: Radius.circular(15.0)),
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage('assets/rewards2/${fromIntToImg[provider.plantScore.toInt()]}'),
                          ),
                        ),
                      )
                    : Container(
                        width: 160,
                        height: 260,
                        child: const CircularProgressIndicator(),
                    ),
                (provider.end.year == provider.showDate.year &&
                        provider.end.month == provider.showDate.month &&
                        provider.end.day == provider.showDate.day)
                    ? const Text("Still growing!")
                    : const Text("Your plant for that week"),
              ],
            ),
          
          // Spacer to push third column to the right
          const Spacer(),

          // Third Column (right)
          Column(
            children: [
              // ignore: unnecessary_null_comparison
              (provider.moodScores != null)
                  ? CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 8,
                      center: const Icon(Icons.sunny, size: 35, color: Color.fromARGB(255, 229, 211, 48),),
                      progressColor: const Color(0xFF4e50bf),
                      animation: true,
                      animationDuration: 1000,
                      footer: const Text('Mood', style: TextStyle(fontSize: 10)),
                      percent: calculateAverageMoodScore(provider.moodScores),
                      circularStrokeCap: CircularStrokeCap.round,
                  )
                : const CircularProgressIndicator(),
              const SizedBox(height: 40),
              // ignore: unnecessary_null_comparison
              (provider.plantScore !=null)
                ?  CircularPercentIndicator(
                    radius: 35,
                    lineWidth: 8,
                    center: Text('${(provider.plantScore/10*100).toInt()}%'),
                    progressColor: const Color(0xFF4e50bf),
                    animation: true,
                    animationDuration: 1000,
                    footer: const Text('Plant progress', style: TextStyle(fontSize: 10)),
                    percent: provider.plantScore / 10,
                    circularStrokeCap: CircularStrokeCap.round,
                  )
                : const CircularProgressIndicator(),
              ],
            ),
        ],
      ),
    ),
    );
  }
}


double? calculateAverageSleepScore(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return null; // if no valid scores
  } else {
    double averageScore = validScores.reduce((a, b) => a + b) / validScores.length;
    return averageScore;
  }
}

double calculateAverageExerciseScore(List<double> scores) {
  if (scores.isEmpty) {
    return 0;
  } else {
    double sum = scores.reduce((a, b) => a + b); // Sum all elements in the list
    double average = sum / scores.length;
    return double.parse(average.toStringAsFixed(2));
  }
}

double calculateAverageMoodScore(List<double> scores) {
  if (scores.isEmpty) {
    return 0;
  } else {
    double sum = scores.reduce((a, b) => a + b); // Sum all elements in the list
    double average = sum / scores.length;
    return double.parse(average.toStringAsFixed(2));
  }
}

Widget getIconScore(double score) {
  if (score == 0) {
    return const Icon(Icons.error);
  } else if (score >= 90) {
    return const Icon(Icons.sentiment_very_satisfied); 
  } else if (score >= 80) {
    return const Icon(Icons.sentiment_satisfied); 
  } else if (score >= 70) {
    return const Icon(Icons.sentiment_neutral); 
  } else if (score >= 60) {
    return const Icon(Icons.sentiment_dissatisfied); 
  } else {
    return const Icon(Icons.sentiment_very_dissatisfied); 
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
//import 'package:lag/algorithms/sleepScore.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/InfoRHR.dart';
import 'package:lag/screens/exerciseScreen.dart';
import 'package:lag/screens/infoExercise.dart';
import 'package:lag/screens/infoSleep.dart';
import 'package:lag/screens/moodScreen.dart';
import 'package:lag/screens/rhrScreen.dart';
import 'package:lag/screens/sleepScreen.dart';
import 'package:provider/provider.dart';
//import 'dart:async';


// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class WeeklyRecap extends StatelessWidget {
  const WeeklyRecap({super.key});

  String getCurrentWeekIdentifier(DateTime dateToday) {
    DateTime firstDayOfYear = DateTime(dateToday.year, 1, 1);
    int daysDifference = dateToday.difference(firstDayOfYear).inDays;
    int weekNumber = (daysDifference / 7).ceil() + 1;
    return "$weekNumber";
}

  //Future<double> sleepAvg = calculateAverageSleepScore(BuildContext context, Future<List<double>> sleepDataFuture); 


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
                    const Text('Personal Recap',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
                    
                    Container(
                      //height: 600,
                      width: 370,
                      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 248, 226, 226),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      child: Column(children: [

                        (DateTime.now().subtract(const Duration(days: 1)).year == provider.end.year && DateTime.now().subtract(const Duration(days: 1)).month == provider.end.month && DateTime.now().subtract(const Duration(days: 1)).day == provider.end.day)
                        ? Card(
                          elevation: 5,
                          child: ListTile(
                            leading: const Icon(Icons.wb_cloudy),
                            /*
                            trailing: Container(
                              child: getScoreIcon((provider.sleepScores)["scores"]!) // funzione definita in sleepScreen
                            ),
                            */
                            title: Text("Today mood"), 
                            //subtitle: const Text('about quality of your sleep this week', style: TextStyle(fontSize: 11),),
                            onTap: () => _toMoodPage(context, provider.start, provider.end, provider),
                          ),
                          )
                        : const SizedBox(height: 10),

                        const Text("Weekly Trends for sleep and exercise",
                          style: TextStyle(fontSize: 19),
                        ), 
                        const SizedBox(height: 10),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 250, 196, 196),
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
                            ]
                          ),
                        ),
                        

                        //const SizedBox(height: 5),
                        /*
                        const Text("See how much you’ve been striving throughout the week",
                            style: TextStyle(fontSize: 12,color: Colors.black45),
                            ),*/
                        const SizedBox(height: 10),
                        //const Text('Sleep Data'),
                        Container(
                          width: 350, 
                          //height: 80,
                          child: (provider.sleepData.isEmpty) 
                            ? const Card(
                                elevation: 5,
                                child: ListTile(
                                  leading: Icon(Icons.bedtime),
                                  trailing: CircularProgressIndicator.adaptive(),
                                  title: Text('Loading...'), 
                                  subtitle: Text('    '),
                                ),
                              )
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
                          ),
                          const SizedBox(height: 10,),
                          //Text('Exercise Data'),
                          Container(
                            width: 350, 
                            //height: 90,
                            child: (provider.exerciseData.isEmpty) 
                              ? const Card(
                                  elevation: 5,
                                  child: ListTile(
                                    leading: Icon(Icons.directions_run),
                                    trailing: CircularProgressIndicator.adaptive(),
                                    title: Text('Loading...'), 
                                    subtitle: Text('    '),
                                  ),
                              )
                              : Card(
                                  elevation: 5,
                                  child: ListTile(
                                    leading: Icon(Icons.directions_run),
                                    trailing: Container(
                                      child: (provider.exerciseDuration()>=30*7) ? const Icon(Icons.thumb_up) : const Icon(Icons.thumb_down),), //qui mettere la media della settimana al posto del solo primo giorno
                                    title: Text('Exercise : ${provider.exerciseDuration()} minutes'),
                                    subtitle: Text('Total minutes of exercise performed this week'),
                                              //When a ListTile is tapped, the user is redirected to the ExercisePage
                                    onTap: () => _toExercisePage(context, provider.start, provider.end, provider, getCurrentWeekIdentifier(provider.start)),
                                            ),
                              ),
                          ),
                          const SizedBox(height: 10),

                          const Text("Cumulative Score", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 5),
                          const Text("Descriptive index of the quality of your week",
                              style: TextStyle(fontSize: 12,color: Colors.black45),
                              ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10, bottom: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                      color: Color.fromARGB(255, 255, 115, 115),
                                      value: provider.score / 100,
                                      backgroundColor: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    const SizedBox(height: 15),
                    Container(
                      //height: 150,
                      width: 370,
                      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 248, 226, 226),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      child: Column(children: [
                        const Text("Explore Monthly Trends for resting heart rate",
                          style: TextStyle(fontSize: 16),
                        ), 
                        const SizedBox(height: 10), 
                        (provider.heartRateData.isEmpty) 
                          ? const CircularProgressIndicator.adaptive() 
                          :
                          Card(
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(Icons.monitor_heart),
                              trailing: SizedBox(
                                width: 10,
                                child: ((provider.rhrAvg() > 80.0) | (provider.rhrAvg() < 55.0)) ? Icon(Icons.thumb_down) : Icon(Icons.thumb_up),
                                ), 
                              title: Text('Resting heart rate : ${provider.rhrAvg()} bpm'),
                              subtitle: Text('Average of current month'),
                                        //When a ListTile is tapped, the user is redirected to the ExercisePage
                              onTap: () async {
                                  ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.blue,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(8),
                                        duration: Duration(seconds: 10),
                                        content: Text(
                                            "Be patient.. We're loading your data!"),
                                      ),
                                    );
                                  await provider.fetchMonthlyHeartRateData(DateFormat("yyyy-MM-dd").format(provider.yesterday));
                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => RhrScreen(provider: provider)
                                    ));
                                }
                              ),
                            ),
                      ],),
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
  void _toExercisePage(BuildContext context, DateTime start, DateTime end, HomeProvider provider, String week) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ExerciseScreen(startDate: start, endDate: end, provider: provider, week: week)));



































  }
  
  void _toMoodPage(BuildContext context, DateTime start, DateTime end, HomeProvider provider) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MoodScreen(startDate: start, endDate: end, provider: provider)));
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
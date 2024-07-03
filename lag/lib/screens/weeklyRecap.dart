import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/algorithms/exercise_score.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/algorithms/exercise_score.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/InfoRHR.dart';
import 'package:lag/screens/exerciseScreen.dart';
import 'package:lag/screens/infoScore.dart';
import 'package:lag/screens/moodScreen.dart';
import 'package:lag/screens/sleepScreen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
                    Text("Hello, ${provider.nick}!",style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    //const Text('Personal Recap',style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
                    Gamification(provider),
                    const SizedBox(height: 15),
                    (DateTime.now().subtract(const Duration(days: 1)).year == provider.end.year && DateTime.now().subtract(const Duration(days: 1)).month == provider.end.month && DateTime.now().subtract(const Duration(days: 1)).day == provider.end.day)
                        ? Card(
                          elevation: 5,
                          color: Color.fromARGB(255, 243, 232, 251),
                          child: ListTile(
                            leading: const Icon(Icons.wb_cloudy),
                            /*
                            trailing: Container(
                              child: getScoreIcon((provider.sleepScores)["scores"]!) // funzione definita in sleepScreen
                            ),
                            */
                            title: Text("Today's mood"), 
                            subtitle: const Text("Track today's feeling to provide sun to your little plant!", style: TextStyle(fontSize: 11),),
                            onTap: () => _toMoodPage(context, provider),
                          ),
                          )
                        : const SizedBox(height: 10),
                    
                    Container(
                      //height: 600,
                      width: 370,
                      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 239, 226, 250),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      child: Column(children: [
                        const Text("Weekly Trends for sleep and exercise",
                          style: TextStyle(fontSize: 19),
                        ), 
                        const SizedBox(height: 10),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 215, 188, 255),
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
                                  title: 
                                    calculateAverageSleepScore((provider.sleepScores)["scores"]!) != null
                                    ? Text("Sleep score: ${calculateAverageSleepScore((provider.sleepScores)["scores"]!)!.toStringAsFixed(1)}%")
                                    : Text("No data available"), // funzione definita sotto
                                  subtitle: const Text('about quality of your sleep this week',
                                                      style: TextStyle(fontSize: 11),),
                                  onTap: () => _toSleepPage(context, provider.start, provider.end, provider),
                                ),
                            ),
                          ),
                          const SizedBox(height: 10,),
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
                      leading: Icon(Icons.directions_run),
                      trailing: Container(
                        child: getIconScore(calculateAverageExerciseScore(provider.exerciseData, provider.age, provider.ageInserted) as double),
                        ),
                      title: Text('Exercise score: ${calculateAverageExerciseScore(provider.exerciseData, provider.age, provider.ageInserted)}%'),
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
                                  (computeScore(provider).toInt()).toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(computeScore(provider) / 100 < 0.33
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
                                      color: Color.fromARGB(255, 138, 2, 250),
                                      value: computeScore(provider) / 100,
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
                                          //faccio partire il fetch in background
                                          provider.fetchMonthlyHeartRateData(DateFormat("yyyy-MM-dd").format(provider.yesterday), false);
                                        }
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => InfoRHR(provider: provider,)));
                                      },
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
                                              builder: (_) => InfoScore())),
                                      child: Hero(
                                        tag: 'score',
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
  
  void _toMoodPage(BuildContext context, HomeProvider provider) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MoodScreen(provider: provider)));
  }
  
  // OCCHIO CHE VORREBBE COSTRUIRE PRIMA CHE I DATI SIANO STATI FETCHATI !!!
  Widget Gamification(HomeProvider provider) {
  /*final Map<int, String> fromIntToImg = {
    1: 'reward_1.png',
    2: 'reward_1.png',
    3: 'reward_2.png',
    4: 'reward_3.png',
    5: 'reward_4.png',
    6: 'reward_5.png',
    7: 'reward_6.png',
    8: 'reward_7.png',
    9: 'reward_8.png',
    10: 'reward_9.png',
    11: 'reward_10.png',
    12: 'reward_11.png',
    13: 'reward_12.png',
    14: 'reward_12.png'
  };*/

  final Map<int, String> fromIntToImg = {
    1: 'rew1.jpeg',
    2: 'rew1.jpeg',
    3: 'rew2.jpeg',
    4: 'rew2.jpeg',
    5: 'rew3.jpeg',
    6: 'rew4.jpeg',
    7: 'rew5.jpeg',
    8: 'rew6.jpeg',
    9: 'rew7.jpeg',
    10: 'rew8.jpeg',
    11: 'rew9.jpeg',
    12: 'rew9.jpeg',
    13: 'rew10.jpeg',
    14: 'rew10.jpeg'
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
                        size: 35.0, // Dimensione dell'icona
                        color: Colors.blue, // Colore dell'icona
                      ), // QUI L'IMMAGINE DELL'INNAFFIATORE
                      progressColor: const Color(0xFF4e50bf),
                      animation: true,
                      animationDuration: 1000,
                      footer: Text('Sleep', style: TextStyle(fontSize: 10)),
                      percent: calculateAverageSleepScore((provider.sleepScores)["scores"]!) != null
                          ? calculateAverageSleepScore((provider.sleepScores)["scores"]!)! / 100
                          : 0, // PENSA A COME GESTIRE IL CASO IN CUI NON CI SIANO DATI
                      circularStrokeCap: CircularStrokeCap.round,
                    )
                  : CircularProgressIndicator(),
              const SizedBox(height: 40),
              ((provider.sleepScores)["scores"] != null)
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
                              image: AssetImage('assets/shovel.png'),
                            ),
                          ),
                        ),
                      progressColor: const Color(0xFF4e50bf),
                      animation: true,
                      animationDuration: 1000,
                      footer: Text('Sleep', style: TextStyle(fontSize: 10)),
                      percent: calculateAverageSleepScore((provider.sleepScores)["scores"]!) != null
                          ? calculateAverageSleepScore((provider.sleepScores)["scores"]!)! / 100
                          : 0, // PENSA A COME GESTIRE IL CASO IN CUI NON CI SIANO DATI
                      circularStrokeCap: CircularStrokeCap.round,
                    )
                  : CircularProgressIndicator(),
            ],
          ),
          
          // Spacer to push second column to center
          Spacer(),

          // Second Column (center)
          Column(
            children: [
              ((provider.sleepScores)["scores"] != null)
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
                          image: AssetImage('assets/rewards2/${fromIntToImg[imageToShow(provider.sleepScores["scores"]!)]}'),
                        ),
                      ),
                    )
                  : CircularProgressIndicator(),
              (provider.end.year == provider.showDate.year &&
                      provider.end.month == provider.showDate.month &&
                      provider.end.day == provider.showDate.day)
                  ? Text("Still growing!")
                  : Text("Your plant for that week"), // cambia questa frase
            ],
          ),
          
          // Spacer to push third column to the right
          Spacer(),

          // Third Column (right)
          Column(
            children: [
              ((provider.sleepScores)["scores"] != null)
                  ? CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 8,
                      center: const Icon(Icons.sunny, size: 35, color: Color.fromARGB(255, 229, 211, 48),),
                      progressColor: const Color(0xFF4e50bf),
                      animation: true,
                      animationDuration: 1000,
                      footer: Text('Mood', style: TextStyle(fontSize: 10)),
                      percent: percentageSun(provider),
                      circularStrokeCap: CircularStrokeCap.round,
                    //widgetIndicator: _reachedGoal(),
                  )
                : CircularProgressIndicator(),
                const SizedBox(height: 40),
                ((provider.sleepScores)["scores"]!=null)
                ?  CircularPercentIndicator(
                    radius: 35,
                    lineWidth: 8,
                    center: null, // QUI L'IMMAGINE DELL'INNAFFIATORE
                    progressColor: const Color(0xFF4e50bf),
                    animation: true,
                    animationDuration: 1000,
                    footer: Text('Sleep', style: TextStyle(fontSize: 10)),
                    percent: calculateAverageSleepScore((provider.sleepScores)["scores"]!) != null
                      ? calculateAverageSleepScore((provider.sleepScores)["scores"]!)!/100
                      : 0, // PENSA A COME GESTIRE IL CASO IN CUI NON CI SIANO DATI
                    circularStrokeCap: CircularStrokeCap.round,
                    //widgetIndicator: _reachedGoal(),
                  )
                : CircularProgressIndicator(),
              ],
            ),
          ],
      ),
    ),
    );
  }

  int imageToShow(List<double> scores){
    int ind = 0;
    for (double value in scores) {
      if (value > 90) {
        ind = ind + 2;
      } else if (value < 80) {
      } 
      else {
        ind++;
      }
    }
    return ind;
  }
  
  double percentageSun(HomeProvider provider) {
    if (provider.todayMoodTracked) {
      return 0.5;
    } else if (provider.firstThoughtsubmitted) {
      return 1;
    } else {
      return 0;
    }
  }

}



/*
String calculateAverageSleepScoreString(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return "No data available"; // if no valid scores
  } else {
    double averageScore = validScores.reduce((a, b) => a + b) / validScores.length;
    return "Sleep score: ${averageScore.toStringAsFixed(1)}%";
  }
}*/
double? calculateAverageSleepScore(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return null; // if no valid scores
  } else {
    double averageScore = validScores.reduce((a, b) => a + b) / validScores.length;
    return averageScore;
  }
}

double calculateAverageExerciseScore(List<ExerciseData> exerciseData, int age, bool ageInserted) {
  List<double> scores = calculateExerciseScore(exerciseData, age, ageInserted).map((score) => score.toDouble()).toList(); 
  if (scores.isEmpty) {
    return 0;
  } else {
    double sum = scores.reduce((a, b) => a + b); // Sum all elements in the list
    double average = sum / scores.length;
    return double.parse(average.toStringAsFixed(2));
  }
}

Widget getIconScore(double score) {
  if (score >= 75) {
    return Icon(Icons.sentiment_very_satisfied); 
  } else if (score >= 45) {
    return Icon(Icons.sentiment_neutral); 
  } else { 
    return Icon(Icons.sentiment_very_dissatisfied); 
  }
}

double computeScore(HomeProvider provider) {
  List<ExerciseData> exerciseData = provider.exerciseData;
  double sleepScore;
  double exerciseScore; 
  double totalScore;

  // Ensure the sleepScores list is non-null before passing it to the function
  List<double> sleepScores = (provider.sleepScores["scores"] ?? []).cast<double>();

  sleepScore = calculateAverageSleepScore(sleepScores) ?? 0.0;
  exerciseScore = calculateAverageExerciseScore(exerciseData, provider.age, provider.ageInserted);
  totalScore = ((sleepScore + exerciseScore) / 2);

  return totalScore;
}






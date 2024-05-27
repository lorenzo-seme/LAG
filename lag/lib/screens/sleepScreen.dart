import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/algorithms/sleepScore.dart';
import 'package:lag/models/sleepdata.dart';
//import 'package:lag/models/heartratedata.dart';
import 'package:lag/providers/homeProvider.dart';
// import 'package:lag/utils/custom_plot.dart';
import 'package:provider/provider.dart';

// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class SleepScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SleepScreen({super.key, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Data', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();},
          ),
        ),
      
      body: SafeArea(
        child: ChangeNotifierProvider(
      create: (context) => HomeProvider(), // homeprovider is the class implementing the change notifier
      builder: (context, child) => Padding(
        padding:
            const EdgeInsets.only(left: 12.0, right: 12.0, top: 10, bottom: 20),
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text('${DateFormat('EEE, d MMM').format(startDate)} - ${DateFormat('EEE, d MMM').format(endDate)}'),
              const SizedBox(height: 5),
              
              const Text("PLOT DAYS VS SCORE",style: TextStyle(fontSize: 32)),
              
              // qui crea un qualcosa che prelevi dalla lista provider.sleepData della settimana i vari parametri di ogni giorno e faccia le media
              //getSleepScore(context, provider.sleepData);
              //provider.sleepData.minutesAsleep;
              

              const SizedBox(height: 10,),
              Text("Explore each quantity on average", style: TextStyle(fontSize: 12.0)),
              (provider.sleepData.isEmpty) ? const CircularProgressIndicator.adaptive() :
                Card(
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.hotel),
                    
                    /*
                    trailing: Container(width: 10,
                      child: getSleepScoreIcon((getSleepScore(context, provider.sleepData)),"scores")),
                      //child: Icon(Icons.sentiment_neutral)),
                    */
                    trailing: Container(
                      width: 10,
                      child: FutureBuilder<Widget>(
                        future: getSleepScoreIcon(getSleepScore(context, provider.sleepData), "scores"),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Icon(Icons.error_outline);
                          } else {
                            return snapshot.data ?? SizedBox(); // Restituisci il widget ottenuto, oppure un widget vuoto
                          }
                        },
                      ),
                    ),
                    title:
                        Text(
                          calculateAverageSleepMinutes(provider.sleepData) == null
                              ? "No data available"
                              : "${double.parse((calculateAverageSleepMinutes(provider.sleepData)! / 60).toStringAsFixed(1))} hours slept",
                          style: TextStyle(fontSize: 14.0),
                        ),
                    subtitle: Text('Tap to learn more',
                    style: TextStyle(fontSize: 10.0)),
                    //onTap: () => _toExercisePage(context),
                  ),
                  ),
                  Text("1. MI SA CHE NON STA AGGIORNANDO I DATI, MOSTRA SEMPRE 7.2 ORE DI DORMITA \n 2. SCORES VA MA NON L'ALTRA CHIVE"),
              

            ],
          );
        }),
      ),
    ))
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
  if (count == 0) {return null;} // Handles the case where all entries are null (no data available)
  double average = sum / count;
  return average;
}

//enum SleepScoreIcon { poor, average, good }

/*
Object getSleepScoreIcon(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return Icons.error_outline; // if no valid scores
  }
  double averageScore = validScores.reduce((a, b) => a + b) / validScores.length; 
  if (averageScore >= 80) {
    return SleepScoreIcon.good; // average score above 80
  } else if (averageScore >= 60) {
    return SleepScoreIcon.average; // average score between 60 and 80
  } else {
    return SleepScoreIcon.poor; // average score below 60
  }
}
*/

/*
Widget getSleepScoreIcon(List<double> scores) {
  List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
  if (validScores.isEmpty) {
    return Icon(Icons.error); // if no valid scores
  }
  double averageScore = validScores.reduce((a, b) => a + b) / validScores.length; 
  if (averageScore >= 80) {
    return Icon(Icons.sentiment_satisfied); // average score above 80
  } else if (averageScore >= 60) {
    return Icon(Icons.sentiment_neutral); // average score between 60 and 80
  } else {
    return Icon(Icons.sentiment_dissatisfied); // average score below 60
  }
}
*/

/*
Widget? getSleepScoreIcon(Future<Map<String, List<double>>> futureScore, String key) {
  futureScore.then((Map<String, List<double>> data) {
    List<double> scores = data[key]!;
    print("$scores");
    List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
    print("$validScores");
    if (validScores.isEmpty) {
      print("1");
      return const Icon(Icons.error); // if no valid score
    }
    double averageScore = validScores.reduce((a, b) => a + b) / validScores.length; 
    if (averageScore >= 80) {
      print("2");
      return const Icon(Icons.sentiment_satisfied); // average score above 80
    } else if (averageScore >= 60) {
      print("3");
      return const Icon(Icons.sentiment_neutral); // average score between 60 and 80
    } else {
      print("4");
      return const Icon(Icons.sentiment_dissatisfied); // average score below 60
    }
  });
  return const Icon(Icons.battery_full);
}
*/

Future<Widget> getSleepScoreIcon(Future<Map<String, List<double>>> futureScore, String key) async {
  try {
    Map<String, List<double>> data = await futureScore;
    List<double> scores = data[key]!;
    List<double> validScores = scores.where((score) => score >= 0).toList(); // to not consider scores=-1 (days without sleep data)
    if (validScores.isEmpty) {
      return Icon(Icons.error); // if no valid score
    }
    double averageScore = validScores.reduce((a, b) => a + b) / validScores.length; 
    if (averageScore >= 80) {
      return Icon(Icons.sentiment_satisfied); // average score above 80
    } else if (averageScore >= 60) {
      return Icon(Icons.sentiment_neutral); // average score between 60 and 80
    } else {
      return Icon(Icons.sentiment_dissatisfied); // average score below 60
    }
  } catch (error) {
    // Gestione degli errori, ad esempio restituire un'icona di errore
    return Icon(Icons.error_outline);
  }
}

/*
Widget getSleepScoreIcon(Future<Map<String, List<double>>?> sleepScoreFuture) {
  return FutureBuilder<Map<String, List<double>>?>(
    future: sleepScoreFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(); 
      } else if (snapshot.hasError) {
        return Icon(Icons.error); 
      } else {
        List<double>? scores = snapshot.data?['sleepHoursScores']; 
        if (scores!.isNotEmpty) {
          //double averageScore = calculateAverage(scores);
          double averageScore = scores.reduce((a, b) => a + b) / scores.length; 
          if (averageScore >= 80) {
            return Icon(Icons.sentiment_satisfied);
          } else if (averageScore >=60) {
            return Icon(Icons.sentiment_neutral);
          } else {
            return Icon(Icons.sentiment_dissatisfied);
          }
        } else {
          return Icon(Icons.warning); // no data available
        }
      }
    },
  );
}
*/

/*
Widget getSleepScoreIcon(Future<Map<String, List<double>>?> sleepScoreFuture) {
  return FutureBuilder<Map<String, List<double>>?>(
    future: sleepScoreFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Icon(Icons.error);
      } else {
        Map<String, List<double>>? data = snapshot.data; // Aggiungere ? per indicare che il valore potrebbe essere null
        if (data != null) { // Verifica se data non è null
          List<double>? scores = data['scores'];
          if (scores!.isNotEmpty) {
          //double averageScore = calculateAverage(scores);
          double averageScore = scores.reduce((a, b) => a + b) / scores.length; 
          if (averageScore >= 80) {
            return Icon(Icons.sentiment_satisfied);
          } else if (averageScore >=60) {
            return Icon(Icons.sentiment_neutral);
          } else {
            return Icon(Icons.sentiment_dissatisfied);
          }
        } else {
          return Icon(Icons.warning); // no data available
        }
          }
        }
        // Se snapshot.data o scores sono null, oppure scores è vuoto
        return Icon(Icons.warning);
      }
    );
}*/
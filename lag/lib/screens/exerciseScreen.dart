import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/rhrScreen.dart';
import 'package:lag/utils/barplotEx.dart';
//import 'package:lag/screens/rhrScreen.dart';
//import 'package:lag/models/heartratedata.dart';
//import 'package:lag/utils/custom_plot.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lag/screens/survey.dart';
import 'package:shared_preferences/shared_preferences.dart';

// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class ExerciseScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;

  const ExerciseScreen(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.provider});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool _buttonClickedToday = false;

  @override
  void initState() {
    super.initState();
    _checkButtonStatus();
  }

  Future<void> _checkButtonStatus() async {
    final sp = await SharedPreferences.getInstance();
    final lastClickedDate = sp.getString('lastClickedDate');

    if (lastClickedDate != null) {
      final lastClicked = DateTime.parse(lastClickedDate);
      final now = DateTime.now();

      if (_isSameDay(lastClicked, now)) {
        setState(() {
          _buttonClickedToday = true;
        });
      }
    }
  }

  Future<void> _onButtonClick() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastClickedDate', now.toIso8601String());

    setState(() {
      _buttonClickedToday = true;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    //String dataCheckMessage = checkData(widget.provider.exerciseData);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.run_circle_outlined),
            const SizedBox(width: 10),
            (widget.provider.start.year == widget.provider.end.year &&
                    widget.provider.start.month == widget.provider.end.month &&
                    widget.provider.start.day == widget.provider.end.day)
                ? Text(DateFormat('EEE, d MMM').format(widget.provider.start),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold))
                : Text(
                    '${DateFormat('EEE, d MMM').format(widget.provider.start)} - ${DateFormat('EEE, d MMM').format(widget.provider.end)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color.fromARGB(255, 227, 211, 244),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 12.0, right: 12.0, top: 10, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text('How much did you work out everyday during this week?',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                const Text('Tap on bars to discover more details',
                    style: TextStyle(fontSize: 10,
                    color: Color.fromARGB(202, 97, 20, 169))),
                    /*
                  SizedBox(
                    height: 230,
                    width: 330,
                    child: _buildBarPlot(widget.provider.exerciseData)),
                    */

                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: widget.provider.exerciseData.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildBarPlot(widget.provider.exerciseData),  // input = list with exData every day of the week
                        ),
                ),
                Card(
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.run_circle_outlined),
                    tileColor: const Color.fromARGB(255, 227, 211, 244),
                    title: Text("Set a goal!"),
                    subtitle:
                        Text('Find a good motivation to move your ass :)'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    iconColor: Color.fromARGB(255, 131, 35, 233),
                    hoverColor: const Color.fromARGB(255, 227, 211, 244),
                    onTap: () => (),   // ---------------------------------------> QUA DA SETTARE GOAL
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 15,
                        center: Text(
                          "${(0.8 * 100).toStringAsFixed(0)}%", //// DA METTERE PROGRESSOR
                          style: TextStyle(fontSize: 20),
                        ),
                        progressColor: const Color.fromARGB(255, 7, 181, 255),
                        animation: true,
                        animationDuration: 2000,
                        footer: new Text(
                          'How close you are',
                          style: TextStyle(
                              fontSize: 15,
                              color: const Color.fromARGB(255, 0, 83, 121)),
                        ),
                        percent: 0.8,

                        /// PROGRESS HERE
                        circularStrokeCap: CircularStrokeCap.round,
                      ),

                      // LATERAL TEXT
                      const SizedBox(width: 20),
                      Expanded(child: Text("You're doing great"))
                    ],
                  ),
                ),

                // SURVEY
                const SizedBox(height: 30),
                Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text('Survey of the day'), // funzione definita sotto
                    subtitle: const Text(
                      'Tell me about your activity',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                    if (_buttonClickedToday == false) {
                      _onButtonClick();
                      showDialog(
                        // si apre il pop-up
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor:const Color.fromARGB(255, 242, 239, 245),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CardDialog(),
                                Positioned(
                                  // bottone per chiudere
                                  top: 0,
                                  right: 0,
                                  //height: 28,
                                  //width: 28,
                                  child: OutlinedButton(
                                    child: Icon(Icons.close_rounded, color: Color.fromARGB(255, 227, 211, 244)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(6),
                                      shape: const CircleBorder(),
                                      backgroundColor: Color.fromARGB(255, 183, 123, 248),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    },
                  ),
                ),
                Center(
                      child: ElevatedButton(
                        child: Text('Temporary button, to RHR screen'),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RhrScreen(startDate: widget.provider.start, endDate: widget.provider.end, provider: widget.provider))),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }

    _buildBarPlot(List<ExerciseData> exerciseDataList) {  
    //List<double> hoursList = [];
    List<double> minOfEx = [];
    List<PieChart?> pieList = [];   // ------------------------> da implementare
    List<String?> legend = [];
    for (ExerciseData data in exerciseDataList) {  // per ogni giorno
      //hoursList.add(data.duration/60);
      minOfEx.add((data.duration));
      pieList.add(_buildPieChart([data], true));  // in _builPieChart insert ExerciseData 
      legend.add("Run: ${((calculatePercentage([data])!)["Corsa"]!).toStringAsFixed(1)}% \nBike: ${((calculatePercentage([data])!)["Bici"]!).toStringAsFixed(1)}% \nWalk: ${((calculatePercentage([data])!)["Camminata"]!).toStringAsFixed(1)}%");
        }
    while (minOfEx.length < 7) {
      //hoursList.add(0);
      minOfEx.add(0);
      pieList.add(null);
      legend.add(null);
    }
    return BarChartSample7(yValues: minOfEx, pieCharts: pieList, legend: legend);    
  }
  

Map<String, double>? calculatePercentage(List<ExerciseData> exerciseDataList) { 
  double totalRun = 0;
  double totalBike = 0;
  double totalWalking = 0;
  double total = 0;
  if (exerciseDataList.length > 1) {
    for (var data in exerciseDataList) {
    totalRun += data.activities["Corsa"]![0];
    totalBike += data.activities["Bici"]![0];
    totalWalking += data.activities["Camminata"]![0];
    }
    total = totalRun + totalWalking + totalBike;
  } else {
    totalRun = exerciseDataList[0].activities["Corsa"]![0];
    totalBike = exerciseDataList[0].activities["Bici"]![0];
    totalWalking = exerciseDataList[0].activities["Camminata"]![0];
    total = totalRun + totalWalking + totalBike;
    }

  Map<String, double> percentages = {
      "Corsa" : (totalRun / total) * 100,
      "Bici" : (totalBike / total) * 100,
      "Camminata" : (totalWalking / total) * 100
    };
    return percentages;
}

PieChart _buildPieChart(List<ExerciseData> exerciseData, bool _isPhasesCardExpanded) {   // ------> dove viene inizializzata la bool 
  double radius = 30;
  bool title = false;  
  (_isPhasesCardExpanded) ? radius=75 : radius=30;
  (_isPhasesCardExpanded) ? title=true : title=false;
  return PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: (calculatePercentage(exerciseData)!)["Corsa"],
                  color: const Color(0xFF8A2BE2), // Viola scuro per Deep Sleep
                  title: "Run", titlePositionPercentageOffset: 0.7, titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  showTitle: title,
                  radius: radius,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(exerciseData)!)["Bici"],
                  color: const Color(0xFFBA55D3), // Viola medio per REM Sleep
                  title: "Bike", titlePositionPercentageOffset: 0.7, titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  showTitle: title,
                  radius: radius,
                ),
                PieChartSectionData(
                  value: (calculatePercentage(exerciseData)!)["Camminata"],
                  color: const Color(0xFF9370DB), // Viola chiaro per Light Sleep
                  title: "Walking", titlePositionPercentageOffset: 0.7, titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  showTitle: title,
                  radius: radius,
                ),
              ],
              centerSpaceColor: Colors.transparent,
              centerSpaceRadius: 0.01,
              sectionsSpace: 2, // Rimuove lo spazio tra le sezioni
              // Altre opzioni come angolo di inizio, ecc.
            ),
          );
}















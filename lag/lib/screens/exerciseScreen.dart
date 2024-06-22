import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/rhrScreen.dart';
import 'package:lag/utils/barplotEx.dart';
//import 'package:lag/screens/rhrScreen.dart';
//import 'package:lag/models/heartratedata.dart';
//import 'package:lag/utils/custom_plot.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lag/screens/cardDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;
  final String week;

  const ExerciseScreen(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.provider,
      required this.week});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool _buttonClickedToday = false;
  double _threshold = 0;
  double _currentScore = 0;
  double _percentage = 0;
  String _level = '';
  bool _reachGoal = false;
  int _fullLaps = 0;
  bool _goalDisable = false;

  @override
  void initState() {
    super.initState();
    _loadPercentage();
    _checkButtonStatus();
    _Goal();
  }

  Future<void> _checkButtonStatus() async {
    final sp = await SharedPreferences.getInstance();
    final lastClickedDate = sp.getString('lastClickedDate');

    if (lastClickedDate != null) {
      final lastClicked = DateTime.parse(lastClickedDate);
      final now = DateTime.now();

      if (_isSameDay(lastClicked, now)) {
        setState(
          () {
            _buttonClickedToday = true;
            showDialog(
              context: context,
              builder: (context) {
                return const SimpleDialog(
                    contentPadding: EdgeInsets.all(10),
                    title: Text('Oh no!'),
                    children: [
                      Text(
                          'You have already done the survey for today, see you tommorow :)'),
                      SizedBox(height: 10),
                    ]);
              },
            );
          },
        );
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

  _loadPercentage() async {
    //String currentWeekKey = 'percentage_${_getCurrentWeekIdentifier()}';
    final sp = await SharedPreferences.getInstance();
    try {
      double savedPercentage = sp.getDouble(widget.week) ?? 0.0;
      setState(() {
        _percentage = savedPercentage;
      });
    } catch (e) {
      print('Error loading percentage: $e');
    }
  }

  _Goal() async {
    final sp = await SharedPreferences.getInstance();
    String level = sp.getString('level_${widget.week}') ?? '';
    bool goal = sp.getBool('goal_${widget.week}') ?? false;
    setState(() {
      _level = level;
      _goalDisable = goal;
    });
  }

  String _getCurrentWeekIdentifier() {
    DateTime date = widget.startDate;
    print('now $date');
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    print('first of the year $firstDayOfYear');
    int daysDifference = date.difference(firstDayOfYear).inDays;
    print('differenze $daysDifference');
    int weekNumber = (daysDifference / 7).ceil() + 1;
    return "$weekNumber";
  }

  _setGoal(String level) async {
    double wRun = 0.5;
    double wBike = 0.4;
    double wWalk = 0.1;
    Map<String, double> distances = widget.provider.exerciseDistance2();
    double runDistance = distances['Corsa'] ?? 0;
    double bikeDistance = distances['Bici'] ?? 0;
    double walkDistance = distances['Camminata'] ?? 0;
    Map<String, double> thresholds = {
      'Lazy': 50.5,
      'Medium': 110,
      'Hard': 150.5
    };
    setState(() {
      _level = level;
      _threshold = thresholds[level]!;
      _currentScore =
          wRun * runDistance + wBike * bikeDistance + wWalk * walkDistance;
      if (_currentScore / _threshold >= 1) {
        _reachGoal = true;
        //_upDateGoal(); // -------------> questo da rimuovere se voglio chiedere di andare avanti
      } else {
        _percentage = _currentScore / _threshold;
      }
      //print(_currentScore / _threshold); // da togliere
    });
  }


  _reachedGoal() {
    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 250),
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        },
        transitionBuilder: (context, a1, a2, widget) {
          return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
                child: AlertDialog(
                  backgroundColor: const Color.fromARGB(255, 242, 239, 245),
                  content: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Congratulation! You have reached your goal!!',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Image.asset('assets/goal.jpg'),
                        const SizedBox(height: 20),
                        Text('Do you want to move to the next level?',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    print('current level $_level');
                                    print('current score $_currentScore');
                                    _upDateGoal();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Yes')),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _percentage = 1;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text('No'),
                              ),
                            ],),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }
  

  _upDateGoal() async {
    Map<String, double> thresholds = {
      'Lazy': 50.5,
      'Medium': 110,
      'Hard': 150
    };
    
    final sp = await SharedPreferences.getInstance();
    int fullLaps = 1;
    String currLevel = _level; // lazy
    double currScore = _currentScore;  // 61.979
    double newthreshold = currScore;  // 61.979
    bool continueCycle = true;
    double difference = currScore % thresholds[currLevel]!; //(61.979 % 50.5 = 11.4790)
    print("difference $difference");

    while (continueCycle) {
      if (currLevel == 'Lazy') {
        newthreshold = thresholds['Medium']!;  // 110
        if (difference / newthreshold <= 1) {  // 11.4790 / 110 = 0.1043
          setState(() {
            print('Ok percentage = ${difference / newthreshold}');
            _percentage = difference / newthreshold;
            _level = 'Medium';
          });
          continueCycle = false;
        } else {
          difference = (difference / newthreshold) % newthreshold;
          currLevel = 'Medium';
        }
      } else if (currLevel == 'Medium') {
        newthreshold = thresholds['Hard']!;
        if (difference / newthreshold <= 1) {
          setState(() {
            _percentage = difference / newthreshold;
            _level = 'Hard';
          });
          continueCycle = false;
        } else {
          difference = (difference / newthreshold) % newthreshold;
          currLevel = 'Hard';
        }
      } else if (currLevel == 'Hard') {
        setState(() {
          _percentage = 1;
          //_reachGoal = true;
        });
        continueCycle = false;
      }
    }
    if (currLevel == 'Lazy' && fullLaps > 2) {
      fullLaps = 2;
    } else if (currLevel == 'Medium' && fullLaps > 1) {
      fullLaps = 1;
    } else if (currLevel == 'Hard') {
      fullLaps = 0;
    }
    
    String week = _getCurrentWeekIdentifier();
    sp.setDouble(week, _percentage);
    sp.setString('level_$week', _level);
    setState(() {
      _fullLaps = fullLaps;
    });
  }

  /*
  _reachedGoal() {
   showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text('Congratulations! You have reached your goal!!'),
      );
    },
  );
}
*/


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
                // PLOT
                const SizedBox(height: 5),
                Text('How much did you work out everyday during this week?',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                const Text(
                  'Tap on bars to discover more details',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color.fromARGB(202, 97, 20, 169),
                  ),
                ),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: widget.provider.exerciseData.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildBarPlot(widget.provider
                              .exerciseData), // input = list with exData every day of the week
                        ),
                ),
                // GOAL BOTTON
                Card(
                  elevation: 5,
                  child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      leading: _goalDisable
                      ? Icon(Icons.info_outline)
                      : Icon(Icons.run_circle_outlined), // metti qualcos'altro
                      tileColor: const Color.fromARGB(255, 227, 211, 244),
                      title: _goalDisable
                      ? Text('Some suggestions!')
                      : Text("Set a goal!"),
                      subtitle: _goalDisable
                      ? Text('I want to help you to reach your goal easily, click here!')
                      : Text('Find a good motivation to move your ass :)'),
                      iconColor: Color.fromARGB(255, 131, 35, 233),
                      hoverColor: const Color.fromARGB(255, 227, 211, 244),
                      onTap: () {
                        _goalDisable
                        ? null  // -------> collegare a una pagina che dà consigli 
                        :
                        showGeneralDialog(
                          barrierDismissible: true,
                          barrierLabel: "",
                          transitionDuration: const Duration(milliseconds: 200),
                          context: context,
                          pageBuilder: (context, animation1, animation2) {
                            return Container();
                          },
                          transitionBuilder: (context, a1, a2, widget) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.5, end: 1.0)
                                  .animate(a1),
                              child: FadeTransition(
                                opacity: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(a1),
                                child: AlertDialog(
                                  backgroundColor:
                                      const Color.fromARGB(255, 242, 239, 245),
                                  content: SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'How strong are you this week?',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 20),
                                          Card(
                                              elevation: 3,
                                              color: Colors.purple[100],
                                              //shape: ShapeBorder.,
                                              child: ListTile(
                                                  title: Text('Lazy level'),
                                                  subtitle: const Text(
                                                    'Minimum activity acceptable to live in a healthy way',
                                                    style:
                                                        TextStyle(fontSize: 11),
                                                  ),
                                                  trailing:
                                                      Icon(Icons.battery_0_bar),
                                                  iconColor: Colors.black,
                                                  onTap: () async {
                                                    setState(() {
                                                      _level = 'Lazy';
                                                      _goalDisable = true;
                                                    });
                                                    _setGoal(_level);
                                                    Navigator.of(context).pop();
                                                    (_reachGoal)
                                                        ? _reachedGoal()
                                                        : null;
                                                    final sp =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    String currentWeekKey =
                                                        _getCurrentWeekIdentifier();
                                                    sp.setDouble(currentWeekKey,
                                                        _percentage);
                                                    sp.setString(
                                                        'level_$currentWeekKey',
                                                        _level);
                                                    sp.setBool('goal_$currentWeekKey', true);
                                                  })),
                                          Card(
                                              elevation: 3,
                                              color: Colors.purple[200],
                                              //shape: ShapeBorder.,
                                              child: ListTile(
                                                  title: Text('Medium level'),
                                                  subtitle: const Text(
                                                    'Medium activity to live in a healthy way',
                                                    style:
                                                        TextStyle(fontSize: 11),
                                                  ),
                                                  trailing:
                                                      Icon(Icons.battery_3_bar),
                                                  iconColor: Colors.black,
                                                  onTap: () async {
                                                    setState(() {
                                                      _level = 'Medium';
                                                      _goalDisable = true;
                                                    });
                                                    _setGoal(_level);
                                                    final sp =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    String currentWeekKey =
                                                        _getCurrentWeekIdentifier();
                                                    sp.setDouble(currentWeekKey,
                                                        _percentage);
                                                    sp.setString(
                                                        'level_$currentWeekKey',
                                                        _level);
                                                    sp.setBool('goal_$currentWeekKey', true);
                                                    Navigator.of(context).pop();
                                                    (_reachGoal)
                                                        ? _reachedGoal()
                                                        : null;
                                                  })),
                                          Card(
                                              elevation: 3,
                                              color: Colors.purple[300],
                                              //shape: ShapeBorder.,
                                              child: ListTile(
                                                  title: Text('Hard level'),
                                                  subtitle: const Text(
                                                    'Strong activity life',
                                                    style:
                                                        TextStyle(fontSize: 11),
                                                  ),
                                                  trailing:
                                                      Icon(Icons.battery_full),
                                                  iconColor: Colors.black,
                                                  onTap: () async {
                                                    setState(() {
                                                      _level = 'Hard';
                                                      _goalDisable = true;
                                                    });
                                                    _setGoal(_level);
                                                    final sp =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    String currentWeekKey =
                                                        _getCurrentWeekIdentifier();
                                                    sp.setDouble(currentWeekKey,
                                                        _percentage);
                                                    sp.setString(
                                                        'level_$currentWeekKey',
                                                        _level);
                                                    sp.setBool('goal_$currentWeekKey', true);
                                                    Navigator.of(context).pop();
                                                    (_reachGoal)
                                                        ? _reachedGoal()
                                                        : null;
                                                  })),
                                          OutlinedButton(
                                            child: Icon(Icons.close_rounded,
                                                color: Color.fromARGB(
                                                    255, 227, 211, 244)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.all(6),
                                              shape: const CircleBorder(),
                                              backgroundColor: Color.fromARGB(
                                                  255, 183, 123, 248),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                ),

                // PERCENTAGE
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                          radius: 75,
                          lineWidth: 15,
                          center: Text(
                          "${(_percentage * 100).toStringAsFixed(2)}%",
                          style: TextStyle(fontSize: 20),
                          ),
                          progressColor: Color.fromARGB(255, 131, 35, 233),
                          animation: true,
                          animationDuration: 2000,
                          footer: Text(
                            'You chose the ${_level.toLowerCase()} level',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          percent: _percentage,
                          circularStrokeCap: CircularStrokeCap.round,
                          //widgetIndicator: _reachedGoal(),
                        ),

                      // LATERAL TEXT
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(width: 20),
                            Row(
                              children: [
                                Icon(Icons.directions_run),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        'Running performance: ${(widget.provider.exerciseDistance2()['Corsa'] ?? 0).toStringAsFixed(2)} kilometers',
                                        style: TextStyle(fontSize: 12))),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.directions_bike),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        'Biking performance: ${(widget.provider.exerciseDistance2()['Bici'] ?? 0).toStringAsFixed(2)} kilometers',
                                        style: TextStyle(fontSize: 12))),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.directions_walk),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        'Walking performance: ${(widget.provider.exerciseDistance2()['Camminata'] ?? 0).toStringAsFixed(2)} kilometers',
                                        style: TextStyle(fontSize: 12))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // SURVEY
                const SizedBox(height: 30),
                Card(
                  elevation: 5,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    tileColor: const Color.fromARGB(255, 227, 211, 244),
                    title: Text('Survey of the day'), // funzione definita sotto
                    subtitle: const Text(
                      'Tell me about your activity',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      if (_buttonClickedToday == false) {
                        _onButtonClick();
                        showGeneralDialog(
                          // si apre il pop-up
                          barrierDismissible: true,
                          barrierLabel: "",
                          transitionDuration: const Duration(milliseconds: 200),
                          context: context,
                          pageBuilder: (context, animation1, animation2) {
                            return Container();
                          },
                          transitionBuilder: (context, a1, a2, widget) {
                            return ScaleTransition(
                                scale: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(a1),
                                child: FadeTransition(
                                  opacity: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(a1),
                                  child: AlertDialog(
                                    backgroundColor: const Color.fromARGB(
                                        255, 242, 239, 245),
                                    content: SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CardDialog(),
                                            const SizedBox(height: 20),
                                            OutlinedButton(
                                              child: Icon(Icons.close_rounded,
                                                  color: Color.fromARGB(
                                                      255, 227, 211, 244)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                shape: const CircleBorder(),
                                                backgroundColor: Color.fromARGB(
                                                    255, 183, 123, 248),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        );
                      } else {
                        showDialog(
                          // si apre il pop-up
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: Text(
                                'Oh no!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              elevation: 5,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'You have already done the survey for today, see you tommorrow :)',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      ),
                                      const SizedBox(height: 40),
                                      OutlinedButton(
                                        child: Icon(Icons.close_rounded,
                                            color: Color.fromARGB(
                                                255, 227, 211, 244)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(6),
                                          shape: const CircleBorder(),
                                          backgroundColor: Color.fromARGB(
                                              255, 183, 123, 248),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
  List<PieChart?> pieList = [];
  List<String?> legend = [];
  for (ExerciseData data in exerciseDataList) {
    // per ogni giorno
    //hoursList.add(data.duration/60);
    minOfEx.add((data.duration));
    pieList.add(
        _buildPieChart([data], true)); // in _builPieChart insert ExerciseData
    legend.add("Run: ${((calculatePercentage([
          data
        ])!)["Corsa"]!).toStringAsFixed(1)}% \nBike: ${((calculatePercentage([
          data
        ])!)["Bici"]!).toStringAsFixed(1)}% \nWalk: ${((calculatePercentage([
          data
        ])!)["Camminata"]!).toStringAsFixed(1)}%");
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
    "Corsa": (totalRun / total) * 100,
    "Bici": (totalBike / total) * 100,
    "Camminata": (totalWalking / total) * 100
  };
  return percentages;
}

PieChart _buildPieChart(
    List<ExerciseData> exerciseData, bool _isPhasesCardExpanded) {
  // ------> dove viene inizializzata la bool
  double radius = 30;
  bool title = false;
  (_isPhasesCardExpanded) ? radius = 75 : radius = 30;
  (_isPhasesCardExpanded) ? title = true : title = false;
  return PieChart(
    PieChartData(
      sections: [
        PieChartSectionData(
          value: (calculatePercentage(exerciseData)!)["Corsa"],
          color: const Color(0xFF8A2BE2), // Viola scuro per Deep Sleep
          title: "Run", titlePositionPercentageOffset: 0.7,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
          showTitle: title,
          radius: radius,
        ),
        PieChartSectionData(
          value: (calculatePercentage(exerciseData)!)["Bici"],
          color: const Color(0xFFBA55D3), // Viola medio per REM Sleep
          title: "Bike", titlePositionPercentageOffset: 0.7,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
          showTitle: title,
          radius: radius,
        ),
        PieChartSectionData(
          value: (calculatePercentage(exerciseData)!)["Camminata"],
          color: const Color(0xFF9370DB), // Viola chiaro per Light Sleep
          title: "Walking", titlePositionPercentageOffset: 0.7,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
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

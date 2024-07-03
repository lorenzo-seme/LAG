import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/sliderWidget.dart';
import 'package:lag/screens/rhrScreen.dart';
import 'package:lag/utils/barplotEx.dart';
//import 'package:lag/screens/rhrScreen.dart';
//import 'package:lag/models/heartratedata.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lag/screens/cardDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;
  final bool current;
  final String week;

  const ExerciseScreen(
      {super.key,
      required this.startDate,
      required this.endDate,
      required this.provider,
      required this.current,
      required this.week});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool _buttonClickedToday = false; // survey
  bool _sameDay = false; // goal
  double _threshold = 0;
  double _currentScore = 0;
  double _percentage = 0;
  String _level = '';
  bool _reachGoal = false;
  bool _exToday = false;
  //int _fullLaps = 0;
  bool _goalDisable = false;
  Map<String, double> _performances = {};
  bool _currentWeek = true;

  @override
  void initState() {
    super.initState();
    _loadPercentage();
    _checkButtonStatus();
    _exerciseToday();
    _isCurrentWeek();
  }

  // GENEAL METHODS:
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getCurrentWeekIdentifier() {
    DateTime date = widget.startDate;
    //print('now $date');
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    //print('first of the year $firstDayOfYear');
    int daysDifference = date.difference(firstDayOfYear).inDays;
    //print('differenze $daysDifference');
    int weekNumber = (daysDifference / 7).ceil() + 1;
    return "$weekNumber";
  }

_isCurrentWeek() async {
  final sp = await SharedPreferences.getInstance();
  double currentWeek = double.parse(_getCurrentWeekIdentifier()); // settimana che sto visualizzando
  double? week = sp.getDouble('CurrentWeek'); 
  DateTime now = DateTime.now().subtract(Duration(days: 1));
  DateTime firstDayOfYear = DateTime(now.year, 1, 1);
  int daysDifference = now.difference(firstDayOfYear).inDays;
  double weekNumber = (daysDifference / 7).floor() + 1;
  //print("week $week, weeknumber $weekNumber, currentWeek $currentWeek");

  if (week == null || currentWeek == weekNumber) {
    setState(() {
      _currentWeek = true;
      //_goalDisable = true;
    });
  } else if (currentWeek == weekNumber) {
    setState(() {
      _currentWeek = true;
    });
  } else {
    setState(() {
      _currentWeek = false;
      _goalDisable = true;
    });
  }
  sp.setDouble('CurrentWeek', weekNumber);
  //print("cw: ${_currentWeek}");
  //return currentWeek == weekNumber;
}

  Future<void> _onButtonClick() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastClickedDate', now.toIso8601String());

    setState(() {
      _buttonClickedToday = true;  // da cambiare a true
    });
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
            _buttonClickedToday = true;  // da cambaire a true
          },
        );
      }
    }
  }

  _exerciseToday() async {
    final sp = await SharedPreferences.getInstance();
    final day = DateTime.now().subtract(Duration(days: 1)).day;
    final month = DateTime.now().subtract(Duration(days: 1)).month;
    if (widget.provider.exerciseToday()) {
      setState(() {
        _exToday = true;
      });
  } else {
    _exToday = false;
  }
  sp.setBool('exToday_${day}_${month}', _exToday);
  print('exToday_${day}_${month} ${_exToday}');
  }

  // ----- GOAL INTERNAL METHODS:----------------------
  _loadPercentage() async {
    final sp = await SharedPreferences.getInstance();
    String level = sp.getString('level_${widget.week}') ?? ''; // livello
    bool goal = sp.getBool('goal_${widget.week}') ?? false;  // se il goal è già stato settato nella settimana
    List<String> names = getNames(widget.provider.exerciseData);
    Map<String, double> performance = {};
    print("widget.week : ${widget.week}");

    setState(() { // setto ora perchè questi non cambiano nell'arco della settimana
      _level = level;
      _goalDisable = goal;
    });

    try {
      double savedPercentage = sp.getDouble("percentage_${widget.week}") ?? 0.0;
      for (var act in names) {
        performance[act] = sp.getDouble("${act}_${widget.week}") ?? 0;
      }
      _checkGoalStatus();
      if (_sameDay) {
        setState(() {
          _percentage =
              savedPercentage; // every time that open the page but it is the same day, returns the same value of percentage
          _performances = performance;
        });
      } else {
        _dailyUpdate();
        sp.setDouble("percentage_${widget.week}", _percentage);
        for (var act in names) {
          if (_performances[act] != null) {
            sp.setDouble("${act}_${widget.week}", _performances[act]!);
          } else {
            sp.setDouble("${act}_${widget.week}", 0);
          }
        }
        print(_performances);
      }
    } catch (e) {
     print('Error loading percentage: $e');
    }
  }

  Future<void> _checkGoalStatus() async {
    final sp = await SharedPreferences.getInstance();
    final lastUpdateDate = sp.getString('lastUpdateDate');

    if (lastUpdateDate != null) {
      final lastClicked = DateTime.parse(lastUpdateDate);
      final now = DateTime.now();

      if (_isSameDay(lastClicked, now)) {
        setState(
          () {
            _sameDay = true;
          },
        );
      }
    }
  }

  _dailyUpdate() {
    double wRun = 0.3;
    double wBike = 0.2;
    double wWalk = 0.05;
    double wOther = 0.45;
    double score = 0;
    Map<String, double> weights = {
      'Corsa': wRun,
      'Bici': wBike,
      'Camminata': wWalk,
      'Other': wOther
    };
    Map<String, double> distances = widget.provider.exerciseDistanceActivities();
    for (String act in distances.keys) {
      setState(() {
        _performances[act] = distances[act]!;
      });
      if (act == 'Corsa' || act == 'Bici' || act == 'Camminata') {
        score = score + distances[act]! * weights[act]!;
      } else {
        score = score + distances[act]! * weights['Other']!;
      }
    }
    Map<String, double> thresholds = {
      'Lazy': 50.5,
      'Medium': 110,
      'Hard': 150.5
    };
    print("score $score");
    print("_threshold $_threshold");
    print("level $_level");
    double p = score / thresholds[_level]!;
    if (p >= 1) {
      _reachedGoal();
      return 1;
    } else {
      setState(() {
        _percentage = score / thresholds[_level]!;
      });
      return score / thresholds[_level]!;
    }
  }

  _setGoal(String level) {
    //List<String> names = getNames(widget.provider.exerciseData);
    String week = _getCurrentWeekIdentifier();
    double wRun = 0.3;
    double wBike = 0.2;
    double wWalk = 0.05;
    double wOther = 0.45;
    double score = 0;
    Map<String, double> weights = {
      'Corsa': wRun,
      'Bici': wBike,
      'Camminata': wWalk,
      'Other': wOther
    };
    Map<String, double> performance = {};
    Map<String, double> distances = widget.provider.exerciseDistanceActivities();
    for (String act in distances.keys) {
      performance[act] = performance[act]! + distances[act]!;
      if (act == 'Corsa' || act == 'Bici' || act == 'Camminata') {
        score = score + distances[act]! * weights[act]!;
      } else {
        score = score + distances[act]! * weights['Other']!;
      }
    }
    Map<String, double> thresholds = {
      'Lazy': 50.5,
      'Medium': 110,
      'Hard': 150.5
    };
    setState(() {
      //_level = level;
      _threshold = thresholds[level]!;
      _currentScore = score;
      _performances = performance;
      if (_currentScore / _threshold >= 1) {
        _reachGoal = true;
      } else {
        _percentage = _currentScore / _threshold;
      }
      //print(_currentScore / _threshold); // da togliere
    });
    // -------> mettere anche sp per percentage???
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  _upDateGoal() async {
    Map<String, double> thresholds = {'Lazy': 50.5, 'Medium': 110, 'Hard': 150};

    final sp = await SharedPreferences.getInstance();
    int fullLaps = 1;
    String currLevel = _level;
    double currScore = _currentScore;
    double newthreshold = currScore;
    bool continueCycle = true;
    double difference = currScore % thresholds[currLevel]!;
    print("difference $difference");

    while (continueCycle) {
      if (currLevel == 'Lazy') {
        newthreshold = thresholds['Medium']!; // 110
        if (difference / newthreshold <= 1) {
          // 11.4790 / 110 = 0.1043
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
    sp.setDouble("percentage_${week}", _percentage);
    sp.setString('level_$week', _level);
    /*
    setState(() {
      _fullLaps = fullLaps;
    });*/
  }

  Widget _lateralText() {
    List<ExerciseData> exerciseDataList = widget.provider.exerciseData;
    if (exerciseDataList.isEmpty) {
      return const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'No goals or activities recorded',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      List<String> names = getNames(exerciseDataList);
      Map<String, String> namesEn = {};
      Map<String, Icon> imm = {
        'Corsa': Icon(Icons.directions_run),
        'Bici': Icon(Icons.directions_bike),
        'Camminata': Icon(Icons.directions_walk),
        'Spinning': Icon(Icons.pool),
        'Nuoto': Icon(Icons.pool),
        'Basket': Icon(Icons.sports_basketball),
        'Tennis': Icon(Icons.sports_tennis),
      };
      for (int i = 0; i < names.length; i++) {
        setState(() {
          _performances[names[i]] =
              widget.provider.exerciseDistanceActivities()[names[i]] ?? 0;
        });
        if (names[i] == "Corsa") {
          namesEn[names[i]] = 'Run';
        } else if (names[i] == 'Bici') {
          namesEn[names[i]] = 'Bike';
        } else if (names[i] == 'Camminata') {
          namesEn[names[i]] = 'Walk';
        } else if (names[i] == 'Nuoto') {
          namesEn[names[i]] = 'Swim';
        } else {
          namesEn[names[i]] = names[i];
        }
      }

      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            ...names.map((act) {
              return Column(
                children: [
                  Row(
                    children: [
                      imm[act] ??
                          Icon(Icons
                              .fitness_center), // Icona di default se non trovata
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${namesEn[act]} performance: ${_performances[act]!.toStringAsFixed(2)} kilometers',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      );
    }
  }

  _updatePerformances() async {
    final sp = await SharedPreferences.getInstance();
    String week = _getCurrentWeekIdentifier();
    List<String> names = getNames(widget.provider.exerciseData);
    for (String act in names) {
      sp.setDouble("${act}_$week", _performances[act]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dataCheckMessage = checkData(widget.provider.exerciseData);
    bool noDataAvailable = dataCheckMessage == "No data available";

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
      body: noDataAvailable
          ? _buildNoDataMessage()
          : SingleChildScrollView(
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
                            Text(
                                'How much did you work out everyday during this week?',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold)),
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
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: _buildBarPlot(widget.provider
                                          .exerciseData), // input = list with exData every day of the week
                                    ),
                            ),
                            // GOAL BOTTON
                            (_currentWeek)
                            ?
                            Card(
                              elevation: 5,
                              child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  leading: _goalDisable
                                      ? Icon(Icons.info_outline)
                                      : Icon(Icons
                                          .run_circle_outlined), // metti qualcos'altro
                                  tileColor:
                                      const Color.fromARGB(255, 227, 211, 244),
                                  title: _goalDisable
                                      ? Text('Some suggestions!')
                                      : Text("Set a goal!"),
                                  subtitle: _goalDisable
                                      ? Text(
                                          'I want to help you to reach your goal easily, click here!')
                                      : Text(
                                          'Find a good motivation to move your ass :)'),
                                  iconColor: Color.fromARGB(255, 131, 35, 233),
                                  hoverColor:
                                      const Color.fromARGB(255, 227, 211, 244),
                                  onTap: () {
                                    _goalDisable
                                        ? null // -------> collegare a una pagina che dà consigli
                                        : showGeneralDialog(
                                            barrierDismissible: true,
                                            barrierLabel: "",
                                            transitionDuration: const Duration(
                                                milliseconds: 200),
                                            context: context,
                                            pageBuilder: (context, animation1,
                                                animation2) {
                                              return Container();
                                            },
                                            transitionBuilder:
                                                (context, a1, a2, widget) {
                                              return ScaleTransition(
                                                scale: Tween<double>(
                                                        begin: 0.5, end: 1.0)
                                                    .animate(a1),
                                                child: FadeTransition(
                                                  opacity: Tween<double>(
                                                          begin: 0.5, end: 1.0)
                                                      .animate(a1),
                                                  child: AlertDialog(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 242, 239, 245),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'How strong are you this week?',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Card(
                                                                elevation: 3,
                                                                color: Colors
                                                                        .purple[
                                                                    100],
                                                                //shape: ShapeBorder.,
                                                                child: ListTile(
                                                                    title: Text(
                                                                        'Lazy level'),
                                                                    subtitle:
                                                                        const Text(
                                                                      'Minimum activity acceptable to live in a healthy way',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                    ),
                                                                    trailing: Icon(
                                                                        Icons
                                                                            .battery_0_bar),
                                                                    iconColor:
                                                                        Colors
                                                                            .black,
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        _level =
                                                                            'Lazy';
                                                                        _goalDisable =
                                                                            true;
                                                                      });
                                                                      _setGoal(
                                                                          _level);
                                                                      final sp =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      String
                                                                          currentWeekKey =
                                                                          _getCurrentWeekIdentifier();
                                                                      sp.setDouble(
                                                                          currentWeekKey,
                                                                          _percentage);
                                                                      sp.setString(
                                                                          'level_$currentWeekKey',
                                                                          _level);
                                                                      sp.setBool(
                                                                          'goal_$currentWeekKey',
                                                                          true);
                                                                      for (var act in _performances.keys) {
                                                                        sp.setDouble("${act}_$currentWeekKey", _performances[act]!);
                                                                      }
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      (_reachGoal)
                                                                          ? _reachedGoal()
                                                                          : null;
                                                                    })),
                                                            Card(
                                                                elevation: 3,
                                                                color: Colors
                                                                        .purple[
                                                                    200],
                                                                //shape: ShapeBorder.,
                                                                child: ListTile(
                                                                    title: Text(
                                                                        'Medium level'),
                                                                    subtitle:
                                                                        const Text(
                                                                      'Medium activity to live in a healthy way',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                    ),
                                                                    trailing: Icon(
                                                                        Icons
                                                                            .battery_3_bar),
                                                                    iconColor:
                                                                        Colors
                                                                            .black,
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        _level =
                                                                            'Medium';
                                                                        _goalDisable =
                                                                            true;
                                                                      });
                                                                      _setGoal(
                                                                          _level);
                                                                      final sp =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      String
                                                                          currentWeekKey =
                                                                          _getCurrentWeekIdentifier();
                                                                      sp.setDouble(
                                                                          currentWeekKey,
                                                                          _percentage);
                                                                      sp.setString(
                                                                          'level_$currentWeekKey',
                                                                          _level);
                                                                      sp.setBool(
                                                                          'goal_$currentWeekKey',
                                                                          true);
                                                                      for (var act in _performances.keys) {
                                                                        sp.setDouble("${act}_$currentWeekKey", _performances[act]!);
                                                                      }
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      (_reachGoal)
                                                                          ? _reachedGoal()
                                                                          : null;
                                                                    })),
                                                            Card(
                                                                elevation: 3,
                                                                color: Colors
                                                                        .purple[
                                                                    300],
                                                                //shape: ShapeBorder.,
                                                                child: ListTile(
                                                                    title: Text(
                                                                        'Hard level'),
                                                                    subtitle:
                                                                        const Text(
                                                                      'Strong activity life',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                    ),
                                                                    trailing: Icon(
                                                                        Icons
                                                                            .battery_full),
                                                                    iconColor:
                                                                        Colors
                                                                            .black,
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        _level =
                                                                            'Hard';
                                                                        _goalDisable =
                                                                            true;
                                                                      });
                                                                      _setGoal(
                                                                          _level);
                                                                      final sp =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      String
                                                                          currentWeekKey =
                                                                          _getCurrentWeekIdentifier();
                                                                      sp.setDouble(
                                                                          currentWeekKey,
                                                                          _percentage);
                                                                      sp.setString(
                                                                          'level_$currentWeekKey',
                                                                          _level);
                                                                      sp.setBool(
                                                                          'goal_$currentWeekKey',
                                                                          true);
                                                                      for (var act in _performances.keys) {
                                                                        sp.setDouble("${act}_$currentWeekKey", _performances[act]!);
                                                                      }
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      (_reachGoal)
                                                                          ? _reachedGoal()
                                                                          : null;
                                                                    })),
                                                            SizedBox(
                                                                height: 20),
                                                            TextButton(
                                                              child:
                                                                  Text('Close'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            )
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
                            )
                            :

                            // PERCENTAGE
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12,vertical: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: 75,
                                    lineWidth: 15,
                                    center: Text(
                                      "${(_percentage * 100).toStringAsFixed(2)}%",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    progressColor:
                                        Color.fromARGB(255, 131, 35, 233),
                                    animation: true,
                                    animationDuration: 2000,
                                    footer: _level != ''
                                        ? Text(
                                            'You chose the ${_level.toLowerCase()} level',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          )
                                        : null,
                                    percent: _percentage,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    //widgetIndicator: _reachedGoal(),
                                  ),

                                  // LATERAL TEXT
                                  const SizedBox(width: 20),
                                  _lateralText()
                                ],
                              ),
                            ),

                            // SURVEY
                            const SizedBox(height: 10),
                            (_currentWeek) 
                            ? 
                            Card(
                              elevation: 5,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                tileColor:
                                    const Color.fromARGB(255, 227, 211, 244),
                                title: Text(
                                    'Survey of the day'), // funzione definita sotto
                                subtitle: _buttonClickedToday
                                ? Text('Get something more')
                                : Text(
                                  'Tell me about your activity',
                                  style: TextStyle(fontSize: 11),
                                ),
                                trailing: _buttonClickedToday
                                ? Icon(Icons.done_all, color: Colors.lightGreen.shade900)
                                : null,
                                onTap: () {
                                  //if (_buttonClickedToday == false) {
                                    showGeneralDialog(
                                      // si apre il pop-up
                                      barrierDismissible: true,
                                      barrierLabel: "",
                                      transitionDuration:
                                          const Duration(milliseconds: 200),
                                      context: context,
                                      pageBuilder:
                                          (context, animation1, animation2) {
                                        return Container();
                                      },
                                      transitionBuilder:
                                          (context, a1, a2, widget) {
                                        return ScaleTransition(
                                            scale: Tween<double>(
                                                    begin: 0.5, end: 1.0)
                                                .animate(a1),
                                            child: FadeTransition(
                                              opacity: Tween<double>(
                                                      begin: 0.5, end: 1.0)
                                                  .animate(a1),
                                              child: AlertDialog(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 242, 239, 245),
                                                content: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.all(20),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        _exToday
                                                        ? SliderWidget(_buttonClickedToday)
                                                        : CardDialog(
                                                            _buttonClickedToday), // CARD HERE
                                                        const SizedBox(
                                                            height: 20),
                                                        TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ));
                                      },
                                    );
                                    _onButtonClick();
                                },
                              ),
                            )
                            : Card(
                              elevation: 5,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                tileColor:
                                    const Color.fromARGB(255, 227, 211, 244),
                                title: Text(
                                    'Summary of your surveys'), // funzione definita sotto
                                subtitle: Text('Get something more',
                                  style: TextStyle(fontSize: 11),
                                ),
                                onTap: ()  async {
                    
                                  final sp = await SharedPreferences.getInstance();
                                  Map<String, dynamic> results = {};
                                  int month = widget.provider.start.month;
                                  List<int> range_days = List.generate(7, (index) => widget.provider.start.add(Duration(days: index)).day);
                                  for (int d in range_days) {
                                    if (sp.getDouble("q1_${d}_${widget.provider.start.month}") != null) {
                                      results["resultS_${d}_${widget.provider.start.month}"] = [
                                        sp.getDouble("q1_${d}_${widget.provider.start.month}"),
                                        sp.getDouble("q2_${d}_${widget.provider.start.month}"),
                                        sp.getDouble("q3_${d}_${widget.provider.start.month}")
                                      ];
                                    } else if (sp.getString("survey_${d}_${widget.provider.start.month}") != null) {
                                        results["resultS_${d}_${widget.provider.start.month}"] = sp.getString("survey_${d}_${widget.provider.start.month}");
                                    } else {
                                      results["resultS_${d}_${widget.provider.start.month}"] = 0;
                                    }
                                  }
                                  //surveySummary(context, results, range_days, month);
                                  
                                }
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ]))),
            ),
    );
  }
}

_buildBarPlot(List<ExerciseData> exerciseDataList) {
  // lista della settimana
  List<double> minOfEx = []; // 52.62
  List<PieChart?> pieList = [];
  List<String?> legend = [];
  List<String> names = getNames(exerciseDataList); // spinning
  //print('getNames in _buildBarPlot : $names');

  for (ExerciseData data in exerciseDataList) {
    minOfEx.add(data.duration);
    //print('minOfEx: $minOfEx');
    pieList.add(_buildPieChart([data], true));

    // Crea dinamicamente la legenda per ogni attività
    String legendEntry = names.map((activity) {
      final percentage = calculatePercentage([data])?[activity] ?? 0;
      return "$activity: ${percentage.toStringAsFixed(1)}%";
    }).join(" \n");

    legend.add(legendEntry);
  }

  while (minOfEx.length < 7) {
    minOfEx.add(0);
    pieList.add(null);
    legend.add(null);
  }

  return BarChartSample7(yValues: minOfEx, pieCharts: pieList, legend: legend);
}

Map<String, double>? calculatePercentage(List<ExerciseData> exerciseDataList) {
  //print('ok');
  Map<String, double> total = {};
  double t = 0;
  Set<String> names = {};

  if (exerciseDataList.length > 1) {
    // più di un giorno
    for (var data in exerciseDataList) {
      // seleziono exData singolo gg
      for (var act in data.actNames) {
        total[act] = (total[act] ?? 0) + (data.activities[act]?[0] ?? 0);
        names.add(act);
        t += data.activities[act]?[0] ?? 0;
      }
    }
  } else {
    //print(exerciseDataList[0].actNames);
    for (var act in exerciseDataList[0].actNames) {
      // inserisco dati di un solo giorno
      total[act] =
          (total[act] ?? 0) + (exerciseDataList[0].activities[act]?[0] ?? 0);
      names.add(act);
      t += exerciseDataList[0].activities[act]?[0] ?? 0;
    }
  }
  //print('Da percentage: total $total, t: $t');
  Map<String, double> percentages = {};
  if (t == 0) {
    // Return 0 percentage for each activity name
    for (var act in names) {
      percentages[act] = 0;
    }
  } else {
    for (var act in names) {
      percentages[act] = (total[act]! / t) * 100;
    }
  }
  //print(percentages);
  return percentages;
}

List<String> getNames(List<ExerciseData> exerciseDataList) {
  List<String> names = [];
  for (var data in exerciseDataList) {
    // seleziono dati, un giorno alla volta
    for (var act in data.actNames) {
      if (!names.contains(act)) {
        names.add(act);
      }
    }
  }
  return names;
}

PieChart _buildPieChart(
    List<ExerciseData> exerciseData, bool _isPhasesCardExpanded) {
  double radius = _isPhasesCardExpanded ? 75 : 30;
  bool title = _isPhasesCardExpanded;

  // Ottieni i nomi delle attività
  List<String> activityNames = exerciseData[0].actNames;
  Map<String, Color> colori = getColorForActivity(activityNames);
  //print('getNames in _buildPiechart : $activityNames');

  // Crea dinamicamente le sezioni del grafico a torta
  List<PieChartSectionData> sections = activityNames.map((activity) {
    //print('activity in pie : ${calculatePercentage(exerciseData)![activity]}');
    return PieChartSectionData(
      value: (calculatePercentage(exerciseData)![activity]),
      color: colori[
          activity], // Funzione per ottenere il colore in base all'attività
      title: activity,
      titlePositionPercentageOffset: 0.7,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 11),
      showTitle: title,
      radius: radius,
    );
  }).toList();

  return PieChart(
    PieChartData(
      sections: sections,
      centerSpaceColor: Colors.transparent,
      centerSpaceRadius: 0.01,
      sectionsSpace: 2,
    ),
  );
}

// Funzione di esempio per ottenere un colore in base all'attività
Color getRandomPurpleColor() {
  Random random = Random();
  int red = 128 + random.nextInt(128); // Valori tra 128 e 255
  int green = 0;
  int blue = 128 + random.nextInt(128); // Valori tra 128 e 255
  return Color.fromARGB(255, red, green, blue);
}

Map<String, Color> getColorForActivity(List<String> activities) {
  Map<String, Color> activityColors = {};
  for (String activity in activities) {
    activityColors[activity] = getRandomPurpleColor();
  }
  return activityColors;
}

String checkData(List<ExerciseData> sleepData) {
  List<String> noDataDays = [];
  bool noDataFlag = true;
  for (ExerciseData data in sleepData) {
    if (data.distance == 0 && data.duration == 0) {
      String formattedDay = DateFormat('EEEE', 'en_US').format(data.day);
      noDataDays.add(formattedDay);
    } else {
      noDataFlag = false;
    }
  }
  if (noDataDays.isEmpty) {
    return "All days have data";
  } else if (noDataFlag) {
    return "No data available";
  } else if (noDataDays.length == 1) {
    return "${noDataDays[0]}: No data available";
  } else {
    return "${noDataDays.join(' ,')}: No data available";
  }
}

Widget _buildNoDataMessage() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error, size: 50),
        SizedBox(height: 10),
        Text("No data available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

/*
void surveySummary(BuildContext context, Map<String, dynamic> results, List<int> days, int month) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Survey Results",
    barrierColor: Colors.black54,
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: days.map((day) {
                  String key = "resultS_${day}_${month}";
                  var result = results[key];
                  String displayText;

                  if (result == 0) {
                    displayText = "No survey";
                  } else if (result is String) {
                    if (result == 'Yes0') {
                      displayText = 'Workout done';
                    }
                  } else if (result is List) {
                    displayText = result.join(", ");
                  } else {
                    displayText = "Tipo di dato non supportato";
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$day",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        results[key] ?? "No survey",
                        style: TextStyle(fontSize: 16),
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      );
    },
  );
}
*/

void surveySummary(BuildContext context, Map<String, dynamic> results, List<int> days, int month) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Survey Results",
    barrierColor: Colors.black54,
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: days.map((day) {
                  String key = "resultS_${day}_${month}";
                  String result = results[key] ?? "No survey";
                  String displayText;

                  if (result == "No survey") {
                    displayText = "Nessun sondaggio";
                  } else if (result == "Completed") {
                    displayText = "Sondaggio completato";
                  } else {
                    displayText = result;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Giorno $day",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        displayText,
                        style: TextStyle(fontSize: 16),
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      );
    },
  );
}


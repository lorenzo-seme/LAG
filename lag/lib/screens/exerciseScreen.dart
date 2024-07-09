import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/cardDialog.dart';
import 'package:lag/screens/personal_info.dart';
import 'package:lag/screens/reachedGoal.dart';
import 'package:lag/screens/sliderWidget.dart';
import 'package:lag/utils/barplotEx.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _goalDisable = false;
  Map<String, double> _performances = {};
  bool _currentWeek = true;
  bool _isExerciseCardExpanded = false;
  double wRun = 0.3;
  double wBike = 0.2;
  double wWalk = 0.05;
  double wOther = 0.45;
  double score = 0;
  Map<String, double> weights = {
    'Corsa': 0.3,
    'Bici': 0.2,
    'Camminata': 0.05,
    'Other': 0.45
  };
  Map<String, double> thresholds = {
      'Lazy': 50.5,
      'Medium': 110,
      'Hard': 150.5
    };

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
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    int daysDifference = date.difference(firstDayOfYear).inDays;
    int weekNumber = (daysDifference / 7).ceil() + 1;
    return "$weekNumber";
  }

  _isCurrentWeek() async {
    final sp = await SharedPreferences.getInstance();
    double currentWeek = double.parse(
        _getCurrentWeekIdentifier());
    double? week = sp.getDouble('CurrentWeek');
    DateTime now = DateTime.now().subtract(const Duration(days: 1));
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    int daysDifference = now.difference(firstDayOfYear).inDays;
    double weekNumber = (daysDifference / 7).floor() + 1;

    if (week == null || currentWeek == weekNumber) {
      setState(() {
        _currentWeek = true;
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
  }

  Future<void> _onButtonClick() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastClickedDate', now.toIso8601String());

    setState(() {
      _buttonClickedToday = true;
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
            _buttonClickedToday = true;
          },
        );
      }
    }
  }

  _exerciseToday() async {
    final sp = await SharedPreferences.getInstance();
    DateTime date = DateTime.now().subtract(const Duration(days: 1));
    String dateString = date.toIso8601String().split('T').first;
    if (widget.provider.exerciseToday()) {
      setState(() {
        _exToday = true;
      });
    } else {
      _exToday = false;
    }
    sp.setBool('exToday_$dateString', _exToday);
  }

  // ----- GOAL INTERNAL METHODS:----------------------
  _loadPercentage() async {
    final sp = await SharedPreferences.getInstance();
    String level = sp.getString('level_${widget.week}') ?? '';
    bool goal = sp.getBool('goal_${widget.week}') ??
        false;
    List<String> names = getNames(widget.provider.exerciseData);
    Map<String, double> performance = {};

    setState(() {
      _level = level;
      _goalDisable = goal;
    });

    try {
      double savedPercentage = sp.getDouble("percentage_${widget.week}") ?? 0.0;
      for (var act in names) {
        performance[act] = sp.getDouble("${act}_${widget.week}") ?? 0;
      }
      _checkGoalStatus();
      if (_sameDay && _goalDisable) {
        setState(() {
          _percentage = savedPercentage; // every time that open the page but it is the same day, returns the same value of percentage
          _performances = performance;
        });
      } else if (_sameDay && !_goalDisable) {
        setState(() {
          _percentage = 0;
        });
      } else if (!_sameDay && !_goalDisable) {
        setState(() {
          _percentage = 0;
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
      }
    } catch (e) {
      // ignore: avoid_print
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
    
    Map<String, double> distances = _performances;
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

    

    double p = score / thresholds[_level]!;
    if (p >= 1) {
      setState(() {
        _reachGoal = true;
      });
      return 1;
    } else {
      setState(() {
        _percentage = score / thresholds[_level]!;
      });
      return score / thresholds[_level]!;
    }
  }

  _setGoal(String level) {
    Map<String, double> distances =
        widget.provider.exerciseDistanceActivities();
    
    for (String act in distances.keys) {
      if (act == 'Corsa' || act == 'Bici' || act == 'Camminata') {
        score = score + distances[act]! * weights[act]!;
      } else {
        score = score + distances[act]! * weights['Other']!;
      }
    }

    setState(() {
      _threshold = thresholds[level]!;
      _currentScore = score;
      _performances = distances;
      if (_currentScore / _threshold >= 1) {
        _reachGoal = true;
        _percentage = _currentScore / _threshold;
      } else {
        _percentage = _currentScore / _threshold;
      }
    });
  }

  _upDateGoal() async {
    final sp = await SharedPreferences.getInstance();
    String currLevel = _level;
    double currScore = _currentScore;
    double newthreshold = currScore;
    double difference = currScore % thresholds[currLevel]!;

    if (currLevel == 'Lazy') {
      newthreshold = thresholds['Medium']!;
      if (difference / newthreshold <= 1) {
        setState(() {
          _percentage = difference / newthreshold;
          _level = 'Medium';
          _reachGoal = false;
        });
      } else {
        setState(() {
          _percentage = (difference / newthreshold) % newthreshold;
          _level = 'Medium';
          _reachGoal = true;
        });
      }
    } else if (currLevel == 'Medium') {
      newthreshold = thresholds['Hard']!;
      if (difference / newthreshold <= 1) {
        setState(() {
          _percentage = difference / newthreshold;
          _level = 'Hard';
          _reachGoal = false;
        });
      } else {
        setState(() {
          _percentage = difference % newthreshold;
          _level = 'Hard';
          _reachGoal = true;
        });
      }
    } else if (currLevel == 'Hard') {
      setState(() {
        _percentage = 1;
      });
    }

    String week = _getCurrentWeekIdentifier();
    sp.setDouble("percentage_$week", _percentage);
    sp.setString('level_$week', _level);
    _showPercentage();
  }

  Widget _showPercentage() {
    double percentValue = _percentage > 1 ? 1 : _percentage;
    if (percentValue > 1) {
      percentValue = 1;
    }
    return GestureDetector(
      onTap: () {
        _reachGoal ? _upDateGoal() : null;
      },
      child: CircularPercentIndicator(
        radius: 75,
        lineWidth: 15,
        center: _reachGoal
            ? const Text(
                "100%",
                style: TextStyle(fontSize: 20),
              )
            : Text(
                "${(_percentage * 100).toStringAsFixed(2)}%",
                style: const TextStyle(fontSize: 20),
              ),
        progressColor: const Color.fromARGB(255, 131, 35, 233),
        animation: true,
        animationDuration: 2000,
        footer: ((_level != '' || _level == 'Hard') && !_reachGoal)
            ? Text(
                '$_level level',
                style: const TextStyle(
                  fontSize: 12,
                ),
              )
            : (_reachGoal)
                ? Text("$_level reached, press here to update!")
                : const Text("No goal set"),
        percent: _reachGoal ? 1 : percentValue,
        circularStrokeCap: CircularStrokeCap.round,
      ),
    );
    }
  

  Future<void> _notifyOnePossibilityGoal() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Be careful! This is your goal for the week.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          content: const Text(
              'Once you set a goal, you won\'t be able to change it until the next week. Make sure to choose wisely and stay committed!',
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _goalDisable = true;
                    });
                  },
                  child: const Text('Set goal'),
                ),
                const SizedBox(width: 70),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back'),
                )
              ],
            )
          ],
        );
      },
    );
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
        'Corsa': const Icon(Icons.directions_run),
        'Bici': const Icon(Icons.directions_bike),
        'Camminata': const Icon(Icons.directions_walk),
        'Spinning': const Icon(Icons.directions_bike),
        'Nuoto': const Icon(Icons.pool),
        'Basket': const Icon(Icons.sports_basketball),
        'Tennis': const Icon(Icons.sports_tennis),
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

      Map<String, String> perfText = {};
      for (int i = 0; i < names.length; i++) {
        if (_performances[names[i]] == 0) {
          perfText[names[i]] = "any distance recorded";
        } else {
          perfText[names[i]] =
              "${_performances[names[i]]!.toStringAsFixed(2)} kilometers";
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
                          const Icon(Icons
                              .fitness_center),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${namesEn[act]} performance: ${perfText[act]!}',
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

  Widget _exerciseAdvice(bool ageInserted, bool showAlertForAge, int age) {
    if (!ageInserted && showAlertForAge) {
      return Column(
        children: [
          const Text(
            "Estimates were made assuming that your age is 25. \nAdd your personal information for a customized advice!",
            style: TextStyle(fontSize: 11.0, fontStyle: FontStyle.italic),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('To Personal Info',
                    style: TextStyle(fontSize: 11.0)),
                onPressed: () async {
                  await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PersonalInfo()));
                  final sp = await SharedPreferences.getInstance();
                  final name = sp.getString('name');
                  final userAge = sp.getString('userAge');
                  setState(() {
                    widget.provider.showAlertForAge = false;
                    if (userAge != null && name != null) {
                      widget.provider.nick = name;
                      widget.provider.age = int.parse(userAge);
                    }
                  });
                },
              ),
              TextButton(
                child: const Text('Do not ask again',
                    style: TextStyle(fontSize: 11.0)),
                onPressed: () {
                  setState(() {
                    widget.provider.showAlertForAge = false;
                  });
                },
              )
            ],
          )
        ],
      );
    } else {
      String message = "";
      if (age <= 17) {
        message =
            "Think of exercise as your secret power-up to grow strong and fast. It's like leveling up in a game, where every move makes you a hero in training. Keep active, and you'll build a fortress of bones and muscles! 🦸‍♂️🏃‍♀️";
      } else if (age > 17 && age < 65) {
        message =
            "Training is your fountain of youth. It keeps you fit, fights off the villains of stress and illness, and powers you through the jungle of life. Whether you're lifting weights or striking a yoga pose, keep moving. It's your armor in the daily grind. 🏋️‍♂️🧘‍♀️";
      } else {
        message =
            "Exercise is your magic wand for an energetic golden age. Every step is a victory, keeping the spells of aging at bay. Walk, dance, or garden—each move is a triumph for staying young at heart and nimble as a cat! 🚶‍♂️💃🌼";
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(message, style: const TextStyle(fontSize: 11.0)),
        const Text("- National Foundation of Exercise",
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11.0))
      ]);
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
                      const Text(
                          'How much did you work out everyday during this week?',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold)),
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
                                    .exerciseData),
                              ),
                      ),
                      // GOAL BUTTON
                      (_currentWeek)
                          ? Card(
                              elevation: 5,
                              child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  leading: _goalDisable
                                      ? const Icon(Icons.info_outline)
                                      : const Icon(Icons
                                          .run_circle_outlined),
                                  tileColor:
                                      const Color.fromARGB(255, 227, 211, 244),
                                  title: _goalDisable
                                      ? const Text('Some suggestions!')
                                      : const Text("Set a goal!"),
                                  subtitle: _goalDisable
                                      ? const Text(
                                          'I want to help you to reach your goal easily, click here!')
                                      : const Text(
                                          'Find a good motivation to move'),
                                  hoverColor:
                                      const Color.fromARGB(255, 227, 211, 244),
                                  onTap: () async {
                                    if (_goalDisable) {
                                      await launchUrl(Uri.parse(
                                          'https://www.aidstation.com.au/blogs/news/10-proven-tips-for-setting-and-achieving-your-athletic-goals'));
                                    } else {
                                      await _notifyOnePossibilityGoal();
                                      if (_goalDisable) {
                                        showGeneralDialog(
                                          barrierDismissible: true,
                                          barrierLabel: "",
                                          transitionDuration:
                                              const Duration(milliseconds: 200),
                                          context: context,
                                          pageBuilder: (context, animation1, animation2) {
                                            return Container();
                                          },
                                          transitionBuilder:
                                              (context, a1, a2, widget) {
                                            return SlideTransition(
                                              position: Tween(
                                                      begin: const Offset(0, 1),
                                                      end: const Offset(0, 0)).animate(a1),
                                              child: FadeTransition(
                                                opacity: Tween<double>(
                                                        begin: 0.5, end: 1.0).animate(a1),
                                                child: AlertDialog(
                                                  backgroundColor:
                                                      const Color.fromARGB(255, 242, 239, 245),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(20),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Text('How strong are you this week?',
                                                            style: TextStyle(
                                                              fontWeight:FontWeight.bold),
                                                          ),
                                                          const SizedBox(height: 20),
                                                          Card(
                                                              elevation: 3,
                                                              color: Colors.purple[100],
                                                              child: ListTile(
                                                                  title: const Text('Lazy level'),
                                                                  subtitle: const Text('Minimum activity acceptable to live in a healthy way',
                                                                    style: TextStyle(
                                                                        fontSize: 11),
                                                                  ),
                                                                  trailing:
                                                                      const Icon(Icons.battery_0_bar),
                                                                  iconColor: Colors.black,
                                                                  onTap: () async {
                                                                    Navigator.of(context).pop();
                                                                    setState(() {
                                                                      _level = 'Lazy';
                                                                      _goalDisable = true;
                                                                    });
                                                                    _setGoal(_level);
                                                                    final sp = await SharedPreferences.getInstance();
                                                                    String currentWeekKey = _getCurrentWeekIdentifier();
                                                                    sp.setDouble('percentage_$currentWeekKey', _percentage);
                                                                    sp.setString('level_$currentWeekKey', _level);
                                                                    sp.setBool('goal_$currentWeekKey',  true);
                                                                    for (var act in _performances.keys) {
                                                                      sp.setDouble("${act}_$currentWeekKey", _performances[act]!);
                                                                    }
                                                                  },),),
                                                          Card(
                                                              elevation: 3,
                                                              color: Colors.purple[200],
                                                              child: ListTile(
                                                                  title: const Text('Medium level'),
                                                                  subtitle: const Text('Medium activity to live in a healthy way',
                                                                    style: TextStyle(
                                                                        fontSize: 11),
                                                                  ),
                                                                  trailing:
                                                                      const Icon(Icons.battery_3_bar),
                                                                  iconColor: Colors.black,
                                                                  onTap: () async {
                                                                    Navigator.of(context).pop();
                                                                    setState(() {
                                                                      _level = 'Medium';
                                                                      _goalDisable = true;
                                                                    });
                                                                    _setGoal(_level);
                                                                    final sp = await SharedPreferences.getInstance();
                                                                    String currentWeekKey = _getCurrentWeekIdentifier();
                                                                    sp.setDouble('percentage_$currentWeekKey', _percentage);
                                                                    sp.setString('level_$currentWeekKey', _level);
                                                                    sp.setBool('goal_$currentWeekKey', true);
                                                                    for (var act in _performances.keys) {
                                                                      sp.setDouble("${act}_$currentWeekKey", _performances[act]!);
                                                                    }
                                                                  },
                                                                  ),
                                                                  ),
                                                          Card(
                                                              elevation: 3,
                                                              color: Colors.purple[300],
                                                              child: ListTile(
                                                                  title: const Text('Hard level'),
                                                                  subtitle:
                                                                      const Text('Strong activity life',
                                                                    style: TextStyle(
                                                                        fontSize: 11),
                                                                  ),
                                                                  trailing:
                                                                      const Icon(Icons.battery_full),
                                                                  iconColor:Colors.black,
                                                                  onTap: () async {
                                                                    Navigator.of(context).pop();
                                                                    setState(() {
                                                                      _level = 'Hard';
                                                                      _goalDisable = true;
                                                                    });
                                                                    _setGoal(_level);
                                                                    final sp = await SharedPreferences.getInstance();
                                                                    String currentWeekKey = _getCurrentWeekIdentifier();
                                                                    sp.setDouble('percentage_$currentWeekKey', _percentage);
                                                                    sp.setString('level_$currentWeekKey', _level);
                                                                    sp.setBool('goal_$currentWeekKey', true);
                                                                    for (var act in _performances.keys) {
                                                                      sp.setDouble("${act}_$currentWeekKey", _performances[act]!);
                                                                    }
                                                                  },
                                                                  ),
                                                                  ),
                                                          const SizedBox(height: 20),
                                                          TextButton(
                                                            child: const Text('Close'),
                                                            onPressed: () {
                                                              setState(() {
                                                                _goalDisable = false;
                                                              });
                                                              Navigator.of(context).pop();
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
                                      }
                                    }
                                  }),
                            )
                          :

                          // PERCENTAGE
                          const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _showPercentage(),

                            if (_goalDisable) ...[
                              ReachedGoal(reachGoal: _reachGoal)
                            ],

                            // LATERAL TEXT
                            const SizedBox(width: 20),
                            _lateralText()
                          ],
                        ),
                      ),

                      // SURVEY
                      const SizedBox(height: 10),
                      (_currentWeek)
                          ? Card(
                              elevation: 5,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                leading: const Icon(
                                  Icons.live_help,
                                ),
                                tileColor:
                                    const Color.fromARGB(255, 227, 211, 244),
                                title: const Text(
                                    'Survey of the day'),
                                subtitle: _buttonClickedToday
                                    ? const Text('Get something more')
                                    : const Text(
                                        'Tell me about your activity',
                                      ),
                                trailing: _buttonClickedToday
                                    ? Icon(Icons.done_all,
                                        color: Colors.lightGreen.shade900)
                                    : null,
                                onTap: () async {
                                  await showGeneralDialog(
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
                                          scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
                                          child: FadeTransition(
                                            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
                                            child: AlertDialog(
                                              backgroundColor:
                                                  const Color.fromARGB(255, 242, 239, 245),
                                              content: SingleChildScrollView(
                                                child: Container(
                                                  padding: const EdgeInsets.all(5),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      _exToday
                                                          ? SliderWidget(_buttonClickedToday)
                                                          : CardDialog(_buttonClickedToday), // CARD HERE
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
                          : const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Card(
                          elevation: 5,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isExerciseCardExpanded = !_isExerciseCardExpanded;
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  leading: const Icon(
                                    Icons.fitness_center,
                                  ),
                                  tileColor: const Color.fromARGB(255, 227, 211, 244),
                                  title: const Text(
                                    "Why sport is important for YOU",
                                  ),
                                  subtitle: const Text('Tap to learn more'),
                                ),
                                if (_isExerciseCardExpanded)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: _exerciseAdvice(
                                        widget.provider.ageInserted,
                                        widget.provider.showAlertForAge,
                                        widget.provider.age),
                                  ),
                              ],
                            ),
                          ),
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
  List<double> minOfEx = [];
  List<PieChart?> pieList = [];
  List<String?> legend = [];
  List<String> names = getNames(exerciseDataList);

  for (ExerciseData data in exerciseDataList) {
    minOfEx.add(data.duration);
    pieList.add(_buildPieChart([data], true));

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
  Map<String, double> total = {};
  double t = 0;
  Set<String> names = {};

  if (exerciseDataList.length > 1) {
    for (var data in exerciseDataList) {
      for (var act in data.actNames) {
        total[act] = (total[act] ?? 0) + (data.activities[act]?[0] ?? 0);
        names.add(act);
        t += data.activities[act]?[0] ?? 0;
      }
    }
  } else {
    for (var act in exerciseDataList[0].actNames) {
      total[act] =
          (total[act] ?? 0) + (exerciseDataList[0].activities[act]?[0] ?? 0);
      names.add(act);
      t += exerciseDataList[0].activities[act]?[0] ?? 0;
    }
  }
  Map<String, double> percentages = {};
  if (t == 0) {
    for (var act in names) {
      percentages[act] = 0;
    }
  } else {
    for (var act in names) {
      percentages[act] = (total[act]! / t) * 100;
    }
  }
  return percentages;
}

List<String> getNames(List<ExerciseData> exerciseDataList) {
  List<String> names = [];
  for (var data in exerciseDataList) {
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

  List<String> activityNames = exerciseData[0].actNames;
  Map<String, Color> colori = getColorForActivity(activityNames);

  List<PieChartSectionData> sections = activityNames.map((activity) {
    return PieChartSectionData(
      value: (calculatePercentage(exerciseData)![activity]),
      color: colori[
          activity],
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

Color getRandomPurpleColor() {
  Random random = Random();
  int red = 128 + random.nextInt(128);
  int green = 0;
  int blue = 128 + random.nextInt(128);
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
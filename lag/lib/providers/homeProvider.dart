import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/heartratedata.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/utils/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeProvider extends ChangeNotifier {
  //List<HR> heartRates = [];
  List<int> heartRates = []; // MOMENTANEO
  List<SleepData> sleepData = [];
  List<HeartRateData> heartRateData = [];
  List<ExerciseData> exerciseData = [];

  double score = 0;

  String nick = 'User';

  DateTime showDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime? monday;
  DateTime? sunday;

  final Impact impact = Impact();

  // constructor of provider which manages the fetching of all data from the servers and then notifies the ui to build
  // HomeProvider() {getDataOfDay(showDate);}
  HomeProvider() {_init();}

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    final name = sp.getString('name');
    if (name != null) {
      nick = name;
    }

    // Fetch data 
    getDataOfDay(showDate);
    getDataOfWeek(showDate);
  }

  // method to get the data of the chosen day
  void getDataOfDay(DateTime showDate) async {
    showDate = DateUtils.dateOnly(showDate);
    this.showDate = showDate;
    _loading(); 
    //heartRates = await impact.getDataFromDay(showDate);
    fetchAllData(showDate.toString());
    heartRates = [1,2,3]; // MOMENTANEO

    score = Random().nextDouble() * 100;
    print('Got data for $showDate: ${heartRates.length}');
    notifyListeners();
  }


  // method to get the data of the chosen week
  void getDataOfWeek(DateTime showDate) async {
    DateTime monday = showDate.subtract(Duration(days: showDate.weekday - DateTime.monday));
    DateTime sunday = monday.add(Duration(days: 6));
    
    DateFormat dateFormat = DateFormat('E, d MMM');
    String formattedMonday = dateFormat.format(monday);
    String formattedSunday = dateFormat.format(sunday);

    String dateRange = '$formattedMonday - $formattedSunday';

    this.monday = monday;
    this.sunday = sunday;
    
    _loading(); 

    // heartRates = await impact.getDataFromWeek(monday, sunday);
    heartRates = [1, 2, 3]; // Esempio temporaneo

    score = Random().nextDouble() * 100;
    print('Got data for week from $monday to $sunday: ${heartRates.length}');
    notifyListeners();
    print('\n $dateRange \n');
  }

  //Method to fetch sleep data from the server
  void fetchSleepData(String day) async {
    day = day.substring(0,10);
    sleepData = [];
    //Get the response
    final data = await Impact.fetchSleepData(day);

    //if OK parse the response adding all the elements to the list, otherwise do nothing
    if (data != null) {
      if (!data['data'].isEmpty){
        sleepData.add(SleepData.fromJson(data['data']['date'], data['data']));
        print(sleepData.last);
      }
      notifyListeners();
    }//if
  }//fetchSleepData

  void fetchHeartRateData(String day) async {
    day = day.substring(0,10);
    heartRateData = [];
    //Get the response
    final data = await Impact.fetchHeartRateData(day);

    //if OK parse the response adding all the elements to the list, otherwise do nothing
    if (data != null) {
      if (!data['data'].isEmpty){
        heartRateData.add(HeartRateData.fromJson(data['data']['date'], data['data']));
        print(heartRateData.last);
      }
      notifyListeners();
    }//if
  }//fetchHeartRateData

  void fetchExerciseData(String day) async {
    day = day.substring(0,10);
    exerciseData = [];
    //Get the response
    final data = await Impact.fetchExerciseData(day);

    //if OK parse the response adding all the elements to the list, otherwise do nothing
    if (data != null) {
      if (!data['data'].isEmpty){
        exerciseData.add(ExerciseData.fromJson(data['data']['date'], data['data']));
        print(exerciseData.last);
      }
      notifyListeners();
    }//if
  }//fetchExerciseData

  void fetchAllData(String day) async {
    fetchExerciseData(day);
    fetchHeartRateData(day);
    fetchSleepData(day);

  }//fetchAllData

  // method to give a loading ui feedback to the user
  void _loading() {
    heartRates = [];
    score = 0;
    notifyListeners();
  }
}

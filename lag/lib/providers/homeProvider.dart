import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/heartratedata.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/utils/impact.dart';
//import 'package:provider/provider.dart';
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
  DateTime start = DateTime.now().subtract(const Duration(days: 7));
  DateTime end = DateTime.now().subtract(const Duration(days: 1));

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
    //getDataOfDay(showDate);
    getDataOfWeek(start);
  }


/*
  // method to get the data of the chosen day
  Future<void> getDataOfDay(DateTime showDate) async {
    showDate = DateUtils.dateOnly(showDate);
    this.showDate = showDate;
    _loading(); 
    //heartRates = await impact.getDataFromDay(showDate);
    //await fetchAllData(showDate.toString());
    //heartRates = [1,2,3]; // MOMENTANEO

    score = Random().nextDouble() * 100;
    print('Got data for $showDate: ${heartRates.length}');
    notifyListeners();
  }

  */
  
  double sleepAvg() {
    if(sleepData.isEmpty){return 0.0;}
    double total = 0;
    int counter = 0;
    for(int i=0;i<sleepData.length;i++){
      if(sleepData[i].duration!=null){
        counter = counter + 1;
        total = total + sleepData[i].duration;
      }
    }
    return double.parse((total / counter).toStringAsFixed(1));
  }

  double exerciseDuration(){
    if(exerciseData.isEmpty){return 0.0;}
    double total = 0;
    for(int i=0;i<exerciseData.length;i++){
      total = total + exerciseData[i].duration;
    }
    return double.parse((total).toStringAsFixed(1));
  }

  // method to get the data of the chosen week
  Future<void> getDataOfWeek(DateTime showDate) async {
    DateTime start = showDate;
    DateTime end = start.add(Duration(days: 6));
    
    DateFormat dateFormat = DateFormat('E, d MMM');
    String formattedStart = dateFormat.format(start);
    String formattedEnd = dateFormat.format(end);

    String dateRange = '$formattedStart - $formattedEnd';

    this.start = start;
    this.end = end;

    sleepData = [];
    heartRateData = [];
    exerciseData = [];

    //await fetchSleepData(monday.toString(), sunday.toString());
    await fetchAllData(start.toString(), end.toString());
    
    _loading(); 

    // heartRates = await impact.getDataFromWeek(monday, sunday);
    //heartRates = [1, 2, 3]; // Esempio temporaneo

    score = Random().nextDouble() * 100;
    print('Got data for week from $start to $end');//: ${heartRates.length}');
    notifyListeners();
    print('\n $dateRange \n');
  }

  //Method to fetch sleep data from the server
  Future<void> fetchSleepData(String startDay, String endDay) async {
    startDay = startDay.substring(0,10);
    endDay = endDay.substring(0,10);
    //sleepData = [];
    //Get the response
    final data = await Impact.fetchSleepData(startDay, endDay);

    //if OK parse the response adding all the elements to the list, otherwise do nothing
    if (data != null) {
      if (!data['data'].isEmpty){
        for(int i=0; i<data['data'].length; i++)
        {
          if(!data['data'][i]['data'].isEmpty)
          {
            sleepData.add(SleepData.fromJson(data['data'][i]['date'], data['data'][i]));
          }
          else
          {
            sleepData.add(SleepData.empty(data['data'][i]['date'], data['data'][i]));
          }
          print(sleepData.last);
        }
      }
      notifyListeners();
    }//if
  }//fetchSleepData

  Future<void> fetchHeartRateData(String startDay, String endDay) async {
    startDay = startDay.substring(0,10);
    endDay = endDay.substring(0,10);
    //heartRateData = [];
    //Get the response
    final data = await Impact.fetchHeartRateData(startDay, endDay);

    //if OK parse the response adding all the elements to the list, otherwise do nothing
    if (data != null) {
      if (!data['data'].isEmpty){
        for(int i=0; i<data['data'].length; i++)
        {
          if(!data['data'][i]['data'].isEmpty)
          {
            heartRateData.add(HeartRateData.fromJson(data['data'][i]['date'], data['data'][i]));
          }
          else
          {
            heartRateData.add(HeartRateData.empty(data['data'][i]['date'], data['data'][i]));
          }
          print(heartRateData.last);
        }
      }
      notifyListeners();
    }//if
  }//fetchHeartRateData

  Future<void> fetchExerciseData(String startDay, String endDay) async {
    startDay = startDay.substring(0,10);
    endDay = endDay.substring(0,10);
    //exerciseData = [];
    //Get the response
    final data = await Impact.fetchExerciseData(startDay, endDay);

    //if OK parse the response adding all the elements to the list, otherwise do nothing
    if (data != null) {
      if (!data['data'].isEmpty){
        for(int i=0; i<data['data'].length; i++)
        {
          if(!data['data'][i]['data'].isEmpty)
          {
            exerciseData.add(ExerciseData.fromJson(data['data'][i]['date'], data['data'][i]));
          }
          else
          {
            exerciseData.add(ExerciseData.empty(data['data'][i]['date'], data['data'][i]));
          }
          print(exerciseData.last);
        }
      notifyListeners();
      }}//if
  }//fetchExerciseData

  Future<void> fetchAllData(String startDay, String endDay) async {
    await fetchExerciseData(startDay,endDay);
    await fetchHeartRateData(startDay,endDay);
    await fetchSleepData(startDay,endDay);

  }//fetchAllData

  // method to give a loading ui feedback to the user
  void _loading() {
    //heartRates = [];
    score = 0;
    notifyListeners();
  }
  
}

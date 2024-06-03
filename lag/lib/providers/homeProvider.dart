
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/heartratedata.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/utils/impact.dart';
//import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lag/algorithms/sleep_score.dart';


class HomeProvider extends ChangeNotifier { 
  //List<HR> heartRates = [];
  //List<int> heartRates = []; // MOMENTANEO
  List<SleepData> sleepData = [];
  List<HeartRateData> heartRateData = [];
  List<ExerciseData> exerciseData = [];
  Map<String, List<double>> sleepScores = {};

  double score = 0;

  String nick = 'User';
  
  DateTime showDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime monday = DateTime.now().subtract(const Duration(days: 1)).subtract(Duration(days: DateTime.now().subtract(const Duration(days: 1)).weekday - DateTime.monday));
  //DateTime start = DateTime.now().subtract(const Duration(days: 7));
  DateTime end = DateTime.now().subtract(const Duration(days: 1));
  DateTime start = DateTime.now().subtract(const Duration(days: 1)).subtract(Duration(days: DateTime.now().subtract(const Duration(days: 1)).weekday - DateTime.monday));
  
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
    getDataOfWeek(start, end);
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
  
  double rhrAvg() {
    if(heartRateData.isEmpty){return 0.0;}
    double total = 0;
    int counter = 0;
    for(int i=0;i<heartRateData.length;i++){
      if(heartRateData[i].value!=0){
        counter = counter + 1;
        total = total + heartRateData[i].value;
      }
    }
    print('${heartRateData[0]}');
    return double.parse((total / counter).toStringAsFixed(1));
  }
  
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
  Future<void> getDataOfWeek(DateTime start, DateTime end) async {
    //DateTime start = showDate;
    //DateTime end = start.add(const Duration(days: 6));
    
    DateFormat dateFormat = DateFormat('E, d MMM');
    String formattedStart = dateFormat.format(start);
    String formattedEnd = dateFormat.format(end);

    String dateRange = '$formattedStart - $formattedEnd';

    //this.start = start;
    //this.end = end;

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
    sleepScores = {};

    //if OK parse the response adding all the elements to the list, otherwise do nothing
    if (data != null) {
      if (!data['data'].isEmpty){
        if (data["data"] is List) {
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
            //print(sleepData.last);
          }
        } else {
          if(!data['data']['data'].isEmpty)
            {
              sleepData.add(SleepData.fromJson(data['data']['date'], data['data']));
            }
            else
            {
              sleepData.add(SleepData.empty(data['data']['date'], data['data']));
            }
            //print(sleepData.last);
        } 
        calculateSleepScore(startDay, endDay);
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
        if (data["data"] is List) {
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
            //print(heartRateData.last);
          }
        } else {
          if(!data['data']['data'].isEmpty)
            {
              heartRateData.add(HeartRateData.fromJson(data['data']['date'], data['data']));
            }
            else
            {
              heartRateData.add(HeartRateData.empty(data['data']['date'], data['data']));
            }
            //print(heartRateData.last);
        }
      }
      print('Got ${heartRateData[0]}');
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
        if (data["data"] is List) {
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
            //print(exerciseData.last);
          }
        } else {
          if(!data['data']['data'].isEmpty)
            {
              exerciseData.add(ExerciseData.fromJson(data['data']['date'], data['data']));
            }
            else
            {
              exerciseData.add(ExerciseData.empty(data['data']['date'], data['data']));
            }
            //print(exerciseData.last);
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

  void calculateSleepScore(String startDay, String endDay) async{
    sleepScores = await getSleepScore(sleepData);
    notifyListeners();
  }

  // methods to update start and end: dateSubtractor & dateAdder
  void dateSubtractor(DateTime start) {
    this.start = start.subtract(const Duration(days: 7));
    end = this.start.add(const Duration(days: 6));
    notifyListeners();
  }//dateSubtractor

  void dateAdder(DateTime start) {
    this.start = start.add(const Duration(days: 7));
    if (this.start.year == monday.year && this.start.month == monday.month && this.start.day == monday.day) {
      end = showDate;
    } else {
      end = this.start.add(const Duration(days: 6));
    }
    notifyListeners();
  }//dateAdder 

  
  
}



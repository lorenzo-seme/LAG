import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/heartratedata.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/utils/impact.dart';
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
  int age = 25;
  bool ageInserted = false;
  bool showAlertForAge = false;
  bool isReady = true;

  
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
    String? name = sp.getString('name');
    String? userAge = sp.getString('userAge');
    if (userAge != null){
      // age = ((DateTime.now().difference(DateTime.parse(dob))).inDays / 365).round();
      age = int.parse(sp.getString('userAge')!);
      ageInserted = true;
      showAlertForAge = false;
    } else {
      showAlertForAge = true;
    }
    if (name != null){
      nick = name;
    } else {
      nick = 'User';
    }

    // Fetch data 
    getDataOfWeek(start, end);
  }

    /*
  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    final name = sp.getString('name');
    final dob = sp.getString('dob');
    if (dob != null){
      age = ((DateTime.now().difference(DateTime.parse(dob))).inDays / 365).round();
      ageInserted = true;
    }
    if (name != null){
      nick = name;
    }
    //notifyListeners();
    // Fetch data 
    //getDataOfDay(showDate);
    getDataOfWeek(start, end);
  }
  */

  /*
  void updateName(String newName) {
    nick = newName;
    notifyListeners();
  }
  */

  /*
  Future<void> _init() async {
    await updateSP();
    //notifyListeners();
    // Fetch data 
    //getDataOfDay(showDate);
    getDataOfWeek(start, end);
  }
  */

  Future<void> updateSP() async{
    final sp = await SharedPreferences.getInstance();
    final name = sp.getString('name');
    final userAge = sp.getString('userAge');
    if (userAge != null){
      age = int.parse(sp.getString('userAge')!);
      ageInserted = true;
    } else {
      age = 25;
      ageInserted = false;
      showAlertForAge = true;
    }
    if (name != null){
      nick = name;
    } else {
      nick = 'User';
    }
    notifyListeners();
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

  bool exerciseToday() {
    DateTime today = DateTime.now().subtract(Duration(days: 1));
    int dayIndex = today.weekday -1 ;
    if (exerciseData[dayIndex].duration > 0) {
      return true;
    } else {
      return false;
    }
  }


  double exerciseDistance(){
    if(exerciseData.isEmpty){return 0.0;}
    double total = 0;
    for(int i=0;i<exerciseData.length;i++){
      total = total + exerciseData[i].distance;
    }
    return double.parse((total).toStringAsFixed(1));
  }
  

  Map<String, double> exerciseDistanceActivities(){ // exerciseData is a list, for each day
    Map<String, double> total = {};

    if(exerciseData.isEmpty){
      return total = {'Null' : 0};
      } else {
        for(int i=0; i<exerciseData.length; i++){
        if (exerciseData[i].actNames.length >= 1) {
          List<String> actName_day = exerciseData[i].actNames;
          for (String act in actName_day) {
            if (total[act] == null) {
              total[act] = 0;
            }
            total[act] = total[act]! + exerciseData[i].activities[act]![1];
            //print('names da exDistance2: ${act}_${total[act]}');
            }
        }
        }
      }
      print('exerciseDistance2 : $total');
      return total;
  }

  // method to get the data of the chosen week
  Future<void> getDataOfWeek(DateTime start, DateTime end) async {
    //DateTime start = showDate;
    //DateTime end = start.add(const Duration(days: 6));
    isReady = false;
    //notifyListeners()
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

    isReady = true;
    
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
        calculateSleepScore(sleepData);
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

  void calculateSleepScore(List<SleepData> sleepData) async{
    sleepScores = await getSleepScore(sleepData, this.age, this.ageInserted);
    notifyListeners();
  }

  // methods to update start and end: dateSubtractor & dateAdder
  Future<void> dateSubtractor(DateTime start) async{
    this.start = start.subtract(const Duration(days: 7));
    end = this.start.add(const Duration(days: 6));
    notifyListeners();
  }//dateSubtractor

  Future<void> dateAdder(DateTime start) async{
    this.start = start.add(const Duration(days: 7));
    if (this.start.year == monday.year && this.start.month == monday.month && this.start.day == monday.day) {
      end = showDate;
    } else {
      end = this.start.add(const Duration(days: 6));
    }
    notifyListeners();
  }//dateAdder 

  
  
}




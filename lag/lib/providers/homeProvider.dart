import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata2.dart';
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
  List<HeartRateData> monthlyHeartRateData = [];
  double lastMonthHR = 0;
  List<ExerciseData> exerciseData = [];
  Map<String, List<double>> sleepScores = {};
  List<String> months = [];
 
  double score = 0;

  String nick = 'User';
  int age = 25;
  bool ageInserted = false;
  bool showAlertForAge = false;
  bool isReady = true;
  bool todayMoodTracked = false;
  bool firstThoughtsubmitted = false;

  Future<void> saveMoodScore(DateTime date, int score) async {
    todayMoodTracked = true;
    final prefs = await SharedPreferences.getInstance();
    String key = 'mood_scores';
    Map<String, dynamic> moodScores = {};
    // Retrieve existing scores if any
    String? jsonString = prefs.getString(key);
    if (jsonString != null) {
      moodScores = json.decode(jsonString);
    }
    // Add/Update the score for the given date
    String dateString = date.toIso8601String().split('T').first; // Use only the date part
    await prefs.setString('lastMoodUpdate', dateString);
    moodScores[dateString] = score;
    // Save the updated dictionary back to shared preferences
    jsonString = json.encode(moodScores);
    await prefs.setString(key, jsonString);
    notifyListeners();
  }

  Future<int?> getMoodScore(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'mood_scores';
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    Map<String, dynamic> moodScores = json.decode(jsonString);
    String dateString = date.toIso8601String().split('T').first;
    return moodScores[dateString];
  }

  Future<void> saveMoodText(DateTime date, String text) async {
    firstThoughtsubmitted = true;
    final prefs = await SharedPreferences.getInstance();
    String key = 'mood_texts';
    Map<String, dynamic> moodTexts = {};
    // Retrieve existing data if any
    String? jsonString = prefs.getString(key);
    if (jsonString != null) {
      moodTexts = json.decode(jsonString);
    }
    // Add/Update the data for the given date
    String dateString = date.toIso8601String().split('T').first; 
    await prefs.setString('lastFirstThoughtUpdate', dateString);
    if (moodTexts.containsKey(dateString)) {
      moodTexts[dateString] = "${moodTexts[dateString]}\n\n'$text'";
    } else {
      moodTexts[dateString] = "'text'";
    }
    // Save the updated dictionary back to shared preferences
    jsonString = json.encode(moodTexts);
    await prefs.setString(key, jsonString);
  }

  Future<Map<String, dynamic>?> getMoodText() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'mood_texts';
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    Map<String, dynamic> moodTexts = json.decode(jsonString);
    return moodTexts;
  }

  
  DateTime showDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
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

    DateTime now = DateTime.now();
    String? lastMoodUpadte = sp.getString('lastMoodUpdate');
    if (lastMoodUpadte != null) {
      DateTime moodDate = DateTime.parse(lastMoodUpadte);
      if (moodDate.year == now.year && moodDate.month == now.month && moodDate.day == now.day) {
        todayMoodTracked = true;
      }
    }
    String? lastFirstThoughtUpdate = sp.getString('lastFirstThoughtUpdate');
    if (lastFirstThoughtUpdate != null) {
      DateTime firstThoughtDate = DateTime.parse(lastFirstThoughtUpdate);
      if (firstThoughtDate.year == now.year && firstThoughtDate.month == now.month && firstThoughtDate.day == now.day) {
        firstThoughtsubmitted = true;
      }
    }

    // Fetch data 
    getDataOfWeek(start, end, true);
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

  List<String> getPreviousSixMonths(DateTime date) {
    List<String> months = [];
    DateFormat monthFormat = DateFormat.MMMM();

    for (int i = 5; i >= 0; i--) {
      DateTime previousMonth = DateTime(date.year, date.month - i, date.day);
      String monthName = monthFormat.format(previousMonth);
      months.add(monthName);
    }

    return months;
  }
  /*
  double rhrAvg() {
    if(monthlyHeartRateData.isEmpty){return 0.0;}
    double total = 0;
    int counter = 0;
    for(int i=0;i<monthlyHeartRateData.length;i++){
      if(monthlyHeartRateData[i].value!=0){
        counter = counter + 1;
        total = total + monthlyHeartRateData[i].value;
      }
    }
    print('${heartRateData[0]}');
    return double.parse((total / counter).toStringAsFixed(1));
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

  
  double exerciseDistance(){
    if(exerciseData.isEmpty){return 0.0;}
    double total = 0;
    for(int i=0;i<exerciseData.length;i++){
      total = total + exerciseData[i].distance;
    }
    return double.parse((total).toStringAsFixed(1));
  }
  

  /*
  Map<String, double> exerciseDistance2(){
    Map<String, double> total = {
      'Corsa' : 0,
      'Bici' : 0,
      'Camminata' : 0
    };
    List<String> names = ['Corsa', 'Bici', 'Camminata'];
    if(exerciseData.isEmpty){
      return total;
      } 
    for (String act in names) {
      double tt = 0;
      for(int i=0;i<exerciseData.length;i++){
        if (exerciseData[i].activities.containsKey(act)) {
          tt = tt + exerciseData[i].activities[act]![1];
        }
        
        }
      total[act] = tt;
    }
    return total;
  }
  */

  Map<String, double> exerciseDistance2(){ // exerciseData is a list, for each day
    Map<String, double> total = {};

    if(exerciseData.isEmpty){
      return total = {'Null' : 0};
      } else {
        for(int i=0; i<exerciseData.length; i++){
        if (exerciseData[i].actNames.length >= 1) {
          List actName_day = exerciseData[i].actNames;
          for (String act in actName_day) {
              total[act] = exerciseData[i].activities[act]![1];
            }
        }
        }
      }
      print('exerciseDistance2 : $total');
      return total;
  }

  // method to get the data of the chosen week
  Future<void> getDataOfWeek(DateTime start, DateTime end, bool init) async {
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

    //await fetchSleepData(monday.toString(), sunday.toString());
    if(init){
      sleepData = [];
      heartRateData = [];
      exerciseData = [];
      await fetchAllData(start.toString(), end.toString(), yesterday.toString());
    } else {
      sleepData = [];
      exerciseData = [];
      await fetchExerciseSleep(start.toString(), end.toString());
    }

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

  Future<void> fetchMonthlyHeartRateData(String date, bool lastOnly) async {
    monthlyHeartRateData = [];
    date = date.substring(0,10);
    //print(date);
    List<String> months = [];
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date_obj = dateFormat.parse(date);
    DateFormat monthFormat = DateFormat("yyyy-MM");
    int num;
    if(!lastOnly)
    {
      num = 6;
      for (int i = 5; i >= 0; i--) {
        DateTime previousMonth = DateTime(date_obj.year, date_obj.month - i, date_obj.day);
        String monthNumber = monthFormat.format(previousMonth);
        months.add(monthNumber);
      }
    } else {
      num = 1;
      String monthNumber = monthFormat.format(DateTime(date_obj.year, date_obj.month, date_obj.day));
      months.add(monthNumber);
    }


    for(int i=0; i<num; i++){
        int startingDay = -6;
        int endingDay = 0;
        double sum = 0;
        int counter = 0;
      for(int j=0; j<5; j++){
        String start, end;
        startingDay = startingDay + 7;
        start = months[i] + "-" + startingDay.toString().padLeft(2, '0');
        if(i==num-1 && ((dateFormat.parse(start)).isAfter(date_obj))) //gestisce caso data di inizio futura
        {
          break;
        }
        if(j!=4)
        {
          endingDay = endingDay + 7;
          end = months [i] + "-" + endingDay.toString().padLeft(2, '0');
        } else {
          DateTime firstDayOfFollowingMonth;
          int month = int.parse(months[i].split('-')[1]);
          int year = int.parse(months[i].split('-')[0]);
          if (month == 12) {
            firstDayOfFollowingMonth = DateTime(year + 1, 1, 1);
          } else {
            firstDayOfFollowingMonth = DateTime(year, month + 1, 1);
          }
          DateTime lastDayOfCurrMonth = firstDayOfFollowingMonth.subtract(Duration(days: 1));
          endingDay = lastDayOfCurrMonth.day;
          end = months[i] + "-" + endingDay.toString().padLeft(2, '0');
          if(endingDay<startingDay) //gestisce caso febbraio con 28gg
          {
            break;
          }
        }
        if(i==num-1 && ((dateFormat.parse(end)).isAfter(date_obj)))  //gestisce caso data di fine futura
        {
          end = date_obj.toString().substring(0,10);
        }
        final data = await Impact.fetchHeartRateData(start, end);
        if (data != null) {
          if (!data['data'].isEmpty){
            if (data["data"] is List) {
              for(int k=0; k<data['data'].length; k++)
              {
                if(!data['data'][k]['data'].isEmpty)
                {
                  sum = sum + data['data'][k]['data']['value'];
                  counter = counter + 1;
                }
              }
            } else {
              if(!data['data']['data'].isEmpty)  
              {
                sum = sum + data['data']['data']['value'];
                counter = counter + 1;
              }
            }
          }
        }
      }
      (sum == 0)
              ? monthlyHeartRateData.add(HeartRateData.givenValue(months[i], 0.0))
              : monthlyHeartRateData.add(HeartRateData.givenValue(months[i], double.parse((sum/counter).toStringAsFixed(1))));
    }//for

    lastMonthHR = monthlyHeartRateData.last.value;

    notifyListeners();
    //print(monthlyHeartRateData[0]);
  }
/*
  Future<void> fetchHeartRateData(String date) async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime date_obj = dateFormat.parse(date);
    DateFormat monthFormat = DateFormat("yyyy-MM");
    date = date.substring(0,10);
    int startingDay = -6;
    int endingDay = 0;
    heartRateData = [];
    DateTime month_obj = DateTime(date_obj.year, date_obj.month, date_obj.day);
    String monthNumber = monthFormat.format(month_obj);

    for(int j=0; j<5; j++){
        String start, end;
        startingDay = startingDay + 7;
        start = date.substring(0,8) + startingDay.toString().padLeft(2, '0');
        if((dateFormat.parse(start)).isAfter(date_obj)) //gestisce caso data di inizio futura
        {
          break;
        }
        if(j!=4)
        {
          endingDay = endingDay + 7;
          end = monthNumber + "-" + endingDay.toString().padLeft(2, '0');
        } else {
          DateTime firstDayOfFollowingMonth;
          int month = int.parse(monthNumber.split('-')[1]);
          int year = int.parse(monthNumber.split('-')[0]);
          if (month == 12) {
            firstDayOfFollowingMonth = DateTime(year + 1, 1, 1);
          } else {
            firstDayOfFollowingMonth = DateTime(year, month + 1, 1);
          }
          DateTime lastDayOfCurrMonth = firstDayOfFollowingMonth.subtract(Duration(days: 1));
          endingDay = lastDayOfCurrMonth.day;
          end = monthNumber + "-" + endingDay.toString().padLeft(2, '0');
          if(endingDay<startingDay) //gestisce caso febbraio con 28gg
          {
            break;
          }
        }
        if((dateFormat.parse(end)).isAfter(date_obj))  //gestisce caso data di fine futura
        {
          end = date_obj.toString().substring(0,10);
        }
        end = date.substring(0,8) + endingDay.toString().padLeft(2, '0');
        final data = await Impact.fetchHeartRateData(start, end);
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
        }//if
    }
    print('Got ${heartRateData.length}');
    notifyListeners();
  }//fetchHeartRateData
*/

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
  

  Future<void> fetchAllData(String startDay, String endDay, String date) async {
    await fetchExerciseData(startDay,endDay);
    await fetchSleepData(startDay,endDay);
    await fetchMonthlyHeartRateData(date, true);
  }//fetchAllData

  Future<void> fetchExerciseSleep(String startDay, String endDay) async {
    await fetchExerciseData(startDay,endDay);
    await fetchSleepData(startDay,endDay);
  }

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




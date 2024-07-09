import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/algorithms/exercise_score.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/models/heartratedata.dart';
import 'package:lag/models/sleepdata.dart';
import 'package:lag/services/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lag/algorithms/sleep_score.dart';


class HomeProvider extends ChangeNotifier { 
  List<SleepData> sleepData = [];
  List<HeartRateData> heartRateData = [];
  List<HeartRateData> monthlyHeartRateData = [];
  double lastMonthHR = 0;
  List<ExerciseData> exerciseData = [];
  List<double> exerciseScores = [];
  Map<String, List<double>> sleepScores = {};
  List<double> moodScores = [];
  double plantScore = 0;
  double exerciseScore = 0;
  List<String> months = [];
 

  String nick = 'User';
  int age = 25;
  bool ageInserted = false;
  bool showAlertForAge = false;
  bool isReady = true;
  bool todayMoodTracked = false;
  bool firstThoughtsubmitted = false;

  DateTime showDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
  DateTime monday = DateTime.now().subtract(const Duration(days: 1)).subtract(Duration(days: DateTime.now().subtract(const Duration(days: 1)).weekday - DateTime.monday));
  DateTime end = DateTime.now().subtract(const Duration(days: 1));
  DateTime start = DateTime.now().subtract(const Duration(days: 1)).subtract(Duration(days: DateTime.now().subtract(const Duration(days: 1)).weekday - DateTime.monday));
  
  final Impact impact = Impact();

  // constructor of provider which manages the fetching of all data from the servers and then notifies the ui to build
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

  // method to get the data of the chosen week
  Future<void> getDataOfWeek(DateTime start, DateTime end, bool init) async {
    isReady = false;

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
    moodScores = [];
    
    await calculateMoodScores();
    await imageToShow(sleepScores["scores"], exerciseScores, moodScores);   // da valutare se gestire null di exerciseScores

    isReady = true;

    notifyListeners();
  }

  Future<void> fetchAllData(String startDay, String endDay, String date) async {
    await fetchExerciseData(startDay,endDay);
    await fetchSleepData(startDay,endDay);
    await fetchMonthlyHeartRateData(date, true);
  }//fetchAllData

  Future<void> fetchExerciseSleep(String startDay, String endDay) async {
    await fetchExerciseData(startDay,endDay);
    await fetchSleepData(startDay,endDay);
  }

  Future<void> fetchExerciseData(String startDay, String endDay) async {
    startDay = startDay.substring(0,10);
    endDay = endDay.substring(0,10);
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
        }
      calculateExerciseScore(exerciseData);
      }
    }//if
    notifyListeners();
  }//fetchExerciseData

  void calculateExerciseScore(List<ExerciseData> exerciseData) async{
    exerciseScores = await getExerciseScore(exerciseData, this.age, this.ageInserted).map((score) => score.toDouble()).toList();
    notifyListeners();
  }

  //Method to fetch sleep data from the server
  Future<void> fetchSleepData(String startDay, String endDay) async {
    startDay = startDay.substring(0,10);
    endDay = endDay.substring(0,10);
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
        } 
        calculateSleepScore(sleepData);
      }
    }//if
    notifyListeners();
  }//fetchSleepData

  void calculateSleepScore(List<SleepData> sleepData) async{
    sleepScores = await getSleepScore(sleepData, this.age, this.ageInserted);
    notifyListeners();
  }

  Future<void> fetchMonthlyHeartRateData(String date, bool lastOnly) async {
    monthlyHeartRateData = [];
    date = date.substring(0,10);
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
        if(i==num-1 && ((dateFormat.parse(start)).isAfter(date_obj))) //manages start in the future
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
          if(endingDay<startingDay) //manages february with 28 days
          {
            break;
          }
        }
        if(i==num-1 && ((dateFormat.parse(end)).isAfter(date_obj)))  //manages end in the future
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
  }
  

  Future<void> imageToShow(List<double>? sleepScores, List<double> exerciseScores, List<double> moodScores) async {
    plantScore = 0;
    double sleepValue = 0;
    double exerciseValue = 0;
    double moodValue = 0;

    if(sleepScores != null)
    {
      for (double value in sleepScores) {
        if (value > 85) {
          sleepValue = sleepValue + 2;
        } else if (value < 60) {
        } 
        else {
          sleepValue++;
        }
      }
      sleepValue = sleepValue/(7*2);
    }


    for (double value in exerciseScores) {
      if (value > 85) {
        exerciseValue = exerciseValue + 2;
      } else if (value < 60) {
      } 
      else {
        exerciseValue++;
      }
    }
    exerciseValue = exerciseValue/(7*2);


    for (double value in moodScores) {
      moodValue = moodValue + 2*value;
    }
    moodValue = moodValue/(7*2);

    plantScore = (4*sleepValue + 4*exerciseValue + 2*moodValue);
    notifyListeners();
  } //imageToShow
/*
  List<DateTime> generateDaysOfWeek(DateTime start, DateTime end) {
    List<DateTime> daysOfWeek = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      daysOfWeek.add(start.add(Duration(days: i)));
    }
    notifyListeners();
    return daysOfWeek;
  }*/

List<DateTime> generateDaysOfWeek(DateTime start, DateTime end) {
  List<DateTime> daysOfWeek = [];
  
  DateTime currentDate = start;
  while (!currentDate.isAfter(end)) {
    daysOfWeek.add(currentDate);
    currentDate = currentDate.add(Duration(days: 1));
  }

  notifyListeners();
  return daysOfWeek;
}

  Future<void> calculateMoodScores() async{
    List<DateTime> daysOfWeek = generateDaysOfWeek(start, end);
    for (DateTime day in daysOfWeek) {
      double score = 0;
      if (await getMoodScore(day) != null) {
        score = score + 0.5;
      }
      if (await getMoodText() != null) {
        if ((await getMoodText())![day] != null) {
          score = score + 0.5;
        }
      }
      moodScores.add(score);
    }
    notifyListeners();
  }

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
      moodTexts[dateString] = "'$text'";
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
    calculateSleepScore(sleepData);
    calculateExerciseScore(exerciseData);

    notifyListeners();
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
            }
        }
        }
      }
      return total;
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
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class Impact{
 
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';
  
  static String sleepEndpoint = 'data/v1/sleep/patients/';
  static String heartRateEndpoint = 'data/v1/resting_heart_rate/patients/';
  static String exerciseEndpoint = 'data/v1/exercise/patients/';

  static String patientUsername = 'Jpefaq6m58';

  //This method allows to check if the IMPACT backend is up
  static Future<bool> isImpactUp() async {
    //Create the request
    final url = Impact.baseUrl + Impact.pingEndpoint;
    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url));
    //Just return if the status code is OK
    return response.statusCode == 200;
  } //_isImpactUp

  //This method allows to obtain the JWT token pair from IMPACT and store it in SharedPreferences
  static Future<int> getAndStoreTokens(String username, String password) async {
    //Create the request
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};
    //Get the response
    print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);
    //If response is OK, decode it and store the tokens. Otherwise do nothing.
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    } 
    //Just return the status code
    return response.statusCode;
  } //_getAndStoreTokens



  //This method allows to refrsh the stored JWT in SharedPreferences
  static Future<int> refreshTokens() async {
    //Create the request
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    if (refresh != null) {
      final body = {'refresh': refresh};
      //Get the response
      print('Calling: $url');
      final response = await http.post(Uri.parse(url), body: body);
      //If the response is OK, set the tokens in SharedPreferences to the new values
      if (response.statusCode == 200) { 
        final decodedResponse = jsonDecode(response.body);
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      } 
      //Just return the status code
      return response.statusCode;
    }
    return 401; 
  } //_refreshTokens

  static Future<dynamic> fetchSleepData(String startDay, String endDay) async {
    //Get the stored access token (Note that this code does not work if the tokens are null)
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');
    //If access token is expired, refresh it
    if(JwtDecoder.isExpired(access!)){
      await Impact.refreshTokens();
      access = sp.getString('access');
    }
    //Create the (representative) request
    String url = "";
    if (startDay == endDay) {
      url = baseUrl + sleepEndpoint + patientUsername + '/day/$startDay';
    } else {
      url = baseUrl + sleepEndpoint + patientUsername + '/daterange/start_date/$startDay/end_date/$endDay/';
    }
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    //if OK parse the response, otherwise return null
    var result = null;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    } 
    //Return the result
    return result;
  } //_fetchSleepData

  static Future<dynamic> fetchHeartRateData(String startDay, String endDay) async {
    //Get the stored access token (Note that this code does not work if the tokens are null)
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');
    //If access token is expired, refresh it
    if(JwtDecoder.isExpired(access!)){
      await Impact.refreshTokens();
      access = sp.getString('access');
    }
    //Create the (representative) request
    String url = "";
    if (startDay == endDay) {
      url = baseUrl + heartRateEndpoint + patientUsername + '/day/$startDay';
    } else {
      url = baseUrl + heartRateEndpoint + patientUsername + '/daterange/start_date/$startDay/end_date/$endDay/';
    }
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    //if OK parse the response, otherwise return null
    var result = null;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    } 
    //Return the result
    return result;
  } //_fetchHeartRateData

  static Future<dynamic> fetchExerciseData(String startDay, String endDay) async {
    //Get the stored access token (Note that this code does not work if the tokens are null)
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');
    //If access token is expired, refresh it
    if(JwtDecoder.isExpired(access!)){
      await Impact.refreshTokens();
      access = sp.getString('access');
    }
    //Create the (representative) request
    String url = "";
    if (startDay == endDay) {
      url = baseUrl + exerciseEndpoint + patientUsername + '/day/$startDay';
    } else {
      url = baseUrl + exerciseEndpoint + patientUsername + '/daterange/start_date/$startDay/end_date/$endDay/';
    }
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    //if OK parse the response, otherwise return null
    var result = null;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    } 
    //Return the result
    return result;
  } //_fetchExerciseData
}//Impact 


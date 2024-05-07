import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Impact{

  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';
  
  static String stepsEndpoint = 'data/v1/steps/patients/';

  static String username = 'gq9MVRmZK8';
  static String password = '12345678!';

  static String patientUsername = 'Jpefaq6m58';


  //This method allows to check if the IMPACT backend is up
  // AGGIUNGERE NEL PULSANTE DI LOGIN, RESTITUISCE UN MESSAGGIO (PER CAPIRE SE IL SERVER è OK)
  Future<bool> isImpactUp() async {
    //Create the request
    final url = Impact.baseUrl + Impact.pingEndpoint;

    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url));

    //Just return if the status code is OK
    return response.statusCode == 200;
  } //_isImpactUp



  //This method allows to obtain the JWT token pair from IMPACT and store it in SharedPreferences
  Future<int> getAndStoreTokens(String username, String password) async {
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
    } //if

    //Just return the status code
    return response.statusCode;
  } //_getAndStoreTokens



  //This method allows to refrsh the stored JWT in SharedPreferences
  Future<int> refreshTokens() async {
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
      } //if

      //Just return the status code
      return response.statusCode;
    }
    return 401; // O NON SIAMO MAI STATI AUTENTICATI (NON ESISTONO I TOKEN NELLE SHARED PREFERENCES) OPPURE I TOKEN SONO SCADUTI
    // IN QUESTO CASO SFRUTTIAMO IL FATTO DI AVER SALVATO NELLE SP CRIPTATE USERNAME E PASSWORD,
    // IN MODO CHE LUI POSSA RIFARE IL LOGIN IN AUTOMATICA (SENZA MANDARCI NELLA LOGIN PAGE)
    // QUINDI, AL PRIMO LOGIN, AGGIUNGIAMO LA SPUNTA DEL "REMEMBER ME"
    // SE NON METTI SPUNTA, TI RIMANDA ALLA LOGIN PAGE
  } //_refreshTokens
}//Impact 


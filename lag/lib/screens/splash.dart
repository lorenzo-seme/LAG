import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lag/screens/home.dart';
import 'package:lag/screens/login.dart';
import 'package:lag/utils/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  // Method for navigation SplashPage -> HomePage
  void _toHomePage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => const Home()));
  } //_toHomePage

  // Method for navigation SplashPage -> LoginPage
  void _toLoginPage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: ((context) => Login())));
  } //_toLoginPage

  Future<void> _checkLogin(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    final access = sp.getString('access');
    if (access != null && !(JwtDecoder.isExpired(access))) { // 1. CONTROLLA DI AVERE L'ACCESS NELLE SP
      _toHomePage(context);
    } else {
      final result = await Impact.refreshTokens();
      if (result == 200) { // 2. CONTROLLA DI AVERE IL REFRESH
        _toHomePage(context);
      } else {
        final isChecked = sp.getString('saved_credentials');
        if (isChecked != null) { // 3. CONTROLLA IL REMEMBER ME
          // print("re-authorized thanks to remember me option");
          if (isChecked == "true") {
            final username = sp.getString('username');
            final password = sp.getString('password');
            //final Impact impact = Impact();
            await Impact.getAndStoreTokens(username!, password!);
            _toHomePage(context);
          } else {
            _toLoginPage(context);
          }
        } else {
          _toLoginPage(context);
        }
      }
    }
  } //_checkLogin
   

  @override
  Widget build(BuildContext context) {
    Future.delayed(
        const Duration(seconds: 3),
        () => _checkLogin(context)); // PICCOLO DELAY PRIMA DI PASSARE ALLA LOGIN PAGE (CAMBIA)
    return Scaffold(
        body: Center(
            child: Image.asset(
      'assets/logo_1.png', // CAMBIA LOGO
      scale: 2,
    )));
  }
}

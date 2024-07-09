import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/downScreen.dart';
import 'package:lag/screens/home.dart';
import 'package:lag/screens/login.dart';
import 'package:lag/services/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  final HomeProvider provider;
  const Splash({super.key, required this.provider});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Method for navigation SplashPage -> HomePage
  void _toHomePage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Home(provider: widget.provider)));
  } //_toHomePage

  // Method for navigation SplashPage -> LoginPage
  void _toLoginPage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: ((context) => Login(provider: widget.provider,))));
  } //_toLoginPage

  // Method for navigation SplashPage -> DownScreen
  void _toDownScreen(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: ((context) => DownScreen())));
  } //_toDownScreen

  Future<void> _checkLogin(BuildContext context) async {
    if (!(await Impact.isImpactUp())) {
      _toDownScreen(context);
    } else {
      final sp = await SharedPreferences.getInstance();
      final access = sp.getString('access');
      if (access != null && !(JwtDecoder.isExpired(access))) {
        _toHomePage(context);
      } else {
        final result = await Impact.refreshTokens();
        if (result == 200) {
          _toHomePage(context);
        } else {
          final isChecked = sp.getBool('saved_credentials'); // remember me option
          if (isChecked != null) {
            if (isChecked) {
              final username = sp.getString('username');
              final password = sp.getString('password');
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
    }
  } //_checkLogin

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () => _checkLogin(_scaffoldKey.currentContext!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Image.asset('assets/logo_1.png', scale: 2),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/login.dart';
import 'package:lag/screens/personal_info.dart';
import 'package:lag/screens/settings.dart';
import 'package:provider/provider.dart';
// import 'package:lag/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 12.0, right: 12.0, top: 60, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Info about you and your preferences",
              style: TextStyle(
                      fontSize: 14, 
                      color: Colors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            /*
            const Text(
              "Account",
              style: TextStyle(fontSize: 16),
            ),
            */
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Text(
                    "Personal Info",
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PersonalInfo()));
                  },
                ),
                Divider(
                  color: Color(0xFFFFFFFF),
                  thickness: 3,
                ),
                ListTile(
                  leading: Text("Settings", style: TextStyle(fontSize: 14)),
                  trailing: Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Settings()));
                  },
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Our mission",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "LAG is an innovative app that calculates a score using your sleep, exercise and mental health data to help enhance your quality of life. We designed a fancy gamification feature that provides a pleasant visual way to track your weekly progress and keep your motivation up.",
                    style: TextStyle(
                        fontSize: 14, 
                        color: Colors.black.withOpacity(0.6)
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            /*Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  _toLogin(context); 
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 12)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF384242))),
                child: const Text('Log Out'),
              ),
            ),*/
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  _showLogoutConfirmation(context); 
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 12)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF384242)),
                ),
                child: const Text('Log Out'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "version 2.0.0",
                style: TextStyle(
                        fontSize: 14, 
                        color: Colors.black.withOpacity(0.6)
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to log out?',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
          content: const Text('Remember that logging out will result in the loss of your diary!',
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
                [TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Chiude il pop-up
                  },
                  child: const Text('Back'),
                ),
                const SizedBox(width: 70),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Chiude il pop-up
                    _toLogin(context); // Invoca il logout
                  },
                  child: const Text('Log Out'),
                )],
            )
          ],
        );
      },
    );
  }

  _toLogin(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();

    // opt 1: remove specific keys
    // await sp.remove("age");
    // await sp.remove("gender");
    // await sp.remove("username");
    // await sp.remove("password");

    // opt 2: clear whole shared prefs
    await sp.clear();
    //Then pop the HomePage
    await Provider.of<HomeProvider>(context, listen: false).updateSP();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const Login())));
  }

/*
  _makeTokenExpire(BuildContext context) async{
    final sp = await SharedPreferences.getInstance();
    await sp.remove("access");
    await sp.remove("refresh");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const Splash())));
  } */
}

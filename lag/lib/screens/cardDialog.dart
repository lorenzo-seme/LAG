import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class CardDialog extends StatefulWidget {
  bool buttonClickedToday;

  CardDialog(
    this.buttonClickedToday, {
    super.key,
  });

  @override
  _CardDialogState createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  List<String> questions = [
    'Are you too tired to work out today?',
    'Do you lack motivation to work out?',
    'Are you too busy to work out?'
  ];

  List<bool> answers = [];
  List<String> solutions = [
    'https://www.onepeloton.com/blog/workouts-when-tired/',
    'https://www.nia.nih.gov/health/exercise-and-physical-activity/5-tips-help-you-stay-motivated-exercise',
    'https://www.bronsonhealth.com/news/six-ways-to-find-time-for-the-gym-when-youre-busy/'
  ];
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < questions.length; i++) {
      answers.add(false);
    }
    _loadResult();
  }

  _loadResult() async {
    final sp = await SharedPreferences.getInstance();
    DateTime date = DateTime.now().subtract(Duration(days: 1));
    String dateString = date.toIso8601String().split('T').first;
    for (int i = 0; i < 2; i++) {
      if (sp.getBool('survey${i}_${dateString}') != null) {
        setState(() {
          answers[i] = sp.getBool('survey${i}_${dateString}')!;
        });
      }
    }
  }

  void _saveResult(bool value) async {
    final sp = await SharedPreferences.getInstance();
    DateTime date = DateTime.now().subtract(Duration(days: 1));
    String dateString = date.toIso8601String().split('T').first;
    sp.setBool('survey${currentQuestionIndex}_${dateString}', value);
  }

  Widget _returnDialog() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          if (currentQuestionIndex < questions.length)
            Column(
              children: [
                Text(
                  questions[currentQuestionIndex],
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          answers[currentQuestionIndex] = true;
                          _saveResult(true);
                          if (currentQuestionIndex < questions.length - 1) {
                            currentQuestionIndex++;
                          } else {
                            currentQuestionIndex++;
                          }
                        });
                      },
                      child: Text('Yes'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          answers[currentQuestionIndex] = false;
                          _saveResult(false);
                          if (currentQuestionIndex < questions.length - 1) {
                            currentQuestionIndex++;
                          } else {
                            currentQuestionIndex++;
                          }
                        });
                      },
                      child: Text('No'),
                    ),
                  ],
                ),
              ],
            ),
          if (currentQuestionIndex >= questions.length) _getResults(),
        ],
      ),
    );
  }

  Widget _getResults() {
    List<Widget> results = [
      Text(
        'YOUR STATUS TODAY 🥵',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 30),
      Row(
        children: [
          Text('Tired'),
          const SizedBox(width: 12),
          (answers[0]) ? Icon(Icons.check) : Icon(Icons.close)
        ],
      ),
      const SizedBox(height: 15),
      Row(
        children: [
          Text('Lack of motivation'),
          const SizedBox(width: 12),
          (answers[1]) ? Icon(Icons.check) : Icon(Icons.close),
        ],
      ),
      const SizedBox(height: 15),
      Row(
        children: [
          Text('No time'),
          const SizedBox(width: 12),
          (answers[2]) ? Icon(Icons.check) : Icon(Icons.close),
        ],
      ),
      const SizedBox(height: 20),
    ];

    if (answers.every((element) => element == false)) {
      results.add(
        Column(
          children: [
            const SizedBox(height: 10),
            Row( 
              children: [
                Icon(Icons.priority_high, color: Color.fromARGB(255, 131, 35, 233)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                  'I don\'t understand why you have not done your',
                  style: TextStyle(fontStyle: FontStyle.italic),)
                  //overflow: TextOverflow.ellipsis,),
                )
              ],
            ),
            const SizedBox(height: 15,),
            ElevatedButton(
                child: Text('Discover how to fix it!',
                style: TextStyle(fontStyle: FontStyle.italic),),
              onPressed: () async {
                await launchUrl(Uri.parse(
                    'https://www.nia.nih.gov/health/exercise-and-physical-activity/5-tips-help-you-stay-motivated-exercise'));
              },
            ),
          ],
        ),
      );
      results.add(
        TextButton(
           child: Text('Close'),
           onPressed: () {
            Navigator.of(context).pop();
            },
            ));
    } else {
      List<Widget> buttons = [];
      List<String> typeProblems = ['Tiredness', 'Motivation', 'Busy'];
      for (int i = 0; i < answers.length; i++) {
        if (answers[i]) {
          buttons.add(
            ElevatedButton(
              child: Text('${typeProblems[i]}'),
              onPressed: () async {
                await launchUrl(Uri.parse(solutions[i]));
              },
            ),
          );
        }
      }
      results.add(
        Text(
          'Get here some specific advices:',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      results.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: buttons.map((button) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: button,
                );
              }).toList(),
            ),
          ),
        ),
      );
      results.add(
        TextButton(
           child: Text('Close'),
           onPressed: () {
            Navigator.of(context).pop();
            },
            ));
    }

    return Column(children: results);
  }

/*
  @override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _loadResult(),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Mostra uno spinner o indicatore di caricamento se necessario
        return CircularProgressIndicator();
      } else {
        // Dopo il caricamento, restituisci il widget appropriato
        return widget.buttonClickedToday ? _getResults() : _returnDialog();
      }
    },
  );
}*/
@override
  Widget build(BuildContext context) {
    return widget.buttonClickedToday ? _getResults() : _returnDialog();
  }

}

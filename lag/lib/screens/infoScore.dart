import 'package:flutter/material.dart';

class InfoScore extends StatelessWidget {
  const InfoScore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How do we calculate your score?", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold,)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Hero(
                  tag: 'score',
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            'assets/info_score.png'),
                      ),
                    ),
                  ),),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'Our score is based on the analysis of three fundamental characteristics for maintaining a healthy lifestyle: the quality of sleep and exercise, and the consistency in becoming aware of emotions.\n\n',
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sleep\n',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextSpan(
                          text: 'One of the main aspects considered is ',
                        ),
                        TextSpan(
                          text: 'efficiency',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' which measures how much time the user actually spends sleeping compared to the total time spent in bed.\n'
                              'The amount of ',
                        ),
                        TextSpan(
                          text: 'hours slept',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' is another key factor. The function compares this duration with the recommendations for the user\'s age. \n'
                              'The ',
                        ),
                        TextSpan(
                          text: 'time to fall asleep',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' is also evaluated. This parameter has a lower weight in the final calculation, as it has been observed that it often tends to be zero in the collected data.\n'
                              'Another evaluated aspect is the distribution of sleep among the different phases, in particular ',
                        ),
                        TextSpan(
                          text: 'REM',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' and ',
                        ),
                        TextSpan(
                          text: 'Deep',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '.\n'
                        ),
                        TextSpan(
                          text: '\n'
                        ),
                        TextSpan(
                          text: 'Exercise\n',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextSpan(
                          text: 'Starting from the ',
                        ),
                        TextSpan(
                          text: 'user\'s age',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ', it is possible to define recommendations to ensure a healthy lifestyle. For each type of ',
                        ),
                        TextSpan(
                          text: 'activity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' performed, the score assigns a weight based on the ',
                        ),
                        TextSpan(
                          text: 'distance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' covered and the ',
                        ),
                        TextSpan(
                          text: 'duration',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' of each exercise, such as running, walking, and cycling. The ',
                        ),
                        TextSpan(
                          text: 'frequency',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' of weekly workouts is crucial as it promotes consistency. Additionally, if the user engages in a minimum level of ',
                        ),
                        TextSpan(
                          text: 'activity',
                        ),
                        TextSpan(
                          text: ' every day, a baseline score value will be assigned.\n',
                        ),
                        TextSpan(
                          text: '\n',
                        ),
                        TextSpan(
                          text: 'Mood\n',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextSpan(
                          text: 'The user is rewarded if he/she takes time each day to reflect on how he/she '
                        ),
                        TextSpan(
                          text: 'feels',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' and to write down his/her thoughts. This is a good first step towards better '
                        ),
                        TextSpan(
                          text: 'mood management.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

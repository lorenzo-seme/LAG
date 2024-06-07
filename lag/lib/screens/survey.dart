//class Survey extends Stateless

import 'dart:math';

import 'package:flutter/material.dart';

/*
class Survey extends StatelessWidget {
  Survey({Key? key}) : super(key: key);

  @override
  // This widget is the root of your application.
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            CardDialog(),
            Positioned(
              top: 0,
              right: 0,
              height: 28,
              width: 28,
              child: OutlinedButton(
                child: Icon(Icons.close_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  shape: const CircleBorder(),
                  backgroundColor: Colors.redAccent,
                ),
              ),
            )
          ],
        ));
  }
}
*/

class CardDialog extends StatefulWidget {
  CardDialog({
    super.key,
  });

  @override
  State<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Did you work-out today?',
      'Yes': 'You are great!!',
      'No': '',
    },
    {
      'question': 'Why? Do you feel well?',
      'Yes': '',
      'No': 'Move your as*',
    },
    {
      'question':
          'So, it means you were very very busy and you didn\'t have time, correct?',
      'Yes': '',
      'No': 'Move your as*',
    },
  ];

  int _currentQuestionIndex = 0;
  String _response = '';
  List<String> congrats = ['You are great!!', 'Good job :)'];
  List<String> suggests = ['Come on, you can do it'];
  List<String> insults = ['You should move more', 'Don\'t like your attidute'];

  void _checkAnswer(String ans) {
    final random = Random();
    setState(() {
      _response = _questions[_currentQuestionIndex][ans];

      // Move to the next question after showing the response
      Future.delayed(Duration(milliseconds: 50), () {
        setState(() {
          if (_currentQuestionIndex == 0 && ans == 'Yes') {
            final index = random.nextInt(congrats.length);
            _response = congrats[index];
          } else if (_currentQuestionIndex == 0 && ans == 'No' ||
          _currentQuestionIndex == 1 && ans == 'Yes') {
            _currentQuestionIndex++;
            _response = '';
          } else if  (_currentQuestionIndex == 1 && ans == 'No' || 
          _currentQuestionIndex == 2 && ans == 'Yes') {
            final index = random.nextInt(insults.length);
            _response = insults[index];
          } else if (_currentQuestionIndex == 2 && ans == 'No') {
            final index = random.nextInt(suggests.length);
            _response = suggests[index];
          } else if (_currentQuestionIndex >= _questions.length) {
            _response = 'End';
          }
        },
        );
      }
      );
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        if (_response.isNotEmpty)
          Text(
            _response,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        else
          Text(
            _questions[_currentQuestionIndex]['question'],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 32), // Remove the extra comma here
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _checkAnswer('Yes'),
              child: const Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () => _checkAnswer('No'),
              child: const Text('No'),
            ),
          ],
        ),
      ],
    );
  }
}








      //duration: const Duration(milliseconds: 10),
      //decoration: BoxDecoration(
        //color: Colors.transparent,
        //borderRadius: BorderRadius.circular(12),
      //),
      //curve: Curves.easeInOut,
      




      /*
      child: Card(
        color: const Color.fromARGB(255, 242, 239, 245),
        elevation: 5,
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_questions[_currentQuestionIndex]['question']),
            const SizedBox(height: 32),
            if (_response.isNotEmpty) Text(_response),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                  ),
                  onPressed: () => _checkAnswer('Yes'),
                  child: const Text('Yes'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                  ),
                  onPressed: () => _checkAnswer('No'),
                  child: const Text('No'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
*/

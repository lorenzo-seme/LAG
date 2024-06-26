
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lag/screens/sliderWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: must_be_immutable
class CardDialog extends StatefulWidget {
  bool buttonClickedToday;

  CardDialog(
    this.buttonClickedToday, {
    super.key,
  });

  @override
  State<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  //final GlobalKey<_CardDialogState> cardDialogKey = GlobalKey<_CardDialogState>();
  int _nq = 0;
  final day = DateTime.now().subtract(Duration(days: 1)).day;
  final month = DateTime.now().subtract(Duration(days: 1)).month;
  String _currentAnswer = '';
  bool _showButton = true;
  bool _showText = false;
  bool _endSurvery = false;
  //late final HomeProvider provider;
  String _icon = 'assets/';
  final Map<int, dynamic> _questions = {
    0: 'Did you work out today?',
    1: 'Are you motivated?',
    2: 'Did you have time to try to workout?'
  };
  final Map<int, dynamic> _answers = {
    0: 'Good job!! Exercise improves cardiorespiratory fitness at different ages, even in the elderly and when performed in a reduced-time session of moderate activity',
    1: 'Come on!! Work out so you can eat more pizza guilt-free, sleep like a baby, and live long enough to become a legendary grandparent!',
    2: 'Discover the secret to have more workout time: set your alarm earlier, skip the snooze, and let those endorphins be your morning coffee! By the way, physical inactivity may be the preferential target for clinical and public health interventions which may ultimately reduce the mortality gap. In fact, delivering physical exercise or physical activity may not only improve depression severity, but also directly tackle the constitutive elements of cardiovascular risk. Nonetheless, several challenges remain to be addressed by further research.',
    3: 'Physical inactivity may be the preferential target for clinical and public health interventions which may ultimately reduce the mortality gap. In fact, delivering physical exercise or physical activity may not only improve depression severity, but also directly tackle the constitutive elements of cardiovascular risk. Nonetheless, several challenges remain to be addressed by further research.'
  };
  String _result = '';
  final Map<String, String> _reason = {
    'No1': 'feel like to',
    'No2': 'have enough time to',
    'Yes2': 'want to'
  };
  final Map<String, String> _solution = {
    'No1': 'how to find a good motivation',
    'No2': 'how to better organize your days',
    'Yes2': 'why you should do it'
  };

  @override
  void initState() {
    super.initState();
    _todayResults();
    //_exerciseToday();
  }
  
  _todayResults() async {
    final sp = await SharedPreferences.getInstance();
    final day = DateTime.now().subtract(Duration(days: 1)).day;
    final month = DateTime.now().subtract(Duration(days: 1)).month;
    print('${day}_${month}');
    if (widget.buttonClickedToday) {
      setState(() {
        _result = sp.getString('survey_${day}_${month}') ?? '';
        print('_result updated in _todayResults: $_result');
      });
    }
  }

  _checkAnswer() async {
    final sp = await SharedPreferences.getInstance();
    final day = DateTime.now().subtract(Duration(days: 1)).day;
    final month = DateTime.now().subtract(Duration(days: 1)).month;

    if (_currentAnswer == 'Yes' && _nq == 0) {
      setState(() {
        _endSurvery = true;
        _showText = true;
        _showButton = false;
        _icon = _icon + 'good_ex.jpg';
        _result = 'Yes0';
        print('_result updated in _checkAnswer (Yes0): $_result');
      });
      await sp.setString('${day}_${month}', _result);
    } else if (_currentAnswer == 'Yes' && _nq == 1) {
      setState(() {
        _endSurvery = false;
        _showText = false;
        _showButton = true;
        _nq++;
      });
    } else if (_currentAnswer == 'Yes' && _nq == 2) {
      // si ho avuto tempo di allenarm -> stop
      setState(() {
        _endSurvery = true;
        _showButton = false;
        _showText = true;
        _icon = _icon + "good2_ex.jpg";
        _result = 'Yes2';
        print('_result updated in _checkAnswer (Yes2): $_result');
      });
      await sp.setString('${day}_${month}', _result);
    } else if (_currentAnswer == 'No' && _nq == 0) {
      // no, non mi sono allenata -> avanti
      setState(() {
        _endSurvery = false;
        _showButton = true;
        _showText = false;
        _nq++;
      });
    } else if (_currentAnswer == 'No' && _nq == 1) {
      // no, non sono motivata -> stop
      setState(() {
        _endSurvery = true;
        _showButton = false;
        _showText = true;
        _icon = _icon + "fail_ex.jpg";
        _result = 'No1';
        print('_result updated in _checkAnswer (No1): $_result');
      });
      await sp.setString('${day}_${month}', _result);
    } else if (_currentAnswer == 'No' && _nq == 2) {
      // no, non ho avuto tempo -> stop
      setState(() {
        _endSurvery = true;
        _showButton = false;
        _showText = true;
        _icon = _icon + "fail2_ex.jpg";
        _nq++;
        _result = 'No2';
        print('_result updated in _checkAnswer (No2): $_result');
      });
    }
    await sp.setString('survey_${day}_${month}', _result);
  }

  Map<String, String> _getResults() {
    print('_result $_result');
    if (_result == 'Yes0') {
      return {
        'wo': 'Yes',
        'reason': '',
        'solution': '',
      };
    } else {/*if (_reason.containsKey(_result) &&
        _solution.containsKey(_result)) {*/
      return {
        'wo': 'No',
        'reason': _reason[_result]!,
        'solution': _solution[_result]!,
      };
   /* } else {
      return {
        'wo': 'No',
        'reason': 'Unknown reason',
        'solution': 'Unknown solution',
      };*/
    }
  }

  _showAlternative() {
      return Column(
      children: [
        Text('BUT',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black)),
        const SizedBox(height: 15),
        Text(
            'since you didn\'t ${_getResults()['reason']} workout (till now), discover here ${_getResults()['solution']}',
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {}, child: Text('More info')),
            const SizedBox(width: 15),
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'))
          ],
        )
      ],
    );
  }

    
  Widget _returnStatus() {
    if (_result == 'Yes0') {
      return Row(
        children: [
          Text('Today you are a champion!', style: TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(width: 5),
          Icon(Icons.emoji_events_sharp, color: Colors.amberAccent)
        ],);
    } else if (_result == 'No1') {
      return Row(
        children: [
          Text('No motivation', style: TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(width: 5),
          Icon(Icons.battery_0_bar, color: Colors.red[900])
        ],);
    } else if (_result == 'No2') {
      return Row(
        children: [
          Text('No time', style: TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(width: 5),
          Icon(Icons.schedule, color: Colors.purple[900])
        ],);
    } else {
      return Row(
        children: [
          Text('Lazy', style: TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(width: 5),
          Icon(Icons.mood_bad, color: Colors.black)
        ],);
    }
  }

  
  @override
  Widget build(BuildContext context) {
  if (widget.buttonClickedToday) {  
      return SimpleDialog(
        title: Row(
          children: [
            _returnStatus(),
          ],
        ),
        elevation: 5,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You have already done the survey for today',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                (_getResults()['wo'] == 'Yes')
                    ? TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : _showAlternative()
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          _showText
              ? Column(
                  children: [
                    Image.asset(_icon),
                    SizedBox(height: 20),
                    Text(_answers[_nq], style: TextStyle(fontSize: 17)),
                  ],
                )
              : Text(_questions[_nq], style: TextStyle(fontSize: 17)),
          const SizedBox(height: 20),
          Visibility(
            visible: !_endSurvery && _showButton,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _currentAnswer = 'Yes';
                      _checkAnswer();
                    },
                    child: Text('Yes')),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () {
                      _currentAnswer = 'No';
                      _checkAnswer();
                    },
                    child: Text('No'))
              ],
            ),
          ),
        ],
      );
    }
  }
}

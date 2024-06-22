import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardDialog extends StatefulWidget {
  CardDialog({
    super.key,
  });

  @override
  State<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  int _nq = 0;
  String _currentAnswer = '';
  bool _showButton = true;
  bool _showText = false;
  bool _endSurvery = false;
  String _icon = 'assets/';
  Map<int, dynamic> _questions = {0:'Did you work out today?', 1:'Are you motivated?',2:'Maybe you didn\'t have enough time to workout, correct?'};
  Map<int, dynamic> _answers = {0:'Good job!! Exercise improves cardiorespiratory fitness at different ages, even in the elderly and when performed in a reduced-time session of moderate activity', 
  1:'Come on!! Work out so you can eat more pizza guilt-free, sleep like a baby, and live long enough to become a legendary grandparent!',
  2:'Discover the secret to have more workout time: set your alarm earlier, skip the snooze, and let those endorphins be your morning coffee! By the way, physical inactivity may be the preferential target for clinical and public health interventions which may ultimately reduce the mortality gap. In fact, delivering physical exercise or physical activity may not only improve depression severity, but also directly tackle the constitutive elements of cardiovascular risk. Nonetheless, several challenges remain to be addressed by further research.',
  3:'Physical inactivity may be the preferential target for clinical and public health interventions which may ultimately reduce the mortality gap. In fact, delivering physical exercise or physical activity may not only improve depression severity, but also directly tackle the constitutive elements of cardiovascular risk. Nonetheless, several challenges remain to be addressed by further research.'};

    /*
    _selectQuestion() {
      if (_currentAnswer == 'Yes' && _nq == 1) {
        return _answers[_nq];
      } else if (_currentAnswer == 'Yes' && _nq == 2) {  // sì sono motivata -> avanti
        setState(() {
          _endSurvery = false;
          _showButton = true;
          _showText = false;
        });
        return _questions[_nq];
      } else if (_currentAnswer == 'Yes' && _nq == 3) {  // si ho avuto tempo di allenarm -> stop
        setState(() {
          _endSurvery = true;
          _showButton = false;
          _showText = true;
        });
        return _answers[_nq];
      } else if (_currentAnswer == 'No' && _nq == 1) {  // no, non mi sono allenata -> avanti
        setState(() {
          _endSurvery = false;
          _showButton = true;
          _showText = false;
        });
        return _questions[_nq];
      } else if (_currentAnswer == 'No' && _nq == 2) {  // no, non sono motivata -> stop
        setState(() {
          _endSurvery = true;
          _showButton = false;
          _showText = true;
        });
        return _questions[_nq];
      } else if (_currentAnswer == 'No' && _nq == 3) {  // no, non ho avuto tempo -> stop
        setState(() {
          _endSurvery = true;
          _showButton = false;
          _showText = true;
          _nq++;
        });
        return _answers[_nq];
      } 
    } 
    */ // end _selectQuestion

    _checkAnswer() {
      if (_currentAnswer == 'Yes' && _nq == 0) {
        setState(() {
          _endSurvery = true;
          _showText = true;
          _showButton = false;
          _icon = _icon + 'good_ex.jpg';
        });
      } else if (_currentAnswer == 'Yes' && _nq == 1) {
        setState(() {
          _endSurvery = false;
          _showText = false;
          _showButton = true;
          _nq++;
        });
      } else if (_currentAnswer == 'Yes' && _nq == 2) {  // si ho avuto tempo di allenarm -> stop
        setState(() {
          _endSurvery = true;
          _showButton = false;
          _showText = true;
          _icon = _icon + "good2_ex.jpg";
        });
      } else if (_currentAnswer == 'No' && _nq == 0) {  // no, non mi sono allenata -> avanti
        setState(() {
          _endSurvery = false;
          _showButton = true;
          _showText = false;
          _nq++;
        });
      } else if (_currentAnswer == 'No' && _nq == 1) {  // no, non sono motivata -> stop
        setState(() {
          _endSurvery = true;
          _showButton = false;
          _showText = true;
          _icon = _icon + "fail_ex.jpg";
        });
      } else if (_currentAnswer == 'No' && _nq == 2) {  // no, non ho avuto tempo -> stop
        setState(() {
          _endSurvery = true;
          _showButton = false;
          _showText = true;
          _icon = _icon + "fail2_ex.jpg";
          _nq++;
        });
      } 
    }



    @override 
    Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          _showText
          ? Column(
            children: [
              Image.asset(_icon),
              SizedBox(height: 20),
              Text(_answers[_nq],
            style: TextStyle(
              fontSize: 17)),
              ],
              )
          : Text(_questions[_nq],  style: TextStyle(
            fontSize: 17)),
          const SizedBox(height: 20),
          Visibility(
            visible: !_endSurvery && _showButton,
            child:Row(
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
          )
        ]
      );
    }


}
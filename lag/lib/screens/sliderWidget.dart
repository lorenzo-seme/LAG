import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SliderWidget extends StatefulWidget {
  bool buttonClickedToday;

  SliderWidget(
    this.buttonClickedToday, {
    super.key,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  String dateString = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T').first;
  final Map<int, double> _currentValue = {1: 0, 2: 0, 3: 0};
  final Map<int, String> _questionsWO = {
    1: 'Was the workout hard?',
    2: 'Are you satisfied?',
    3: 'Did it help you to feel better?'
  };

  @override
  void initState() {
    super.initState();
    _todayResults();
  }

  _todayResults() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _currentValue[1] = sp.getDouble('q1_$dateString') ?? 0;
      _currentValue[2] = sp.getDouble('q2_$dateString') ?? 0;
      _currentValue[3] = sp.getDouble('q3_$dateString') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buttonClickedToday) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              width: 300,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Your workout performance of today",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: Text('Hard level: ${_currentValue[1]}'),
                      ),
                      const SizedBox(width: 12),
                      _currentValue[1]! > 5
                          ? const Icon(Icons.thumb_up)
                          : const Icon(Icons.thumb_down),
                    ],
                  ),
                  const SizedBox(height: 15), // Aggiungi spazio tra le righe
                  Row(
                    children: [
                      Flexible(
                        child: Text('Satisfaction level: ${_currentValue[2]}'),
                      ),
                      const SizedBox(width: 12),
                      _currentValue[2]! > 5
                          ? const Icon(Icons.thumb_up)
                          : const Icon(Icons.thumb_down),
                    ],
                  ),
                  const SizedBox(height: 15), // Aggiungi spazio tra le righe
                  Row(
                    children: [
                      Flexible(
                        child: Text('Wellness level: ${_currentValue[3]}'),
                      ),
                      const SizedBox(width: 12),
                      _currentValue[3]! > 5
                          ? const Icon(Icons.thumb_up)
                          : const Icon(Icons.thumb_down),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_questionsWO[1]!),
          Slider(
            value: _currentValue[1]!,
            min: 0,
            max: 10,
            divisions: 10,
            label: _currentValue[1]!.round().toString(),
            onChanged: (double value) async {
              final sp = await SharedPreferences.getInstance();
              setState(() {
                _currentValue[1] = value;
              });
              sp.setDouble('q1_$dateString', _currentValue[1]!);
            },
          ),
          const SizedBox(height: 8),
          Text(_questionsWO[2]!),
          Slider(
            value: _currentValue[2]!,
            min: 0,
            max: 10,
            divisions: 10,
            label: _currentValue[2]!.round().toString(),
            onChanged: (double value) async {
              final sp = await SharedPreferences.getInstance();
              setState(() {
                _currentValue[2] = value;
              });
              sp.setDouble('q2_$dateString', _currentValue[2]!);
            },
          ),
          const SizedBox(height: 8),
          Text(_questionsWO[3]!),
          Slider(
            value: _currentValue[3]!,
            min: 0,
            max: 10,
            divisions: 10,
            label: _currentValue[3]!.round().toString(),
            onChanged: (double value) async {
              final sp = await SharedPreferences.getInstance();
              setState(() {
                _currentValue[3] = value;
              });
              sp.setDouble('q3_$dateString', _currentValue[3]!);
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      );
    }
  }
}

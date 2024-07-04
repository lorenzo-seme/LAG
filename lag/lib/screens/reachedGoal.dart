// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ReachedGoal extends StatefulWidget {
  bool reachGoal;

  ReachedGoal({required this.reachGoal});

  @override
  _ReachedGoalState createState() => _ReachedGoalState();
}

class _ReachedGoalState extends State<ReachedGoal> {
  @override
  void initState() {
    super.initState();
    _showDialogIfGoalReached();
  }

  @override
  void didUpdateWidget(ReachedGoal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reachGoal != widget.reachGoal) {
      _showDialogIfGoalReached();
    }
  }

  void _showDialogIfGoalReached() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.reachGoal) {
       showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 1000),
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        },
        transitionBuilder: (context, a1, a2, widget) {
          return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
                child: AlertDialog(
                  backgroundColor: const Color.fromARGB(255, 242, 239, 245),
                  content: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Congratulation! You have reached your goal!!',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Image.asset('assets/goal.jpg'),
                        const SizedBox(height: 20),
                        /*
                        Text('Do you want to move to the next level?',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  print('current level $_level');
                                  print('current score $_currentScore');
                                  _upDateGoal();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Yes')),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _percentage = 1;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('No'),
                            ),
                          ],
                        ),*/
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Close"))
                      ],
                    ),
                  ),
                ),
              ));
        }
        );
      }
    });
      }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

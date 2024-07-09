import 'package:flutter/material.dart';

class ReachedGoal extends StatefulWidget {
  final bool reachGoal;

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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
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
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Close"))
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

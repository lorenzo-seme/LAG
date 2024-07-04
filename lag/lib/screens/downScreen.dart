import 'package:flutter/material.dart';

class DownScreen extends StatelessWidget {
  const DownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SafeArea(
        minimum: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Impact is down", style: TextStyle(fontSize: 24, color: Colors.black)),
            Text("Try again in a few minutes", style: TextStyle(fontSize: 18, color: Colors.black))
          ],
        ),
      ),
    );
  }
}

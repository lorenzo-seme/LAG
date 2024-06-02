import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/rhrScreen.dart';
//import 'package:lag/models/heartratedata.dart';
import 'package:lag/utils/custom_plot.dart';

// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class ExerciseScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;

  const ExerciseScreen({super.key, required this.startDate, required this.endDate, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sum-up of exercise activity"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            },
            ),
            ),
      
      body: SafeArea(
      child: Padding(
          padding: const EdgeInsets.only(
              left: 12.0, right: 12.0, top: 10, bottom: 20),
          child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text('${DateFormat('EEE, d MMM').format(provider.start)} - ${DateFormat('EEE, d MMM').format(provider.end)}'),
                    const SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: provider.exerciseData.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomPlot(data: provider.exerciseData),
                            ),
                    ),
                    Center(
                      child: ElevatedButton(
                        child: Text('Temporary button, to RHR screen'),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RhrScreen(startDate: provider.start, endDate: provider.end, provider: provider))),
                      ),
                    ),
                  ]
                ),
            ),
          ),
        );
  }
}

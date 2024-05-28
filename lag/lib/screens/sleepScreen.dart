import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; 
import 'package:intl/intl.dart';
import 'package:lag/algorithms/sleepScore.dart';
//import 'package:lag/models/heartratedata.dart';
import 'package:lag/providers/homeProvider.dart';
// import 'package:lag/utils/custom_plot.dart';
import 'package:provider/provider.dart';

// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class SleepScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const SleepScreen({super.key, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Data', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();},
          ),
        ),
      
      body: SafeArea(
        child: ChangeNotifierProvider(
      create: (context) => HomeProvider(), // homeprovider is the class implementing the change notifier
      builder: (context, child) => Padding(
        padding:
            const EdgeInsets.only(left: 12.0, right: 12.0, top: 10, bottom: 20),
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text('${DateFormat('EEE, d MMM').format(startDate)} - ${DateFormat('EEE, d MMM').format(endDate)}'),
              const SizedBox(height: 5),
              
              const Text("PLOT DAYS VS SCORE",style: TextStyle(fontSize: 32)),
              
              // qui crea un qualcosa che prelevi dalla lista provider.sleepData della settimana i vari parametri di ogni giorno e faccia le media
              Text("$getSleepScore(context, provider.sleepData)")
              

            ],
          );
        }),
      ),
    ))
    );
  }
}


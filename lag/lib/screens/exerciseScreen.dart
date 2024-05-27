import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/models/exercisedata.dart';
import 'package:lag/providers/homeProvider.dart';
//import 'package:lag/models/heartratedata.dart';
import 'package:lag/utils/custom_plot.dart';
import 'package:provider/provider.dart';

// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              AppBar(
                title: Text("SUM-UP EXERCISE ACTIVITY"),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                centerTitle: true,
              ), 
              CustomPlot(data: provider.exerciseData)
            ]
          );
        }
  
  )
  )
  )
  );}
  }





              
            
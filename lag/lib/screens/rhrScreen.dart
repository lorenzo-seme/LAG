import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/InfoRHR.dart';
//import 'package:lag/utils/barplot.dart';
import 'package:lag/utils/custom_plot.dart';



// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class RhrScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;

  const RhrScreen({super.key, required this.startDate, required this.endDate, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resting Heart Rate Data', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();},
          ),
        ),
      
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 12.0, right: 12.0, top: 10, bottom: 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text('${DateFormat('EEE, d MMM').format(startDate)} - ${DateFormat('EEE, d MMM').format(endDate)}'),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 100,
                    child: CustomPlot(data: provider.heartRateData),
                    //child: BarChartSample7(),
                  ),
                  const SizedBox(height: 5),
                  (provider.heartRateData.isEmpty) ? const CircularProgressIndicator.adaptive() :
                    Text("Average resting heart rate: ${provider.rhrAvg()}"),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      children:[
                        TextSpan(
                          text: "To better understand these data, ",
                          style: TextStyle(color: Colors.black)
                        ),
                        TextSpan(
                          text: "press here",
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => InfoRHR()));},
                        ),
                        TextSpan(
                          text: ".",
                          style: TextStyle(color: Colors.black)
                        ),
                      ]
                    ),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }

}


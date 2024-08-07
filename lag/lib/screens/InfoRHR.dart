import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/rhrScreen.dart';

class InfoRHR extends StatelessWidget {
  final HomeProvider provider;
  const InfoRHR({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check your heart rate at rest now!", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold,)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Hero(
                  tag: 'rhr',
                  child:  Container(
                    width: 300,
                    height: 200,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            'assets/exercise.jpg'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                RichText(
                  text: const TextSpan(
                    text:'Premature death is defined as death that occurs before the average age of death in a certain population. One of the main causes of death is heart disease. ',
                    style: TextStyle(
                          height: 1.5,
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Experts say most cases of premature death form heart disease are completely preventable',
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '. Risk factors include having high pressure or cholesterol, heavy drinking and physical inactivity. Here we focus on this latter point, in particular on its link with resting heart rate. Generally, a lower heart rate at rest implies more efficient heart function and better cardiovascular fitness. This is crucial to help prevent heart diseases.\nTo see your resting heart rate and get personalized advises on the exercise you should perform, ',
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'click the button below.',
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                (provider.lastMonthHR==0) 
                  ? const CircularProgressIndicator.adaptive() 
                  :
                  Card(
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(Icons.monitor_heart),
                      trailing: SizedBox(
                        width: 10,
                        child: ((provider.lastMonthHR > 80.0)) ? const Icon(Icons.thumb_down) : const Icon(Icons.thumb_up),
                        ), 
                      title: Text('Resting heart rate : ${provider.lastMonthHR} bpm'),
                      subtitle: const Text('Average of current month'),
                      onTap: () async {
                          if(provider.monthlyHeartRateData.length!=6)
                          {
                            ScaffoldMessenger.of(context)
                              .showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.blue,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(8),
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                      "Be patient.. We're loading your data!"),
                                ),
                              );
                          } else {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RhrScreen(provider: provider)
                              )); 
                          }
                        }
                      ),
                    ),
              ],
          ),
        ),
      ),),
    );
  }
}

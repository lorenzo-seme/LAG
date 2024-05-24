import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:provider/provider.dart';

// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class WeeklyRecap extends StatelessWidget {
  const WeeklyRecap({super.key});

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
              Text(
                "Hello, ${provider.nick}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Weekly Personal Recap',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      provider.getDataOfWeek(provider.showDate.subtract(const Duration(days: 7)));
                      provider.dateSubtractor(provider.showDate);
                    },
                    child: const Icon(
                      Icons.navigate_before,
                    ),
                  ),
                ),
                Text('${DateFormat('EEE, d MMM').format(provider.monday!)} - ${DateFormat('EEE, d MMM').format(provider.sunday!)}'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      provider.getDataOfWeek(provider.showDate.add(const Duration(days: 7)));
                      provider.dateAdder(provider.showDate);
                    },
                    child: const Icon(
                      Icons.navigate_next,
                    ),
                  ),
                ),
              ]),
              const Text(
                "Cumulative Score",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                  "Descriptive index of the quality of your week",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  )),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 10, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (provider.score.toInt()).toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      provider.score / 100 < 0.33
                          ? "Low"
                          : provider.score / 100 > 0.33 &&
                                  provider.score / 100 < 0.66
                              ? "Medium"
                              : "High",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      height: 15,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          value: provider.score / 100,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Explore Daily Trends in each parameter",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text("See how much you’ve been striving throughout the week",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  )),
              const SizedBox(
                height: 10,
              ),
              Text('Sleep Data'),
              (provider.sleepData.isEmpty) ? const CircularProgressIndicator.adaptive() :
                Card(
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(Icons.bedtime),
                            trailing: Container(child: (Provider.of<HomeProvider>(context).sleepAvg()>=8) ? const Icon(Icons.thumb_up) : const Icon(Icons.thumb_down),), //qui mettere la media della settimana al posto del solo primo giorno
                            title:
                                Text('Sleep : ${Provider.of<HomeProvider>(context).sleepAvg()} hours'),
                            subtitle: Text('Average hours of sleep for this week'),
                            //When a ListTile is tapped, the user is redirected to the SleepPage
                            //onTap: () => _toSleepPage(context),
                          ),
                  ),
                const SizedBox(height: 10,),
                Text('Exercise Data'),
                (provider.exerciseData.isEmpty) ? const CircularProgressIndicator.adaptive() :
                  Card(
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(Icons.directions_run),
                              trailing: Container(child: (Provider.of<HomeProvider>(context).exerciseDuration()>=30*7) ? const Icon(Icons.thumb_up) : const Icon(Icons.thumb_down),), //qui mettere la media della settimana al posto del solo primo giorno
                              title:
                                  Text('Exercise : ${Provider.of<HomeProvider>(context).exerciseDuration()} minutes'),
                              subtitle: Text('Total minutes of exercise performed this week'),
                              //When a ListTile is tapped, the user is redirected to the ExercisePage
                              //onTap: () => _toSleepPage(context),
                            ),
                    ),
            ],
          );
        }),
      ),
    ));
  }
}

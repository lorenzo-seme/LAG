import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:provider/provider.dart';


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
                      provider.getDataOfDay(provider.showDate.subtract(const Duration(days: 1)));
                      provider.getDataOfWeek(provider.showDate.subtract(const Duration(days: 1)));
                    },
                    child: const Icon(
                      Icons.navigate_before,
                    ),
                  ),
                ),
                // potremmo mettere qui la settimana che stiamo visualizzando
                //Text('${DateFormat('EEE, d MMM').format(provider.monday!)} - ${DateFormat('EEE, d MMM').format(provider.sunday!)}'), // PROBLEMA !!!
                Text(DateFormat('EEE, d MMM').format(provider.showDate)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      provider.getDataOfDay(provider.showDate.add(const Duration(days: 1)));
                      provider.getDataOfWeek(provider.showDate.add(const Duration(days: 1)));
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
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              // e qui magari il plot della settimana, per ognuna delle statistiche. In alternativa, un altra schermata come quella sopra
              // in cui si usano le frecce per muoversi tra i vari giorni.
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    if (provider.heartRateData.isEmpty | provider.exerciseData.isEmpty | provider.sleepData.isEmpty) {
                      return const CircularProgressIndicator.adaptive();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(children: [
                        //N.B. Gestire i casi in cui i dati non sono presenti! Per ora, ai fini del debug ho messo che giri la rotellina
                        // nei giorni in cui manca uno di questi dati..
                        //Questa in realtà è la pagina del weeklyrecap, quindi sarebbe da cambiare il giorno indicato in alto
                        Text('Dati del giorno ${provider.showDate.toString().substring(0,10)}',
                              style: TextStyle(fontSize: 16)),
                        Text('Resting heart rate: ${provider.heartRateData.last.value} bpm'),
                        Text('Exercise duration: ${provider.exerciseData.last.duration} minutes'),
                        Text('Sleep duration: ${provider.sleepData.last.value} hours'),
                      ],)
 
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    ));
  }
}

/*
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    if(provider.sleepData.isEmpty){
                    //if (provider.heartRateData.isEmpty | provider.exerciseData.isEmpty | provider.sleepData.isEmpty) {
                      return const CircularProgressIndicator.adaptive();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomPlot(
                          sleep: provider.sleepData,
                        ),

                        /*
                      child: ListView(children: [
                        //N.B. Gestire i casi in cui i dati non sono presenti! Per ora, ai fini del debug ho messo che giri la rotellina
                        // nei giorni in cui manca uno di questi dati..
                        //Questa in realtà è la pagina del weeklyrecap, quindi sarebbe da cambiare il giorno indicato in alto
                        //Text('Dati del giorno ${provider.showDate.toString().substring(0,10)}',
                              //style: TextStyle(fontSize: 16)),
                        Text('${DateFormat('EEE, d MMM').format(provider.monday!)} - ${DateFormat('EEE, d MMM').format(provider.sunday!)}'),
                        //Text('Resting heart rate: ${provider.heartRateData.last.value} bpm'),
                        //Text('Exercise duration: ${provider.exerciseData.last.duration} minutes'),
                        Text('Sleep duration of monday: ${provider.sleepData[0].value} hours'),
                        Text('Sleep duration of tuesday: ${provider.sleepData[1].value} hours'),
                      ],)
*/
                    );
                  },
                ),
              ),
              */
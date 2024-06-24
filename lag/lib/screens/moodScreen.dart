import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';

class MoodScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;
  
  const MoodScreen({super.key, required this.startDate, required this.endDate, required this.provider});

  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {

  // ha senso che questa pagina esista solo nel giorno corrente (visto che inseriamo il mood di oggi)
  // ha senso magari salvare man mano che uno li inserisce i dati di come ti senti oggi nelle sp (bisogna gestire una lista rappresentata da una stringa, valuta caratteri speciali da riconoscere per spezzare)
  // idem con il testo, magari uno è interessato a vedere lo storico del suo diario

  // tieni conto che la settimana da cui entri arriva fino a ieri, ora sei su oggi

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.wb_cloudy),
            const SizedBox(width: 10),
            Text(DateFormat('EEE, d MMM').format(DateTime.now().subtract(const Duration(days: 1))), 
              textAlign: TextAlign.center, 
              style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold))
          ],
        ),        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color.fromARGB(255, 227, 211, 244), 
      ),
      body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: _buildMoodTrackerCard()
            )
          )
      )
    );
  }

}


Widget _buildMoodTrackerCard() {
  List<IconData> moodIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  List<Color> moodColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
  ];
  
  List<String> moodLabels = [
    "Very Dissatisfied",
    "Dissatisfied",
    "Neutral",
    "Satisfied",
    "Very Satisfied",
  ];

  return Card(
    color: const Color.fromARGB(255, 242, 239, 245),
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.mood),
            title: Text(
              "Track Your Mood",
              style: TextStyle(fontSize: 14.0),
            ),
            subtitle: Text(
              'Tap on the icons to record your mood',
              style: TextStyle(fontSize: 10.0),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(moodIcons.length, (index) {
              return GestureDetector(
                onTap: () {
                  // Handle mood selection here
                  print("Mood selected: ${moodLabels[index]}");
                },
                child: Column(
                  children: [
                    Icon(
                      moodIcons[index],
                      color: moodColors[index],
                      size: 40,
                    ),
                    /*Text(
                      moodLabels[index],
                      style: const TextStyle(fontSize: 10.0),
                    ),*/
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );
}

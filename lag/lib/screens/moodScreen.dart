// DA SISTEMARE
// 1. FAI IN MODO CHE SAVE IN MY DIARY SIA POSSIBILE SOLO QUANDO C'è EFFETTIVAMENTE DEL TESTO INSERITO NEL BOX
// 2. FAI IN MODO CHE OLTRE CHE A RICORDARE NEL PROVIDER CHE HAI GIà INSERITO IL MOOD, CHE ANCHE NON TI RICHIEDA DI DIRE COME MAI TI SEI SENTITO COSI
// 3. POTREBBE ESSERE UN PROBLEMA SALVARE QUESTE COSE NELLE SP SE POI CON IL LOGOUT VIENE TUTTO DIMENTICATO: 
//    MAGARI VALUTA DI FARE IN MODO CHE CON IL LOG IN QUELLE INFO VENGANO RICORDATE
// 4. NEL PROVIDER FORSE CONVERRà CAMBIARE IL GETMOOD SULLA STESSA LOGICA DI GETMOODTEXT (DA VALUTARE QUANDO CALCOLEREMO LO SCORE TOTALE)

// AD AGGIUNGERE
// 1. CONSIGLI RANDOMICI MOTIVAZIONALI IN BASE AL MOOD
// 2. CONSIGLI MUSICALI IN BASE AL GENERE PREFERITO?
// 3. DISCAIMER SULL'IMPORTANZA DEL MOOD TRACKING

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/diaryScreen.dart';
//import 'package:provider/provider.dart';

class MoodScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final HomeProvider provider;
  
  const MoodScreen({super.key, required this.startDate, required this.endDate, required this.provider});

  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMoodIndex;
  final TextEditingController _moodController = TextEditingController();
  bool _saved = false; // To track if save button was pressed

  List<IconData> moodIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];
  
  /*
  List<Color> moodColors = [
    const Color.fromARGB(255, 203, 151, 246),
    const Color.fromARGB(255, 203, 151, 246),
    const Color.fromARGB(255, 203, 151, 246),
    const Color.fromARGB(255, 203, 151, 246),
    const Color.fromARGB(255, 203, 151, 246),
  ];*/
  
  List<String> moodLabels = [
    "very sad",
    "a little sad",
    "just okay",
    "quite happy",
    "very happy",
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.wb_cloudy),
            const SizedBox(width: 10),
            Text(
              DateFormat('EEE, d MMM').format(DateTime.now()), 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
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
            child: Column(
              children: [
                _buildMoodTrackerCard(),
                _buildToDiaryCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Carica lo stato precedente dell'icona selezionata se todayMoodTracked è true
    if (widget.provider.todayMoodTracked) {
      widget.provider.getMoodScore(DateTime.now()).then((moodScore) {
        if (moodScore != null) {
          setState(() {
            _selectedMoodIndex = moodScore - 1;
          });
        }
      });
    }
  }

  Widget _buildMoodTrackerCard() {
    return Card(
      color: const Color.fromARGB(255, 242, 239, 245),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              //contentPadding: EdgeInsets.zero,
              title: Text("Track Your Mood", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              subtitle: Text('Tap on the icons to record your mood', style: TextStyle(fontSize: 11.0)),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(moodIcons.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMoodIndex = index;
                      _saveMood();
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        moodIcons[index],
                        color: _selectedMoodIndex == index 
                          ? const Color.fromARGB(255, 150, 37, 243) // Change the color to indicate selection
                          //: moodColors[index],
                          : const Color.fromARGB(255, 203, 151, 246),
                        size: _selectedMoodIndex == index 
                          ? 50 // Increase the size to indicate selection
                          : 40,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 5),
            if (_selectedMoodIndex != null) _buildMoodInputField(), // Embed the input field within the card
          ],
        ),
      ),
    );
  }

  Widget _buildMoodInputField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (!_saved) // Display motivational message if saved
          ? Text(
              "How come you feel ${moodLabels[_selectedMoodIndex!]} today?",
              style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
            )
          : const Text(
              "Thanks for sharing your thoughts.\nYou did a great job expressing your feelings!",
              style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 10),
          TextField(
            maxLines: 3,
            controller: _moodController,
            decoration: InputDecoration(
              hintText: !_saved || widget.provider.todayMoodTracked
                ? 'Enter your thoughts here...'
                : 'This box will stay open for you.\nFeel free to enter any other thought that comes to your mind!',
              hintStyle: const TextStyle(fontSize: 12),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitFeelings,
            child: const Text("Save in my diary"),
          ),
        ],
      ),
    );
  }

  void _submitFeelings() {
    setState(() {
      _saved = true;
      _saveMoodText(_moodController.text); 
      _moodController.clear(); // Clear the text field
    });
  }

  Future<void> _saveMood() async {
    int moodScore = _selectedMoodIndex! + 1; // Scores are from 1 to 5
    widget.provider.setTodayMoodTracked(true); // Update provider
    await widget.provider.saveMoodScore(DateTime.now(), moodScore); // Save mood score to provider
    //print("Mood saved: $moodScore, Reason: ${_moodController.text}");
  }

  Future<void> _saveMoodText(String text) async {
    await widget.provider.saveMoodText(DateTime.now(), text); // Salva il testo dell'umore nel provider
  }
  
  Widget _buildToDiaryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => DiaryScreen(provider: widget.provider)), 
        );
      },
      child: const Card(
        color: Color.fromARGB(255, 242, 239, 245),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: ListTile(
            //contentPadding: EdgeInsets.zero,
            trailing: Icon(Icons.book),
            title: Text("My diary", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            subtitle: Text('Tap to read your old thoughts', style: TextStyle(fontSize: 11.0)),
          ),
        ),
      ),
    );
  }
}

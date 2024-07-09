import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/diaryScreen.dart';

class MoodScreen extends StatefulWidget {
  final HomeProvider provider;
  
  const MoodScreen({super.key, required this.provider});

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
  
  List<String> moodLabels = [
    "very sad",
    "a little sad",
    "just okay",
    "quite happy",
    "very happy",
  ];

  Map<String, List<String>> moodMotivationalPhrases = {
    "very sad": [
      "Even the darkest nights will end and the sun will rise again.",
      "You are stronger than you know, and you will get through this.",
      "It's okay to not be okay right now. Take your time.",
      "Sending you love and strength during this difficult time.",
      "Remember, storms don't last forever. Brighter days are ahead.",
      "You're not alone. Reach out to those who care about you.",
      "Healing takes time, but you're on the path to recovery.",
      "Every setback is a setup for a comeback. Hang in there.",
      "You are worthy of love and happiness, even on tough days.",
      "Allow yourself to feel what you need to feel. It's a part of healing.",
      "One day at a time. You're doing the best you can.",
      "Your strength and resilience are inspiring, even in moments of sadness.",
      "Let yourself rest. Healing begins with self-compassion.",
      "The world needs your light, even when it feels dim.",
      "Your feelings are valid. Take each moment as it comes.",
      "Be gentle with yourself. You're navigating through rough waters.",
      "You have overcome challenges before, and you will overcome this one too.",
      "There is beauty in the journey of healing, even amidst pain.",
      "Your heart knows how to heal itself. Trust in the process.",
      "In the depth of winter, I finally learned that within me there lay an invincible summer.",
    ],
    "a little sad": [
      "Every cloud has a silver lining, even on gray days.",
      "You are allowed to take breaks and rest when you need it.",
      "Sending you a virtual hug to brighten your day.",
      "Find comfort in small moments of joy and peace.",
      "You're doing the best you can, and that's enough.",
      "Tomorrow is a new day with new opportunities.",
      "Your resilience is admirable, even when things feel tough.",
      "Sometimes a good cry is the first step towards feeling better.",
      "Lean on those who lift you up during challenging times.",
      "Allow yourself to feel your emotions fully; it's a sign of strength.",
      "You are stronger than you know, even on days when it doesn't feel like it.",
      "It's okay to ask for help. You don't have to go through this alone.",
      "Your presence makes a difference, even on days when you feel low.",
      "Take comfort in knowing that better days are ahead.",
      "You are worthy of love and belonging, always.",
      "Even amidst sadness, find moments of gratitude.",
      "Believe in your ability to overcome obstacles.",
      "Gentle reminders: You are loved, you matter, and you are enough.",
      "The world needs your unique light and perspective.",
      "Be kind to yourself as you navigate through challenging emotions."
    ],
    "just okay": [
      "Every day may not be good, but there is something good in every day.",
      "Trust the timing of your life. Everything will fall into place.",
      "You're on a journey, and every step forward is progress.",
      "Embrace the uncertainty; it leads to new opportunities.",
      "You are where you need to be right now. Trust the process.",
      "Your resilience is inspiring, even when things feel uncertain.",
      "Find joy in the small moments and simple pleasures.",
      "Life is a series of ups and downs; embrace the ride.",
      "Give yourself credit for how far you've come.",
      "You have the strength to face whatever comes your way.",
      "Even on average days, you're capable of extraordinary things.",
      "Trust yourself. You've navigated through challenges before.",
      "Your journey is unique and valuable. Honor it.",
      "Celebrate your progress, no matter how small.",
      "Your presence makes a difference, even on ordinary days.",
      "Embrace the ebb and flow of life's rhythms.",
      "Cherish the moments of calm and peace.",
      "Focus on what you can control; let go of what you cannot.",
      "You have the power to create positive change in your life.",
      "You're capable of finding happiness in unexpected places.",
    ],
    "quite happy": [
      "Your positivity shines bright and lifts those around you.",
      "Celebrate the small victories; they lead to big achievements.",
      "Your optimism is contagious. Keep spreading joy.",
      "Find joy in the journey, not just the destination.",
      "You radiate happiness and warmth wherever you go.",
      "Embrace the feeling of contentment and gratitude.",
      "You deserve all the happiness that comes your way.",
      "Your smile brightens even the cloudiest of days.",
      "Take a moment to appreciate how far you've come.",
      "Your positive attitude is a powerful force for good.",
      "Celebrate yourself today. You're making a positive impact.",
      "Your happiness is a reflection of your inner strength.",
      "Spread kindness and joy wherever you go.",
      "Focus on the present moment; it's where happiness resides.",
      "Your resilience and optimism inspire those around you.",
      "Stay true to the things that bring you joy.",
      "You have the power to create a life filled with happiness.",
      "Find beauty in the simple pleasures of everyday life.",
      "Your enthusiasm and zest for life are inspiring.",
      "Choose happiness, even when faced with challenges."
    ],
    "very happy": [
      "Your happiness is a beacon of light for those around you.",
      "Celebrate today like it's the best day of your life.",
      "Embrace the abundance of joy and positivity in your life.",
      "Your energy and enthusiasm are contagious. Keep shining.",
      "Dance like nobody's watching and sing like nobody's listening.",
      "Celebrate your accomplishments with pride and gratitude.",
      "You exude confidence and joy in everything you do.",
      "Spread your happiness like confetti; the world needs it.",
      "Your laughter is the soundtrack of a joyful life.",
      "Stay true to the things that make your heart sing.",
      "Every day is a new opportunity to celebrate life.",
      "Your happiness is a reflection of your inner peace and contentment.",
      "Surround yourself with positivity and watch it multiply.",
      "Live in the moment and savor the happiness it brings.",
      "You're living your best life, and it's a beautiful sight.",
      "Share your happiness with others; it multiplies.",
      "Your positivity creates a ripple effect of joy.",
      "Celebrate the journey that led you to this moment of happiness.",
      "Your smile lights up the room and warms hearts.",
      "Chase your dreams with a heart full of joy and determination.",
    ],
  };

  String? _selectedMotivationalPhrase;

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
          icon: const Icon(Icons.arrow_back), 
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
                const Text("How are you feeling today?", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(202, 97, 20, 169))), 
                const Text('Tracking your mood can provide valuable insights into your emotional well-being, helping you identify triggers',
                  style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,),
                const SizedBox(height: 5),
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
    if (widget.provider.todayMoodTracked) {
      widget.provider.getMoodScore(DateTime.now()).then((moodScore) {
        if (moodScore != null) {
          setState(() {
            _selectedMoodIndex = moodScore - 1;
          });
        }
      });
    }
    if (widget.provider.firstThoughtsubmitted) {
      _saved = true;
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
                      _selectRandomMotivationalPhrase(moodLabels[index]);
                      _saveMood();
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        moodIcons[index],
                        color: _selectedMoodIndex == index 
                          ? const Color.fromARGB(255, 241, 98, 88)
                          : const Color.fromARGB(202, 97, 20, 169), 
                        size: _selectedMoodIndex == index 
                          ? 50
                          : 40,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            if (_selectedMotivationalPhrase != null) _buildMotivationalPhrase(),
            const SizedBox(height: 5),
            if (_selectedMoodIndex != null) _buildMoodInputField(),
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
          (!_saved)
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
                hintText: !_saved 
                  ? 'Enter your thoughts here...'
                  : 'This box will stay open for you.\nFeel free to enter any other thought that comes to your mind!',
                hintStyle: const TextStyle(fontSize: 12),
                border: const OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitFeelings,
            child: const Text("Save in my diary",
              style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(202, 97, 20, 169), 
                  ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMotivationalPhrase() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:  const Color.fromARGB(202, 97, 20, 169), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMotivationalPhrase!,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white), 
          ),
        ],
      ),
    );
  }

  void _submitFeelings() async {
  if (_moodController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter your thoughts before saving.')),
    );
    return;
  }
  await _saveMoodText(_moodController.text);
  setState(() {
    _saved = true;
  });
  _moodController.clear();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Your mood has been saved successfully.')),
  );
}

  Future<void> _saveMood() async {
    int moodScore = _selectedMoodIndex! + 1;
    await widget.provider.saveMoodScore(DateTime.now(), moodScore);
  }

Future<void> _saveMoodText(String text) async {
  await widget.provider.saveMoodText(DateTime.now(), text);
}


  void _selectRandomMotivationalPhrase(String moodLabel) {
    final List<String> phrases = moodMotivationalPhrases[moodLabel]!;
    final Random random = Random();
    _selectedMotivationalPhrase = phrases[random.nextInt(phrases.length)];
  }
  
  Widget _buildToDiaryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => DiaryScreen(provider: widget.provider, showArrow: true,)), 
        );
      },
      child: const Card(
        color: Color.fromARGB(255, 242, 239, 245),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: ListTile(
            trailing: Icon(Icons.book),
            title: Text("My diary", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            subtitle: Text('Tap to read your old thoughts', style: TextStyle(fontSize: 11.0)),
          ),
        ),
      ),
    );
  }
}
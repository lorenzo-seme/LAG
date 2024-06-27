// DA SISTEMARE LA GRAFICA !!!!
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';

class DiaryScreen extends StatefulWidget {
  final HomeProvider provider;

  const DiaryScreen({Key? key, required this.provider}) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: widget.provider.getMoodText(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No mood texts available'));
          } else {
            Map<String, dynamic> moodTexts = snapshot.data!;
            return ListView.builder(
              itemCount: moodTexts.length,
              itemBuilder: (context, index) {
                String dateString = moodTexts.keys.elementAt(index);
                DateTime date = DateTime.parse(dateString);
                return _buildMoodTextCard(date, moodTexts[dateString]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMoodTextCard(DateTime date, String moodText) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          DateFormat('MMMM d, y').format(date),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              moodText,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}

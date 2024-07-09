import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';

class DiaryScreen extends StatefulWidget {
  final HomeProvider provider;
  final bool showArrow;

  const DiaryScreen({Key? key, required this.provider, required this.showArrow}) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final Set<DateTime> _expandedCards = Set<DateTime>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.book),
            SizedBox(width: 10),
            Text(
              "My Diary", 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),        
        leading: (widget.showArrow)
        ?  IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        : null,
        backgroundColor: const Color.fromARGB(255, 227, 211, 244), 
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: widget.provider.getMoodText(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("You did not write anything on your diary yet.\nStart now sharing your thoughts!",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),));
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
    final bool isExpanded = _expandedCards.contains(date);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        color: const Color.fromARGB(255, 242, 239, 245),
        elevation: 5,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCards.remove(date);
              } else {
                _expandedCards.add(date);
              }
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  DateFormat('MMMM d, y').format(date),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: !isExpanded
                    ? const Text('Tap to expand', style: TextStyle(fontSize: 10.0))
                    : null,
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    moodText,
                    style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';

class DiaryScreen extends StatefulWidget {
  final HomeProvider provider;
  final bool showArrow;
  const DiaryScreen({Key? key, required this.provider, required this.showArrow}) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  bool _isMoodTextCardExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.book),
            SizedBox(width: 10),
            Text(
              "My Diary", 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),        
        leading: (widget.showArrow)
        ?  IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        : null,
        backgroundColor: const Color.fromARGB(255, 227, 211, 244), 
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: widget.provider.getMoodText(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("You did not write anything on your diary yet.\nStart now sharing your thoughts!",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),));
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
  
  /*
  Widget _buildMoodTextCard(DateTime date, String moodText) {
    return Card(
      margin: const EdgeInsets.all(8.0),
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
  }*/

  Widget _buildMoodTextCard(DateTime date, String moodText) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        color: const Color.fromARGB(255, 242, 239, 245),
        elevation: 5,
        child: InkWell(
          onTap: () {
            setState(() {
              _isMoodTextCardExpanded = !_isMoodTextCardExpanded;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  DateFormat('MMMM d, y').format(date),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: !_isMoodTextCardExpanded
                    ? const Text('Tap to expand', style: TextStyle(fontSize: 10.0))
                    : null,
              ),
              if (_isMoodTextCardExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    moodText,
                    style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}
*/
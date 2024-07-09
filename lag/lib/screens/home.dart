import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/diaryScreen.dart';
import 'package:lag/screens/profile.dart';
import 'package:lag/screens/weeklyRecap.dart';

class Home extends StatefulWidget {
  final HomeProvider provider;
  const Home({super.key, required this.provider});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selIdx = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selIdx = index;
    });
  }

  List<BottomNavigationBarItem> navBarItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Diary',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.manage_accounts),
      label: 'Profile',
    ),
  ];

  Widget _selectPage({
    required int index,
  }) {
    switch (index) {
      case 0:
        return const WeeklyRecap();
      case 1:
        return DiaryScreen(provider: widget.provider, showArrow: false,);
      case 2:
        return Profile(provider: widget.provider,);
      default:
        return const WeeklyRecap();
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _selectPage(index: _selIdx),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFf5f7f7),
          items: navBarItems,
          currentIndex: _selIdx,
          onTap: _onItemTapped,
        )
    );
  }
}

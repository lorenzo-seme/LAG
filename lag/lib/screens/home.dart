import 'package:flutter/material.dart';
import 'package:lag/screens/profile.dart';
import 'package:lag/screens/weeklyRecap.dart';

class Home extends StatefulWidget {
  const Home({super.key});

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
    BottomNavigationBarItem(
      icon: Icon(Icons.manage_accounts),
      label: 'Profile',
    ),
  ];

  Widget _selectPage({
    required int index,
  }) {
    switch (index) {
      case 0:
        return WeeklyRecap();
      case 1:
        return Profile();
      default:
        return WeeklyRecap();
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
        ));
  }
}

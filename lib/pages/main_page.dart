import 'package:flutter/material.dart';
import 'package:planer/helper/preference_manager.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedPageIndex = myPreferences.getInt('lastPageIndex') ?? 0;
  final List<BottomNavigationBarItem> _navigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Meine Liste'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Kalender')
      ] +
      getNavBarPrefs();

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    myPreferences.setInt('lastPageIndex', _selectedPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            color: const Color(0xffffffff),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: _navigationBarItems,
          currentIndex: _selectedPageIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}

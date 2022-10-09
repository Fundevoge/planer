import 'package:flutter/material.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/page_elements/calendar.dart';
import 'package:planer/page_elements/todolist.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedPageIndex = myPreferences.getInt('lastPageIndex') ?? 0;
  final List<BottomNavigationBarItem> _navigationBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Kalender'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Komplizierter Kalender'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Meine Liste'),
      ] +
      getNavBarPrefs();
  late final List<Widget> views;

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    myPreferences.setInt('lastPageIndex', _selectedPageIndex);
  }

  @override
  void initState() {
    views = <Widget>[const TaskCalendar(), const ListAndPool()] +
        _navigationBarItems.sublist(1).map((e) => TodoList(title: e.label ?? 'Unbenannte Liste')).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: views[_selectedPageIndex]
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

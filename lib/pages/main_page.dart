import 'package:flutter/material.dart';
import 'package:planer/backend/helper.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/models/todolist.dart';
import 'package:planer/page_elements/calendar.dart';
import 'package:planer/page_elements/todolistview.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedPageIndex = myPreferences.getInt('lastPageIndex') ?? 0;
  final List<BottomNavigationBarItem> _navigationBarItems = <BottomNavigationBarItem>[
        const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Kalender'),
      ] +
      todoLists.map((e) => BottomNavigationBarItem(icon: e.listIcon, label: e.listName, )).toList();
  late final List<Widget> views;

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    myPreferences.setInt('lastPageIndex', _selectedPageIndex);
  }

  @override
  void initState() {
    views = <Widget>[const TaskCalendar()] +
        todoLists.map((e) => ListPoolView(todoList: e,)).toList();
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
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedItemColor: greyedColor(_selectedPageIndex == 0 ? Colors.blueAccent : todoLists[_selectedPageIndex-1].listColor),
          selectedItemColor: _selectedPageIndex == 0 ? Colors.blueAccent : todoLists[_selectedPageIndex-1].listColor,
        ),
      ),
    );
  }
}

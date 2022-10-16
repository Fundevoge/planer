import 'package:flutter/material.dart';
import 'package:planer/backend/helper.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/models/todolist.dart';
import 'package:planer/page_elements/calendarview.dart';
import 'package:planer/page_elements/todolistview.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}
const double tabBarHeight = 60;
const double tabWidth = 80;
late bool tabsIsScrollable;
class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<CustomTab> _navigationTabs = <CustomTab>[
        const CustomTab(icon: Icon(Icons.calendar_month_rounded), text: 'Kalender'),
      ] +
      todoLists
          .map((e) => CustomTab(
                icon: e.listIcon,
                text: e.listName,
              ))
          .toList();

  late final List<Widget> views;

  @override
  void initState() {
    views = <Widget>[const TaskCalendar()] +
        todoLists
            .map((e) => ListPoolView(
                  todoList: e,
                ))
            .toList();
    _tabController = TabController(length: views.length, vsync: this, initialIndex: myPreferences.getInt('lastPageIndex') ?? 0);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (_context, constraints) {
          tabsIsScrollable = tabWidth * _navigationTabs.length > constraints.maxWidth;
          return Column(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: constraints.maxHeight - tabBarHeight,
                child: TabBarView(
                  children: views,
                  controller: _tabController,
                ),
              ),
            ),
            Material(
              color: const Color(0xFFF9F9F9),
              child: SizedBox(
                height: tabBarHeight,
                width: constraints.maxWidth,
                child: TabBar(
                  controller: _tabController,
                  indicator: const UnderlineTabIndicator(borderSide: BorderSide(width: 3.0, color: Color(0xFF1995FF)),),
                  isScrollable: tabsIsScrollable,
                  unselectedLabelColor:
                      greyedColor(_tabController.index == 0 ? Colors.blueAccent : todoLists[_tabController.index - 1].listColor),
                  labelColor: _tabController.index == 0 ? Colors.blueAccent : todoLists[_tabController.index - 1].listColor,
                  tabs: _navigationTabs,
                  onTap: (index) => myPreferences.setInt('lastPageIndex', index),
                ),
              ),
            ),
          ],
        );
        },
      ),
    );
  }
}

class CustomTab extends StatelessWidget {
  const CustomTab({Key? key, required this.icon, required this.text}) : super(key: key);
  final Icon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tabBarHeight*0.92,
      width: tabWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [icon, Text(text, style: const TextStyle(fontSize: 12, ), overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 2, textAlign: TextAlign.center,), ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:planer/backend/persistance_manager.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/backend/tasks.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late final LinkedHashMap<Date, List<ToH>> listsByDate;
    DateTime displayedListDate = DateTime.now();

  @override
  void initState() {
    listsByDate = todoLists[widget.title]!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      children: listsByDate[Date.fromDateTime(DateTime.now())]!
          .map((e) => TileToH(
              key: e.uid,
              toh: e,
              moveToDone: (_) => {},
              enterSelectionMode: () => {},
              showConstraints: (_) => {},
              startTimer: (_) => {},
              onTapCallback: (_) => {}))
          .toList(),
    );
  }
}

class Pool extends StatefulWidget {
  const Pool({Key? key}) : super(key: key);

  @override
  State<Pool> createState() => _PoolState();
}

class _PoolState extends State<Pool> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      children: const [],
    );
  }
}

class ListAndPool extends StatefulWidget {
  const ListAndPool({Key? key}) : super(key: key);

  @override
  State<ListAndPool> createState() => _ListAndPoolState();
}

class _ListAndPoolState extends State<ListAndPool> {
  // Top flex to bottom flex
  double? topHeight = myPreferences.getDouble("MainViewTopHeight");
  double? bottomHeight = myPreferences.getDouble("MainViewBottomHeight");

  _handleUpdate(DragUpdateDetails details) {
    double deltaY = details.delta.dy;
    if (topHeight! + deltaY < 0) {
      deltaY = -topHeight!;
    } else if (bottomHeight! - deltaY < 0) {
      deltaY = bottomHeight!;
    }
    setState(() {
      topHeight = topHeight! + deltaY;
      bottomHeight = bottomHeight! - deltaY;
    });
  }

  _handlePanEnd(DragEndDetails details) {
    myPreferences.setDouble("MainViewTopHeight", topHeight!);
    myPreferences.setDouble("MainViewBottomHeight", bottomHeight!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      topHeight ??= (constraints.maxHeight - 24) / 2;
      bottomHeight ??= (constraints.maxHeight - 24) / 2;
      return Column(
        children: [
          SizedBox(
            height: topHeight!,
            child: TodoList(title: "own"),
          ),
          GestureDetector(
            onPanUpdate: _handleUpdate,
            onPanEnd: _handlePanEnd,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF303030),
                ),
              ),
              height: 24,
              child: InkWell(
                child: Center(
                  child: Icon(Icons.menu),
                ),
              ),
            ),
          ),
          SizedBox(
            height: bottomHeight!,
            child: Pool(),
          ),
        ],
      ); // create function here to adapt to the parent widget's constraints
    });
  }
}

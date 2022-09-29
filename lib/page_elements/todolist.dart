import 'package:flutter/material.dart';
import 'package:planer/backend/preference_manager.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      children: const [],
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
            child: TodoList(title: "TestList"),
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

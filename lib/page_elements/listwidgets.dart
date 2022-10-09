import 'package:flutter/material.dart';
import 'package:planer/backend/persistance_manager.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/models/todolist.dart';
import 'package:planer/page_elements/taskwidgets.dart';

class TodoListWidget extends StatefulWidget {
  const TodoListWidget({Key? key, required this.todoList}) : super(key: key);
  final TodoList todoList;
  @override
  State<TodoListWidget> createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {
    Date displayedListDate = Date.now();

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      children: widget.todoList.tohs[displayedListDate]!
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

class TodoPoolWidget extends StatefulWidget {
  const TodoPoolWidget({Key? key}) : super(key: key);

  @override
  State<TodoPoolWidget> createState() => _TodoPoolWidgetState();
}

class _TodoPoolWidgetState extends State<TodoPoolWidget> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      children: const [],
    );
  }
}

class ListAndPool extends StatefulWidget {
  final TodoList todoList;
  const ListAndPool({Key? key, required this.todoList, }) : super(key: key);

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
            child: TodoListWidget(todoList: widget.todoList),
          ),
          GestureDetector(
            onPanUpdate: _handleUpdate,
            onPanEnd: _handlePanEnd,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF303030),
                ),
              ),
              height: 24,
              child: const InkWell(
                child: Center(
                  child: Icon(Icons.menu),
                ),
              ),
            ),
          ),
          SizedBox(
            height: bottomHeight!,
            child: TodoPoolWidget(),
          ),
        ],
      ); // create function here to adapt to the parent widget's constraints
    });
  }
}

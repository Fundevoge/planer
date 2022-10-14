import 'package:flutter/material.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/models/date.dart';
import 'package:planer/models/tasks.dart';
import 'package:planer/models/todolist.dart';
import 'package:planer/page_elements/taskwidgets.dart';

class ListPoolView extends StatefulWidget {
  final TodoList todoList;

  const ListPoolView({
    Key? key,
    required this.todoList,
  }) : super(key: key);

  @override
  State<ListPoolView> createState() => _ListPoolViewState();
}

final TextEditingController _nameController = TextEditingController();
final TextEditingController _noteController = TextEditingController();
// Top flex to bottom flex
late double? topHeight;
late double? bottomHeight;
late int _currentTodoPoolIndex;
Date displayedListDate = Date.now();
late bool showCheckedTodo;
late bool showCheckedPool;

void initListPool() {
  topHeight = myPreferences.getDouble("MainViewTopHeight");
  bottomHeight = myPreferences.getDouble("MainViewBottomHeight");
  _currentTodoPoolIndex = myPreferences.getInt("currentTodoPoolIndex") ?? 0;

  showCheckedTodo = myPreferences.getBool("showCheckedTodo") ?? false;
  showCheckedPool = myPreferences.getBool("showCheckedPool") ?? false;
}

class _ListPoolViewState extends State<ListPoolView> {
  @override
  void initState() {
    super.initState();
  }

  bool showTaskEditDialog(BuildContext context, ToH toH) {
    bool _hasChanged = false;
    showDialog(
        context: context,
        builder: (_context) {
          return AlertDialog(
            content: SizedBox(
              height: 400,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    onChanged: (val) {
                      toH.name = val;
                      _hasChanged = true;
                    },
                  ),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(hintText: 'Notizen'),
                    onChanged: (val) {
                      toH.notes = val;
                      _hasChanged = true;
                    },
                  ),
                ],
              ),
            ),
          );
        }).then((value) => {});
    return _hasChanged;
  }

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
          // Todolist
          SizedBox(
            height: topHeight!,
            child: ListView(
              children: [
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  onReorder: (int oldIndex, int newIndex) {},
                  children: widget.todoList.tohs[displayedListDate]!
                      .where((element) => !element.isDone)
                      .map((e) => TileToH(
                          key: e.uid,
                          toh: e,
                          moveToDone: (_) => {},
                          enterSelectionMode: () => {},
                          showConstraints: (_) => {},
                          startTimer: (_) => {},
                          onTapCallback: (_) => {}))
                      .toList(),
                ),
                TextButton(
                  child: showCheckedTodo
                      ? Row(
                          children: const [
                            RotatedBox(
                              quarterTurns: 1,
                              child: Icon(Icons.chevron_right),
                            ),
                            Text("Abgehakte anzeigen"),
                          ],
                        )
                      : Row(
                          children: const [Icon(Icons.chevron_right), Text("Abgehakte ausblenden")],
                        ),
                  onPressed: () {
                    setState(() => showCheckedTodo = !showCheckedTodo);
                    myPreferences.setBool("showCheckedTodo", showCheckedTodo);
                  },
                ),
                if (showCheckedTodo)
                  ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: widget.todoList.tohs[displayedListDate]!
                          .where((element) => element.isDone)
                          .map((e) => TileToH(
                              key: e.uid,
                              toh: e,
                              moveToDone: (_) => {},
                              enterSelectionMode: () => {},
                              showConstraints: (_) => {},
                              startTimer: (_) => {},
                              onTapCallback: (_) => {}))
                          .toList())
              ],
            ),
          ),
          // Spacer between
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
          // Pool
          SizedBox(
            height: bottomHeight!,
            child: ListView(
              children: [
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  onReorder: (int oldIndex, int newIndex) {},
                  children: todoPools[_currentTodoPoolIndex]
                      .tohs
                      .where((element) => !element.isDone)
                      .map((e) => TileToH(
                          key: e.uid,
                          toh: e,
                          moveToDone: (_) => {},
                          enterSelectionMode: () => {},
                          showConstraints: (_) => {},
                          startTimer: (_) => {},
                          onTapCallback: (_) => {}))
                      .toList(),
                ),
                TextButton(
                  child: showCheckedPool
                      ? Row(
                          children: const [
                            RotatedBox(
                              quarterTurns: 1,
                              child: Icon(Icons.chevron_right),
                            ),
                            Text("Abgehakte anzeigen"),
                          ],
                        )
                      : Row(
                          children: const [Icon(Icons.chevron_right), Text("Abgehakte ausblenden")],
                        ),
                  onPressed: () {
                    setState(() => showCheckedPool = !showCheckedPool);
                    myPreferences.setBool("showCheckedPool", showCheckedPool);
                  },
                ),
                if (showCheckedPool)
                  ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: todoPools[_currentTodoPoolIndex]
                          .tohs
                          .where((element) => element.isDone)
                          .map((e) => TileToH(
                              key: e.uid,
                              toh: e,
                              moveToDone: (_) => {},
                              enterSelectionMode: () => {},
                              showConstraints: (_) => {},
                              startTimer: (_) => {},
                              onTapCallback: (_) => {}))
                          .toList())
              ],
            ),
          ),
        ],
      ); // create function here to adapt to the parent widget's constraints
    });
  }
}
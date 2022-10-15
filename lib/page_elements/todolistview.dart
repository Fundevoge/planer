import 'package:flutter/material.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/models/tasks.dart';
import 'package:planer/models/todolist.dart';
import 'package:planer/page_elements/taskwidgets.dart';
import 'dart:math';

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
late double? topHeight;
late double? bottomHeight;
late double? insertArrowHeight;
late int _currentTodoPoolIndex;
late bool showCheckedTodo;
late bool showCheckedPool;
late Color insertArrowColor;

enum InsertionPosition{
  list,
  pool
}

void initListPool() {
  topHeight = myPreferences.getDouble("MainViewTopHeight");
  bottomHeight = myPreferences.getDouble("MainViewBottomHeight");
  insertArrowHeight = myPreferences.getDouble("insertArrowHeight");

  _currentTodoPoolIndex = myPreferences.getInt("currentTodoPoolIndex") ?? 0;

  showCheckedTodo = myPreferences.getBool("showCheckedTodo") ?? false;
  showCheckedPool = myPreferences.getBool("showCheckedPool") ?? false;

  insertArrowColor = Color(myPreferences.getInt("insertArrowColor") ?? 0xFFFF0000);
}

const double insertArrowSize = 48;
const double insertArrowOffset = insertArrowSize / 2;
const double gestureDetectorHeight = 24;
const double tileExtent = 62;

class _ListPoolViewState extends State<ListPoolView> {
  late double maxHeight;
  final ScrollController _todoListScrollController = ScrollController();
  final ScrollController _poolScrollController = ScrollController();

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

  InsertionPosition getInsertionList(){
    return insertArrowHeight! + insertArrowOffset > topHeight! ? InsertionPosition.pool : InsertionPosition.list;
  }

  int getInsertionIndex(InsertionPosition insertionPosition){
    if(insertionPosition == InsertionPosition.list){
      double actualPosition = insertArrowHeight! + insertArrowOffset + _todoListScrollController.offset;
      return min(max(actualPosition / tileExtent, 0).round(), widget.todoList.tohs.length);
    }
    if(insertionPosition == InsertionPosition.pool){
      double actualPosition = insertArrowHeight! + insertArrowOffset - (topHeight! + gestureDetectorHeight) + _poolScrollController.offset;
      return min(max(actualPosition / tileExtent, 0).round(), todoPools[_currentTodoPoolIndex].tohs.length);
    }
    return 0;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
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
    _handleArrowPanUpdate(details);
  }

  void _handlePanEnd(DragEndDetails details) {
    myPreferences.setDouble("MainViewTopHeight", topHeight!);
    myPreferences.setDouble("MainViewBottomHeight", bottomHeight!);
  }

  void _handleArrowPanUpdate(DragUpdateDetails details) {
    double deltaY = details.delta.dy;
    if (insertArrowHeight! + deltaY < 0) {
      setState(() => insertArrowHeight = 0);
      return;
    }
    if (insertArrowHeight! + deltaY + insertArrowSize > maxHeight) {
      setState(() => insertArrowHeight = maxHeight - insertArrowSize);
      return;
    }
    setState(() => insertArrowHeight = insertArrowHeight! + deltaY);
  }

  void _handleArrowPanEnd(DragEndDetails details) {
    myPreferences.setDouble("insertArrowHeight", insertArrowHeight!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_context, constraints) {
      maxHeight = constraints.maxHeight;
      topHeight ??= (maxHeight - gestureDetectorHeight) / 2;
      bottomHeight ??= (maxHeight - gestureDetectorHeight) / 2;
      insertArrowHeight ??= 0;
      return Stack(
        children: [
          Column(
            children: [
              // Todolist
              Ink(
                color: const Color(0xFFFFFFFF),
                height: topHeight!,
                child: ListView(
                    itemExtent: tileExtent,
                    controller: _todoListScrollController,
                    children: <Widget>[] +
                        widget.todoList.tohs[widget.todoList.displayedDate]!
                            .where((element) => !element.isDone)
                            .map((e) =>
                              TileToH(
                                key: e.uid,
                                toh: e,
                                moveToDone: (_) => {},
                                enterSelectionMode: () => {},
                                showConstraints: (_) => {},
                                startTimer: (_) => {},
                                onTapCallback: (_) => {}))
                            .toList() +
                        [
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
                          )
                        ] +
                        (showCheckedTodo
                            ? widget.todoList.tohs[widget.todoList.displayedDate]!
                                .where((element) => element.isDone)
                                .map((e) => TileToH(
                                    key: e.uid,
                                    toh: e,
                                    moveToDone: (_) => {},
                                    enterSelectionMode: () => {},
                                    showConstraints: (_) => {},
                                    startTimer: (_) => {},
                                    onTapCallback: (_) => {}))
                                .toList()
                            : [])),
              ),
              // Spacer between
              GestureDetector(
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF303030),
                    ),
                    color: const Color(0xFFBABABA),
                  ),
                  height: gestureDetectorHeight,
                  child: const InkWell(
                    child: Center(
                      child: Icon(Icons.menu),
                    ),
                  ),
                ),
              ),
              // Pool
              Ink(
                color: const Color(0xFFFFFFFF),
                height: bottomHeight!,
                child: ListView(
                  itemExtent: tileExtent,
                  controller: _poolScrollController,
                  children: <Widget>[] +
                      todoPools[_currentTodoPoolIndex]
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
                          .toList() +
                      [
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
                      ] +
                      (showCheckedPool
                          ? todoPools[_currentTodoPoolIndex]
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
                              .toList()
                          : []),
                ),
              ),
            ],
          ),
          Positioned(
            right: 2,
            top: insertArrowHeight,
            child: GestureDetector(
              child: SizedBox(
                width: 30,
                child: Icon(
                  Icons.arrow_left_sharp,
                  color: insertArrowColor,
                  size: insertArrowSize,
                ),
              ),
              onPanUpdate: _handleArrowPanUpdate,
              onPanEnd: _handleArrowPanEnd,
            ),
          )
        ],
      ); // create function here to adapt to the parent widget's constraints
    });
  }
}

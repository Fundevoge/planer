import 'package:flutter/material.dart';
import 'package:planer/backend/debug.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/models/tasks.dart';
import 'package:planer/models/todolist.dart';
import 'package:planer/packages/flutter_colorpicker/lib/flutter_colorpicker.dart';
// import 'package:planer/packages/keep_keyboard_popup_menu/lib/keep_keyboard_popup_menu.dart';
import 'package:keep_keyboard_popup_menu/keep_keyboard_popup_menu.dart';
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
late double? insertArrowTopDistance;
late double? insertArrowBottomDistance;
late int _currentTodoPoolIndex;
late bool showCheckedTodo;
late bool showCheckedPool;
late Color insertArrowColor;
late List<Color> sharedColorHistory;

enum InsertionPosition { list, pool }

void initListPool() {
  topHeight = myPreferences.getDouble("MainViewTopHeight");
  bottomHeight = myPreferences.getDouble("MainViewBottomHeight");
  insertArrowTopDistance = myPreferences.getDouble("insertArrowTopDistance");
  insertArrowBottomDistance = myPreferences.getDouble("insertArrowBottomDistance");

  _currentTodoPoolIndex = myPreferences.getInt("currentTodoPoolIndex") ?? 0;

  showCheckedTodo = myPreferences.getBool("showCheckedTodo") ?? false;
  showCheckedPool = myPreferences.getBool("showCheckedPool") ?? false;

  insertArrowColor = Color(myPreferences.getInt("insertArrowColor") ?? 0xFFFF0000);
  sharedColorHistory =
      (myPreferences.getStringList("_sharedColorHistory") ?? <String>[]).map((e) => Color(int.parse(e))).toList();
}

const double insertArrowSize = 48;
const double insertArrowOffset = insertArrowSize / 2;
const double gestureDetectorHeight = 24;
const double tileExtent = 62;
const double taskCreateFontSize = 24;
const double taskCreateStrutHeight = 36;
const double taskCreateColorBoxPadding = 4.0;

class _ListPoolViewState extends State<ListPoolView> {
  late double _maxHeight;
  final ScrollController _todoListScrollController = ScrollController();
  final ScrollController _poolScrollController = ScrollController();
  final TextEditingController _taskCreationController = TextEditingController();
  bool _currentlyCreatingToH = false;
  late Color _firstNewTaskColor;
  List<Color>? _nextColors;
  int _taskCreationLineBreaks = 0;
  late Color _pickedColor;

  @override
  void initState() {
    _firstNewTaskColor = widget.todoList.listColor;
    _pickedColor = widget.todoList.listColor;
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

  void createTask() {}

  void _taskCreationUpdate(String s) {
    final int lineBreaks = "\n".allMatches(s).length;
    if (lineBreaks == _taskCreationLineBreaks) return;

    _taskCreationLineBreaks = lineBreaks;

    setState(() {
      if (lineBreaks == 0) {
        _nextColors = null;
      } else if (lineBreaks < _taskCreationLineBreaks) {
        _nextColors!.removeLast();
      } else {
        if (lineBreaks == 1) {
          _nextColors = [];
        }
        _nextColors!.add(_firstNewTaskColor);
      }
    });
  }

  InsertionPosition getInsertionList() {
    return insertArrowTopDistance! + insertArrowOffset > topHeight! ? InsertionPosition.pool : InsertionPosition.list;
  }

  int getInsertionIndex(InsertionPosition insertionPosition) {
    if (insertionPosition == InsertionPosition.list) {
      double actualPosition = insertArrowTopDistance! + insertArrowOffset + _todoListScrollController.offset;
      return min(max(actualPosition / tileExtent, 0).round(), widget.todoList.tohs.length);
    }
    if (insertionPosition == InsertionPosition.pool) {
      double actualPosition = insertArrowTopDistance! +
          insertArrowOffset -
          (topHeight! + gestureDetectorHeight) +
          _poolScrollController.offset;
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
    if (insertArrowTopDistance! + deltaY < 0) {
      deltaY = -insertArrowTopDistance!;
    } else if (insertArrowBottomDistance! - deltaY < 0) {
      deltaY = insertArrowBottomDistance!;
    }
    setState(() {
      insertArrowTopDistance = insertArrowTopDistance! + deltaY;
      insertArrowBottomDistance = insertArrowBottomDistance! - deltaY;
    });
  }

  void _handleArrowPanEnd(DragEndDetails details) {
    myPreferences.setDouble("insertArrowTopDistance", insertArrowTopDistance!);
    myPreferences.setDouble("insertArrowBottomDistance", insertArrowBottomDistance!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !_currentlyCreatingToH,
        child: FloatingActionButton(
            onPressed: () {
              setState(() => _currentlyCreatingToH = true);
              showModalBottomSheet<bool>(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                  context: context,
                  isScrollControlled: true,
                  builder: (_context) => Padding(
                        padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: ([_firstNewTaskColor] + (_nextColors ?? []))
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => KeepKeyboardPopupMenuButton(
                                      child: Ink(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: taskCreateColorBoxPadding,
                                          horizontal: 2.0,
                                        ),
                                        height: taskCreateStrutHeight - 2 * taskCreateColorBoxPadding,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            color: entry.value,
                                            border: Border.all(),
                                            borderRadius: const BorderRadius.all(Radius.circular(1.0))),
                                      ),
                                      // onCanceled: (){if(!sharedColorHistory.contains(_pickedColor)) sharedColorHistory.insert(0, _pickedColor);},
                                      menuItemBuilder: (BuildContext context, closeMenu) => [
                                        KeepKeyboardPopupMenuItem(
                                          child: Ink(width: 100, height: 100, color: Color(0xFFFF0000),) /*ColorPicker(
                                            pickerColor: _pickedColor,
                                            onColorChanged: (Color value) {
                                              setState(() {
                                                _pickedColor = value;
                                                if (entry.key == 0) {
                                                  _firstNewTaskColor = value;
                                                } else {
                                                  _nextColors![entry.key - 1] = value;
                                                }
                                              });
                                            },
                                            labelTypes: const [],
                                            enableAlpha: false,
                                            paletteType: PaletteType.hsl,
                                            colorPickerWidth: 300,
                                            uniqueHistoryColor: widget.todoList.listColor,
                                            sharedColorHistory: sharedColorHistory,
                                          ),*/
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _taskCreationController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: taskCreateFontSize,
                                ),
                                strutStyle: const StrutStyle(
                                  fontSize: taskCreateFontSize,
                                  height: taskCreateStrutHeight / taskCreateFontSize,
                                ),
                                onChanged: (val) => _taskCreationUpdate,
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Icon(Icons.upload),
                            ),
                          ],
                        ),
                      )).then((value) {
                setState(() {
                  _currentlyCreatingToH = false;
                });
                if (value != null) {
                  createTask();
                  _taskCreationController.text = "";
                  _nextColors = null;
                  _taskCreationLineBreaks = 0;
                }
              });
            },
            child: const Icon(
              Icons.add,
            ),
            backgroundColor: widget.todoList.listColor),
      ),
      body: LayoutBuilder(builder: (_context, constraints) {
        _maxHeight = constraints.maxHeight;
        topHeight ??= (_maxHeight - gestureDetectorHeight) / 2;
        bottomHeight ??= (_maxHeight - gestureDetectorHeight) / 2;
        int topFlex = (topHeight! / _maxHeight * 1000000).toInt();
        int bottomFlex = (bottomHeight! / _maxHeight * 1000000).toInt();
        insertArrowTopDistance ??= 0;
        insertArrowBottomDistance ??= _maxHeight - insertArrowSize;
        int topArrowFlex = (insertArrowTopDistance! / _maxHeight * 1000000).toInt();
        int bottomArrowFlex = (insertArrowBottomDistance! / _maxHeight * 1000000).toInt();
        return Stack(
          children: [
            Column(
              children: [
                // Todolist
                Expanded(
                  flex: topFlex,
                  child: Ink(
                    color: const Color(0xFFFFFFFF),
                    height: topHeight!,
                    child: ListView(
                        itemExtent: tileExtent,
                        controller: _todoListScrollController,
                        children: <Widget>[] +
                            widget.todoList.tohs[widget.todoList.displayedDate]!
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
                ),
                // Spacer between
                GestureDetector(
                  onVerticalDragUpdate: _handlePanUpdate,
                  onVerticalDragEnd: _handlePanEnd,
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
                Expanded(
                  flex: bottomFlex,
                  child: Ink(
                    color: const Color(0xFFFFFFFF),
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
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: topArrowFlex,
                  child: SizedBox(
                    height: insertArrowTopDistance!,
                    width: 1,
                  ),
                ),
                DebugContainer(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 2.0),
                    child: GestureDetector(
                      child: SizedBox(
                        width: 30,
                        child: Icon(
                          Icons.arrow_left_sharp,
                          color: insertArrowColor,
                          size: insertArrowSize,
                        ),
                      ),
                      onVerticalDragUpdate: _handleArrowPanUpdate,
                      onVerticalDragEnd: _handleArrowPanEnd,
                    ),
                  ),
                ),
                Expanded(
                  flex: bottomArrowFlex,
                  child: SizedBox(
                    height: insertArrowBottomDistance,
                    width: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

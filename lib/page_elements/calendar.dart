import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planer/backend/state_manager.dart';
import 'package:planer/models/date.dart';
import 'package:planer/models/tasks.dart';
import 'package:planer/models/todolist.dart';
import 'package:planer/page_elements/taskwidgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../backend/preference_manager.dart';

final kToday = DateTime.now();
final kFirstDay = DateTime(myPreferences.getInt("firstOpenedYear")! - 20);
final kLastDay = DateTime(kToday.year + 100).subtract(const Duration(days: 1));
const CalendarStyle calendarStyle = CalendarStyle(
  selectedDecoration: BoxDecoration(
    color: Color(0xFF7A8DD9),
    shape: BoxShape.circle,
  ),
  todayDecoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Color(0xFFC4BAEE),
  ),
);

class TaskCalendar extends StatefulWidget {
  const TaskCalendar({Key? key}) : super(key: key);

  @override
  State<TaskCalendar> createState() => _TaskCalendarState();
}

class _TaskCalendarState extends State<TaskCalendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  final ChangeNotifier triggerRebuild = ChangeNotifier();
  late final PageController _pageController;

  List<ToH> _getToHsForDay(DateTime day) {
    Date currentDate = Date.fromDateTime(day);
    List<ToH> dayToHs = <ToH>[];
    for (TodoList todoList in todoLists) {
      if (todoList.showInCalendar) {
        dayToHs.addAll(todoList.tohs[currentDate] ?? []);
      }
    }
    return dayToHs;
  }

  Widget _buildSingleMarker(DateTime day, ToH event, double markerSize) {
    return Container(
      width: markerSize,
      height: markerSize,
      margin: const EdgeInsets.fromLTRB(0.3, 0, 0.3, 3.5),
      decoration: BoxDecoration(
        color: listColors[event.listName]!,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget? _markerBuilder(BuildContext context, DateTime day, List<ToH> events) {
    if (_getToHsForDay(day).isEmpty) return null;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(4).map((event) => _buildSingleMarker(day, event, 7.8)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Rebuilder>(builder: (BuildContext context, rebuilder, Widget? consumerChild) {
      List<ToH> dayToHs = _getToHsForDay(_selectedDay);
      return Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 4.0, 8.0),
            child: Row(
              children: [
                // Current Month/Year + Change Year
                TextButton(
                  child: Text(
                    DateFormat.yMMMM('de_DE').format(_focusedMonth),
                    style: const TextStyle(fontSize: 24.0, color: Color(0xFF333355)),
                    textAlign: TextAlign.start,
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Jahr ändern'),
                      content: SizedBox(
                        width: 300,
                        height: 400,
                        child: YearPicker(
                          firstDate: DateTime(myPreferences.getInt("firstOpenedYear")! - 20),
                          lastDate: DateTime.now().add(const Duration(days: 36500)),
                          selectedDate: _focusedMonth,
                          onChanged: (date) {
                            setState(() {
                              _focusedMonth = DateTime(date.year, _focusedMonth.month);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Popup to select shown lists
                PopupMenuButton(
                  offset: const Offset(100, 15),
                  elevation: 5.0,
                  position: PopupMenuPosition.under,
                  child: Row(
                    children: const <Widget>[Text("Listen"), Icon(Icons.arrow_drop_down_sharp)],
                  ),
                  itemBuilder: (_context) => [
                    for (TodoList todoList in todoLists)
                      PopupMenuItem(
                        child: StatefulBuilder(builder: (__context, _setState) {
                          return ListTile(
                            title: Text(todoList.listName),
                            trailing: Theme(
                              data: Theme.of(__context).copyWith(unselectedWidgetColor: todoList.listColor),
                              child: Checkbox(
                                activeColor: todoList.listColor,
                                  value: todoList.showInCalendar,
                                  onChanged: (bool? value) {
                                    _setState(() {
                                      todoList.showInCalendar = value!;
                                      rebuilder.rebuild();
                                    });
                                  }),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
                // Previous Month
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      setState(() {
                        _focusedMonth = _focusedMonth.month == 1
                            ? DateTime(_focusedMonth.year - 1, 12)
                            : DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                      });
                    }),
                // Next Month
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    setState(() {
                      _focusedMonth = _focusedMonth.month == 12
                          ? DateTime(_focusedMonth.year + 1, 1)
                          : DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          // Calendar
          TableCalendar<ToH>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedMonth,
            locale: 'de_DE',
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            eventLoader: _getToHsForDay,
            calendarStyle: calendarStyle,
            calendarBuilders: CalendarBuilders(markerBuilder: _markerBuilder),
            holidayPredicate: (day) {
              // Every 20th day of the month will be treated as a holiday
              return day.day == 20;
            },
            weekendDays: const [],
            selectedDayPredicate: (day) {
              return Date.fromDateTime(_selectedDay) == Date.fromDateTime(day);
            },
            onCalendarCreated: (controller) => _pageController = controller,
            onPageChanged: (newFocusedMonth) => _focusedMonth = newFocusedMonth,
            onDaySelected: (newSelectedDay, newFocusedMonth) {
              if (!isSameDay(_selectedDay, newSelectedDay)) {
                setState(() {
                  _selectedDay = newSelectedDay;
                  _focusedMonth = newFocusedMonth;
                });
              }
            },
          ),
          const SizedBox(height: 8.0),
          // Shown Tasks
          Expanded(
            child: ListView.builder(
              itemCount: dayToHs.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TileToH(
                    toh: dayToHs[index],
                    moveToDone: (int i) {},
                    enterSelectionMode: () {},
                    showConstraints: (List<TDConstraint>? c) {},
                    startTimer: (Duration d) {},
                    onTapCallback: (ToH toh) {},
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

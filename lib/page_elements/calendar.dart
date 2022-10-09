import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planer/backend/persistance_manager.dart';
import 'package:planer/backend/tasks.dart';
import 'package:table_calendar/table_calendar.dart';

import '../backend/preference_manager.dart';


final kToday = DateTime.now();
final kFirstDay = DateTime((myPreferences.getInt("firstOpenedYear") ?? kToday.year)-1);
final kLastDay = DateTime(kToday.year+100).subtract(const Duration(days: 1));

class TaskCalendar extends StatefulWidget {
  const TaskCalendar({Key? key}) : super(key: key);

  @override
  State<TaskCalendar> createState() => _TaskCalendarState();
}

class _TaskCalendarState extends State<TaskCalendar> {
  DateTime _selectedDay = DateTime.now();
  late final PageController _pageController;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());

  List<ToH> _getToHsForDay(DateTime day) {
    Date currentDate = Date.fromDateTime(day);
    List<ToH> dayToHs = <ToH>[];
    for (LinkedHashMap<Date, List<ToH>> map in todoLists.values) {
      dayToHs.addAll(map[currentDate] ?? []);
    }
    return dayToHs;
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, _) {
            return _CalendarHeader(
              focusedDay: value,
              onTodayButtonTap: () {
                setState(() => _focusedDay.value = DateTime.now());
              },
              onLeftArrowTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              onRightArrowTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            );
          },
        ),
        TableCalendar<ToH>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay.value,
          locale: 'de_DE',
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerVisible: false,
          daysOfWeekStyle: DaysOfWeekStyle(),
          eventLoader: _getToHsForDay,
          holidayPredicate: (day) {
            // Every 20th day of the month will be treated as a holiday
            return day.day == 20;
          },
          selectedDayPredicate: (day) {
            return Date.fromDateTime(_selectedDay) == Date.fromDateTime(day);
          },
          onCalendarCreated: (controller) => _pageController = controller,
          onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay.value = focusedDay;
                });
              }
            },

        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              List<ToH> dayToHs = _getToHsForDay(value);
              return ListView.builder(

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
                    child: ListTile(
                      onTap: () => print('${dayToHs[index]}'),
                      title: Text('${dayToHs[index]}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: const TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}

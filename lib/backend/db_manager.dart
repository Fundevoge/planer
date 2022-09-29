import 'dart:collection';
import 'package:planer/backend/tasks.dart';
import 'package:table_calendar/table_calendar.dart';

final Map<String, LinkedHashMap<DateTime, List<ToH>>> todoLists = {};

void initTodoLists() {
  todoLists['own'] = LinkedHashMap<DateTime, List<ToH>>(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll({
    DateTime.now(): [ToH.debugFactory(0), ToH.debugFactory(1)]
  });
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
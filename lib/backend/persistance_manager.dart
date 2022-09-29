import 'dart:collection';
import 'dart:convert';
import 'package:planer/backend/tasks.dart';
import 'package:table_calendar/table_calendar.dart';

void createTaskJson() {
  //db.execute("CREATE TABLE todoListNames(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, UNIQUE(name)");
  //db.execute("CREATE TABLE tohs(uid INTEGER PRIMARY KEY, name TEXT, notes TEXT, timeLimit INT, ");
}

final Map<String, LinkedHashMap<DateTime, List<ToH>>> todoLists = {};
void initTodoListsDebug() {
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

String encodeTodoLists() {
  return jsonEncode({
    for (String key in todoLists.keys)
      key: {
        for (DateTime d in todoLists[key]!.keys)
          d.toIso8601String(): [
            for (ToH toh in todoLists[key]![d]!)
              toh.toJson()]
    }
  });
}

void initTodoLists(String encoded) {
  Map<String, dynamic> decoded = jsonDecode(encoded);
  todoLists.addAll({
    for (String key in decoded.keys)
      key: LinkedHashMap.from({
        for (String date in decoded[key]!.keys)
          DateTime.parse(date): [
            for (Map<String, dynamic> jsonToH in decoded[key]![date]!)
              ToH.fromJson(jsonToH)]
      })
  });
}


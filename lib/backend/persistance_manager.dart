import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:planer/backend/tasks.dart';
import 'package:table_calendar/table_calendar.dart';

void createTaskJson() {
  //db.execute("CREATE TABLE todoListNames(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, UNIQUE(name)");
  //db.execute("CREATE TABLE tohs(uid INTEGER PRIMARY KEY, name TEXT, notes TEXT, timeLimit INT, ");
}
final Map<String, LinkedHashMap<DateTime, List<ToH>>> todoLists = {};
final Map<String, LinkedHashMap<DateTime, List<ToH>>> todoPools = {};
final List<StructureToH> structureToHs = [];
final List<PeriodicToH> periodicToHs = [];
final List<ToH> templateToHs = [];

late final File taskListsFile;
late final File taskPoolsFile;
late final File structureToHFile;
late final File periodicToHFile;
late final File templateToHFile;


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

void initTodoPoolsDebug() {
  todoPools['own'] = LinkedHashMap<DateTime, List<ToH>>(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll({
    DateTime.now(): [ToH.debugFactory(0), ToH.debugFactory(1)]
  });
}

String encodeTodoPools() {
  return jsonEncode({
    for (String key in todoPools.keys)
      key: {
        for (DateTime d in todoPools[key]!.keys)
          d.toIso8601String(): [
            for (ToH toh in todoPools[key]![d]!)
              toh.toJson()]
      }
  });
}

void initTodoPools(String encoded) {
  Map<String, dynamic> decoded = jsonDecode(encoded);
  todoPools.addAll({
    for (String key in decoded.keys)
      key: LinkedHashMap.from({
        for (String date in decoded[key]!.keys)
          DateTime.parse(date): [
            for (Map<String, dynamic> jsonToH in decoded[key]![date]!)
              ToH.fromJson(jsonToH)]
      })
  });
}

void initOtherToHs(String encodedS, String encodedP, String encodedT){
  structureToHs.addAll([for(Map<String, dynamic> jsonS in jsonDecode(encodedS)) StructureToH.fromJson(jsonS)]);
  periodicToHs.addAll([for(Map<String, dynamic> jsonP in jsonDecode(encodedP)) PeriodicToH.fromJson(jsonP)]);
  templateToHs.addAll([for(Map<String, dynamic> jsonT in jsonDecode(encodedT)) ToH.fromJson(jsonT)]);
}

void saveTodoLists() async{
  await taskListsFile.writeAsString(jsonEncode(encodeTodoLists()));
}

void saveTodoPools()async{
  await taskPoolsFile.writeAsString(jsonEncode(encodeTodoLists()));
}

void saveOtherToHs()async{
  await structureToHFile.writeAsString(jsonEncode([for(StructureToH s in structureToHs) s.toJson()]));
  await periodicToHFile.writeAsString(jsonEncode([for(PeriodicToH p in periodicToHs) p.toJson()]));
  await templateToHFile.writeAsString(jsonEncode([for(ToH t in templateToHs) t.toJson()]));
}
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:planer/models/tasks.dart';
import 'package:planer/models/todolist.dart';

class Date {
  final int year;
  final int month;
  final int day;
  @override
  final int hashCode;

  Date(this.day, this.month, this.year) : hashCode = day * 1000000 + month * 10000 + year;

  Date.fromDateTime(DateTime dateTime)
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day,
        hashCode = dateTime.day * 1000000 + dateTime.month * 10000 + dateTime.year;

  factory Date.now() {
    return Date.fromDateTime(DateTime.now());
  }

  @override
  String toString() {
    return "$day.$month.$year";
  }

  factory Date.fromString(String s) {
    List<String> subStrings = s.split(".");
    return Date(int.parse(subStrings[0]), int.parse(subStrings[1]), int.parse(subStrings[2]));
  }

  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  @override
  bool operator ==(Object other) {
    return other is Date && hashCode == other.hashCode;
  }
}

Future<void> createJsons() async {
  todoLists.add(TodoList(tohs: LinkedHashMap.from({Date.now(): <ToH>[]}), listColor: const Color(0xFFAABBCC),
    listIcon: const Icon(Icons.person), listName: "Meine Liste",));
  todoPools.add(TodoPool(tohs: <ToH>[], poolColor: const Color(0xFFAABBCC), poolIcon: const Icon(Icons.person),
      poolName: "Todos"));

  initTodoListsDebug();
  initTodoPoolsDebug();

  await saveTodoLists();
  await saveTodoPools();
  await saveOtherToHs();
}

final List<TodoList> todoLists = <TodoList>[];
final List<TodoPool> todoPools = <TodoPool>[];
final List<StructureToH> structureToHs = <StructureToH>[];
final List<PeriodicToH> periodicToHs = <PeriodicToH>[];
final List<ToH> templateToHs = <ToH>[];

late final File taskListsFile;
late final File taskPoolsFile;
late final File structureToHFile;
late final File periodicToHFile;
late final File templateToHFile;

void initTodoListsDebug() {
  todoLists.add(TodoList(
      tohs: LinkedHashMap.from({
        Date.now(): [ToH.debugFactory(0), ToH.debugFactory(1)]
      }),
      listColor: const Color(0xFFAABBCC),
      listIcon: const Icon(Icons.person),
      listName: "Meine Liste"));
}

String encodeTodoLists() {
  return jsonEncode([for (TodoList todoList in todoLists) todoList.toJson()]);
}

void initTodoLists(String encoded) {
  todoLists.addAll([for (Map<String, dynamic> jsonTodoList in jsonDecode(encoded)) TodoList.fromJson(jsonTodoList)]);
}

void initTodoPoolsDebug() {
  todoPools.add(TodoPool(tohs: [ToH.debugFactory(0), ToH.debugFactory(1)], poolColor: const Color(0xFFAABBCC),
      poolIcon: const Icon(Icons.person),
      poolName: "Todos"));
}

String encodeTodoPools() {
  return jsonEncode([for (TodoPool todoPool in todoPools) todoPool.toJson()]);
}

void initTodoPools(String encoded) {
  todoPools.addAll([for (Map<String, dynamic> jsonTodoPool in jsonDecode(encoded)) TodoPool.fromJson(jsonTodoPool)]);
}

void initOtherToHs(String encodedS, String encodedP, String encodedT) {
  structureToHs.addAll([for (Map<String, dynamic> jsonS in jsonDecode(encodedS)) StructureToH.fromJson(jsonS)]);
  periodicToHs.addAll([for (Map<String, dynamic> jsonP in jsonDecode(encodedP)) PeriodicToH.fromJson(jsonP)]);
  templateToHs.addAll([for (Map<String, dynamic> jsonT in jsonDecode(encodedT)) ToH.fromJson(jsonT)]);
}

Future<void> saveTodoLists() async {
  await taskListsFile.writeAsString(encodeTodoLists());
}

Future<void> saveTodoPools() async {
  await taskPoolsFile.writeAsString(encodeTodoPools());
}

Future<void> saveOtherToHs() async {
  await structureToHFile.writeAsString(jsonEncode([for (StructureToH s in structureToHs) s.toJson()]));
  await periodicToHFile.writeAsString(jsonEncode([for (PeriodicToH p in periodicToHs) p.toJson()]));
  await templateToHFile.writeAsString(jsonEncode([for (ToH t in templateToHs) t.toJson()]));
}

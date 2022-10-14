import 'dart:collection';

import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:planer/backend/helper.dart';
import 'package:planer/models/date.dart';
import 'package:planer/models/tasks.dart';
import 'package:flutter/material.dart';

final List<TodoList> todoLists = <TodoList>[];
final List<TodoPool> todoPools = <TodoPool>[];
final List<StructureToH> structureToHs = <StructureToH>[];
final List<PeriodicToH> periodicToHs = <PeriodicToH>[];
final List<ToH> templateToHs = <ToH>[];

final Map<String, Color> listColors = {};
void initListColors() {
  for (TodoList todoList in todoLists) {
    listColors[todoList.listName] = todoList.listColor;
  }
}

class TodoList {
  final Key uid;
  final LinkedHashMap<Date, List<ToH>> tohs;
  Color listColor;
  Icon listIcon;
  String listName;
  bool showInCalendar;

  TodoList({required this.tohs, required this.listColor, required this.listIcon, required this.listName, this.showInCalendar = true})
      : uid = generateUid();

  Map<String, dynamic> toJson() {
    final Map<String, List<Map<String, dynamic>>> jsonToHs = {
      for (Date date in tohs.keys) date.toString(): [for (ToH toh in tohs[date]!) toh.toJson()]
    };
    return {
      "uid": uid.toString(),
      "tohs": jsonToHs,
      "listColor": listColor.value,
      "listName": listName,
      "listIcon": serializeIcon(listIcon.icon!),
      "showInCalendar": showInCalendar
    };
  }

  TodoList.fromJson(Map<String, dynamic> json)
      : uid = Key(json['uid']),
        listName = json["listName"],
        listColor = Color(json["listColor"]),
        listIcon = Icon(deserializeIcon(json["listIcon"])),
        showInCalendar = json["showInCalendar"],
        tohs = LinkedHashMap.from({
          for (String date in json["tohs"].keys)
            Date.fromString(date): [for (Map<String, dynamic> jsonToH in json["tohs"][date]) ToH.fromJson(jsonToH)]
        });
}

class TodoPool {
  final Key uid;
  final List<ToH> tohs;
  Color poolColor;
  Icon poolIcon;
  String poolName;

  TodoPool({required this.tohs, required this.poolColor, required this.poolIcon, required this.poolName})
      : uid = generateUid();

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> jsonToHs = List.from([for (ToH child in tohs) child.toJson()]);
    return {
      "uid": uid.toString(),
      "tohs": jsonToHs,
      "poolColor": poolColor.value,
      "poolName": poolName,
      "poolIcon": serializeIcon(poolIcon.icon!),
    };
  }

  TodoPool.fromJson(Map<String, dynamic> json)
      : uid = Key(json['uid']),
        poolName = json["poolName"],
        poolColor = Color(json["poolColor"]),
        poolIcon = Icon(deserializeIcon(json["poolIcon"])),
        tohs = [for (Map<String, dynamic> serializedToH in json["tohs"]) ToH.fromJson(serializedToH)];
}

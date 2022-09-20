/*
TaskTypes:
  template
  unique
  structure
  periodic
*/

import 'package:flutter/material.dart';

enum StructureTaskActive { always, workdays, holidays }

class Periodicity {}

class TemplateToH {
  String name;
  String notes;
  Duration timeLimit;
  List<TemplateToH>? children;
  TemplateToH(this.name, this.notes, this.timeLimit, this.children);
}

class DoableToH extends TemplateToH {
  String listName;
  int index;
  bool isDone;

  DoableToH(name, notes, timeLimit, children, this.listName, this.index, this.isDone)
      : super(name, notes, timeLimit, children);
}

class UniqueToH extends DoableToH {
  DateTime dateTime;

  UniqueToH(name, notes, timeLimit, children, listName, index, isDone, this.dateTime)
      : super(name, notes, timeLimit, children, listName, index, isDone);
}

class StructureToH extends DoableToH {
  StructureTaskActive whenActive;

  StructureToH(name, notes, timeLimit, children, listName, index, isDone, this.whenActive)
      : super(name, notes, timeLimit, children, listName, index, isDone);
}

class PeriodicToH extends DoableToH {
  Periodicity periodicity;

  PeriodicToH(name, notes, timeLimit, children, listName, index, isDone, this.periodicity)
      : super(name, notes, timeLimit, children, listName, index, isDone);
}


void addTask() {}
void markTaskDone() {}
void markHeaderDone() {}
List<dynamic> getTasks(DateTime day) {
  return <dynamic>[];
}

List<dynamic> getAllTasks() {
  return <dynamic>[];
}

ListView buildTasksHeaders(bool Function(dynamic) whereF) {
  return ListView();
}

bool onList(dynamic tasks, String listName) {
  return true;
}

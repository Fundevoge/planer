/*
TaskTypes:
  template
  unique
  structure
  periodic
*/

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:planer/backend/preference_manager.dart';
import 'package:planer/backend/tasks.dart';

enum StructureTaskActive { always, workdays, holidays }

// 0 For Structure, 1 for repeating, 2 otherwise default
final List<Color> colorsForTypes = [];
void initColors() {
  colorsForTypes.add(Color(myPreferences.getInt('structureTaskColor') ?? 0));
  colorsForTypes.add(Color(myPreferences.getInt('repeatingTaskColor') ?? 0));
  colorsForTypes.add(Color(myPreferences.getInt('defaultTaskColor') ?? 0));
}

class Periodicity {
  List<Duration> baseOffsets;
  List<Duration> rhythms;
  DateTime baseDate;
  Periodicity(this.baseDate, this.rhythms, this.baseOffsets);
}

enum TDConstraint { external, internal }

// Any Task or Header:
//  Name, Notes, timerduration?, subtasks?, listname, Date?, index, is_done, icon, color, isHighlighted, deadline?,
//  is_repeating, constraints?
class ToH {
  String name;
  String notes;
  Duration? timeLimit;
  List<ToH>? children;
  String listName;
  DateTime? listDate;
  int index;
  bool isDone;
  Icon icon;
  int colorIndex;
  bool isHighlighted;
  DateTime? deadline;
  bool isRepeating;
  List<TDConstraint>? constraints;

  ToH(
      {required this.name,
      required this.notes,
      this.timeLimit,
      this.children,
      required this.listName,
      this.listDate,
      required this.index,
      required this.isDone,
      required this.icon,
      required this.colorIndex,
      required this.isHighlighted,
      this.deadline,
      required this.isRepeating,
      this.constraints});
}
// Structure (Not for task list, only backend and structure maniplator):
//  Whenactive
class StructureToH extends ToH {
  StructureTaskActive whenActive;

  StructureToH(
      {required super.name,
      required super.notes,
      super.timeLimit,
      super.children,
      required super.listName,
      super.listDate,
      required super.index,
      required super.isDone,
      required super.icon,
      required super.colorIndex,
      required super.isHighlighted,
      super.deadline,
      required super.isRepeating,
      super.constraints,
      required this.whenActive});
}
// Repeating (Not for task list, only backend and periodicity maniplator):
//  Periodicity(Rhythm, Base_Date)
class PeriodicToH extends ToH {
  Periodicity periodicity;

  PeriodicToH(
      {required super.name,
        required super.notes,
        super.timeLimit,
        super.children,
        required super.listName,
        super.listDate,
        required super.index,
        required super.isDone,
        required super.icon,
        required super.colorIndex,
        required super.isHighlighted,
        super.deadline,
        required super.isRepeating,
        super.constraints,
        required this.periodicity});
}

void addTask() {}
void markTaskDone() {}
List<ToH> getTasks(DateTime day) {
  return <ToH>[];
}

List<dynamic> getAllTasks() {
  return <ToH>[];
}

ListView renderToH(bool Function(ToH) whereF) {
  return ListView();
}

bool onList(List<ToH> tasks, String listName) {
  return true;
}

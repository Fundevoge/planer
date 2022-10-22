import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:planer/backend/preference_manager.dart';
import '../backend/helper.dart';

enum ToHActive { always, workdays, holidays }

// 0 For Structure, 1 for repeating, 2 otherwise default
late Color structureTaskColor;
late Color repeatingTaskColor;
late Color defaultTaskColor;
void initTaskColors() {
  structureTaskColor = Color(myPreferences.getInt('structureTaskColor') ?? 0xFFFFFFFF);
  repeatingTaskColor = Color(myPreferences.getInt('repeatingTaskColor') ?? 0xFFFFFFFF);
  defaultTaskColor = Color(myPreferences.getInt('defaultTaskColor') ?? 0xFFFFFFFF);
}

enum PeriodicTypes {
  weekRhythm,
  other
}

class Periodicity {
  List<Duration> baseOffsets;
  List<Duration> rhythms;
  DateTime baseDate;
  DateTime endDate;
  Periodicity(this.baseDate, this.rhythms, this.baseOffsets, this.endDate);
  Map<String, dynamic> toJson() {
    return {
      "baseDate": baseDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "rhythms": [for (Duration r in rhythms) r.inSeconds],
      "baseOffsets": [for (Duration b in baseOffsets) b.inSeconds]
    };
  }

  Periodicity.fromJson(Map<String, dynamic> json)
      : baseDate = DateTime.parse(json["baseDate"]),
        endDate = DateTime.parse(json["endDate"]),
        rhythms = [for (String s in json["rhythms"]) Duration(seconds: int.parse(s))],
        baseOffsets = [for (String s in json["baseOffsets"]) Duration(seconds: int.parse(s))];
}

final RegExp isRepeatingRe1 = RegExp(" R\$");
final RegExp isRepeatingRe2 = RegExp(" R ");
final RegExp isMultiLineRe = RegExp("\n");

// Any Task or Header:
//  Name, Notes, timerduration?, subtasks?, listname, Date?, index, is_done, icon, color, isHighlighted, deadline?,
//  is_repeating, constraints?
class ToH {
  final Key uid;
  String name;
  String notes;
  Duration? timeLimit;
  ToH? parent;
  List<ToH>? children;
  String listName;
  DateTime insertionTime;
  int index;
  bool isDone;
  Icon? icon;
  Color taskColor;
  bool isHighlighted;
  bool isSelected;
  DateTime? deadline;
  bool isRepeating;
  List<ToH>? requiredToHs;
  int recursionDepth;
  int constraintDepth;
  // Parent and constraintDepth are only required for construction of the list
  ToH(
      {required this.name,
      this.notes = "",
      this.timeLimit,
      this.children,
      required this.listName,
      required this.insertionTime,
      required this.index,
      this.isDone = false,
      this.icon,
      required this.taskColor,
      this.isHighlighted = false,
      this.isSelected = false,
      this.deadline,
      this.isRepeating = false,
      this.requiredToHs,
      this.recursionDepth = 0, this.constraintDepth = 0})
      : uid = generateUid();

  factory ToH.debugFactory(int index) {
    return ToH(
      name: "New Debug Task $index",
      notes: "Debug Notes",
      listName: "Meine Liste",
      insertionTime: DateTime.now(),
      index: index,
      icon: const Icon(Icons.developer_mode),
      taskColor: Color(randomColorCode()),
    );
  }

  factory ToH.blankToH(String name)  =>
      ToH(name: name, listName: '', index: 0, taskColor: const Color(0x00000000), insertionTime: DateTime(0));

  bool deadlineOverdue() {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>>? jsonChildren =
        (children?.isNotEmpty ?? false) ? List.from([for (ToH child in children!) child.toJson()]) : null;
    final List<Map<String, dynamic>>? jsonRequiredToHs = (requiredToHs?.isNotEmpty ?? false)
        ? List.from([for (ToH child in requiredToHs!) child.toJson()])
        : null;
    return {
      "uid": uid.toString(),
      "name": name,
      "notes": notes,
      "timeLimit": timeLimit?.inSeconds,
      "children": jsonChildren,
      "listName": listName,
      "insertionTime": insertionTime.toIso8601String(),
      "index": index,
      "isDone": isDone,
      "icon": icon == null ? null : serializeIcon(icon!.icon!),
      "taskColor": taskColor.value,
      "isHighlighted": isHighlighted,
      "isSelected": isSelected,
      "deadline": deadline?.toIso8601String(),
      "isRepeating": isRepeating,
      "requiredToHs": jsonRequiredToHs,
      "recursionDepth": recursionDepth,
    };
  }

  ToH.fromJson(Map<String, dynamic> json)
      : uid = Key(json['uid']),
        name = json["name"],
        notes = json["notes"],
        timeLimit = json["timeLimit"],
        children = json["children"] != null
            ? [for (Map<String, dynamic> jsonChild in json["children"]) ToH.fromJson(jsonChild)]
            : null,
        listName = json["listName"],
        insertionTime = DateTime.parse(json["insertionTime"]),
        index = json["index"],
        isDone = json["isDone"],
        icon = json["icon"] == null ? null : Icon(deserializeIcon(json["icon"])!),
        taskColor = Color(json["taskColor"]),
        isHighlighted = json["isHighlighted"],
        isSelected = json["isSelected"],
        deadline = json["deadline"] != null ? DateTime.parse(json["deadline"]) : null,
        recursionDepth = json["recursionDepth"],
        isRepeating = json["isRepeating"],
        constraintDepth = 0,
        requiredToHs = json["requiredToHs"] != null
            ? [for (Map<String, dynamic> jsonChild in json["requiredToHs"]) ToH.fromJson(jsonChild)]
            : null;
}

// Structure (Not for task list, only backend and structure maniplator):
//  Whenactive
class StructureToH {
  ToHActive whenActive;
  final ToH toh;

  StructureToH({required this.toh, required this.whenActive});
  Map<String, dynamic> toJson() {
    return {"whenActive": whenActive.index, "toh": toh.toJson()};
  }

  StructureToH.fromJson(Map<String, dynamic> json)
      : whenActive = ToHActive.values.elementAt(json["whenActive"]),
        toh = ToH.fromJson(json["toh"]);
}

// Repeating (Not for task list, only backend and periodicity maniplator):
//  Periodicity(Rhythm, Base_Date)
class PeriodicToH {
  Periodicity periodicity;
  ToHActive whenActive;
  final ToH toh;

  PeriodicToH({required this.toh, required this.periodicity, required this.whenActive});
  Map<String, dynamic> toJson() {
    return {"periodicity": periodicity.toJson(), "toh": toh.toJson(), "whenActive": whenActive.index};
  }

  PeriodicToH.fromJson(Map<String, dynamic> json)
      : periodicity = Periodicity.fromJson(json["periodicity"]),
        toh = ToH.fromJson(json["toh"]),
        whenActive = ToHActive.values.elementAt(json["whenActive"]);
}

void addTask() {}
void markTaskDone() {}

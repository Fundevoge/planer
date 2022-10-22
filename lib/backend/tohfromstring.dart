import 'dart:math';
import 'package:flutter/material.dart';

import 'package:planer/models/date.dart';
import 'package:planer/models/tasks.dart';

final RegExp dateRe = RegExp(r"^\d{1,2}[.]\d{1,2}([.](\d\d){0,2})?$");
final RegExp timeRe = RegExp(r"\d{1,2}:\d{2}( Uhr)?");
final RegExp timestampRe = RegExp(r" um \d{1,2}:\d{2}( Uhr)?");
final RegExp deadlineRe_1 = RegExp(r" bis \d{1,2}[.]\d{1,2}([.](\d\d){0,2})? \d{1,2}:\d{2}( Uhr)?");
final RegExp deadlineRe_2 = RegExp(r" bis \d{1,2}:\d{2}( Uhr)?");
final RegExp deadlineRe_3 = RegExp(r" bis \d{1,2}[.]\d{1,2}([.](\d\d){0,2})?");
final RegExp externalRe = RegExp(r" \[.*]");
final Map<String, Icon> iconKeywords = {"anrufen": const Icon(Icons.call)};
final RegExp hasDurationRe = RegExp(r" [tT] ");
final RegExp durationReH = RegExp(r"(\d{1,3}h)");
final RegExp durationReM = RegExp(r"(\d{1,3}m)");
final RegExp durationReS = RegExp(r"(\d{1,3}s)");
final RegExp constraintRe = RegExp(r"D+ ");

Map<String, String> extractDuration(String s) {
  RegExpMatch? hourMatch = durationReH.firstMatch(s);
  RegExpMatch? minuteMatch = durationReM.firstMatch(s);
  RegExpMatch? secondMatch = durationReS.firstMatch(s);
  Map<String, String> retMap = {};
  String timeStr;
  if (hourMatch != null && hourMatch.groupCount > 0) {
    timeStr = hourMatch.group(0)!;
    timeStr = timeStr.substring(0, timeStr.length - 1);
    retMap["h"] = timeStr;
  }
  if (minuteMatch != null && minuteMatch.groupCount > 0) {
    timeStr = minuteMatch.group(0)!;
    timeStr = timeStr.substring(0, timeStr.length - 1);
    retMap["m"] = timeStr;
  }
  if (secondMatch != null && secondMatch.groupCount > 0) {
    timeStr = secondMatch.group(0)!;
    timeStr = timeStr.substring(0, timeStr.length - 1);
    retMap["s"] = timeStr;
  }
  return retMap;
}

Duration durationFromMap(Map<String, String> duration) {
  return Duration(
    hours: int.parse(duration["h"] ?? "0"),
    minutes: int.parse(duration["m"] ?? "0"),
    seconds: int.parse(duration["s"] ?? "0"),
  );
}

String stringFromDuration(Map<String, String> duration) {
  return [for (MapEntry<String, String> e in duration.entries) e.value + e.key].join("");
}

Date extractDate(String s) {
  RegExpMatch? dateCandidate = dateRe.firstMatch(s);
  if (dateCandidate == null) return Date.now();

  List<String> components = dateCandidate.group(0)!.split(".");
  int month = max(1, min(12, int.parse(components[1])));
  int day = max(1, min(31, int.parse(components[0])));
  int year;
  if (components.length != 3 || components[2].isEmpty) {
    year = DateTime.now().year;
  } else {
    year = int.parse(components[2]);
    if (year < 100) year += (DateTime.now().year ~/ 100) * 100;
  }
  return Date(day, month, year);
}

DateTime extractTime(Date d, String s) {
  RegExpMatch? timeCandidate = timeRe.firstMatch(s);
  if (timeCandidate == null) return DateTime(d.year, d.month, d.day, DateTime.now().hour, DateTime.now().minute);

  List<String> timeParts = timeCandidate.group(0)!.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
  return DateTime(d.year, d.month, d.day, hour, minute);
}

DateTime extractDeadline(String s) {
  Date date = extractDate(s);
  return extractTime(date, s);
}

List<ToH> processExternalMatch(String s) {
  s = s.trim();
  s = s.substring(1, s.length - 1);
  return s.split(", ").map((e) => ToH.blankToH(e)).toList();
}

ToH extractTaskSingleLine(Date defaultDate, String listName, int defaultIndex, Color taskColor, String s) {
  ToH newToH = ToH(name: "", listName: "", index: defaultIndex, taskColor: taskColor, insertionTime: DateTime(0));

  RegExpMatch? timeMatch = timestampRe.firstMatch(s);
  if (timeMatch != null) {
    s = s.replaceFirst(timeMatch.group(0)!, "").trim();
    newToH.insertionTime = extractTime(defaultDate, timeMatch.group(0)!);
  }

  RegExpMatch? deadlineMatch = deadlineRe_1.firstMatch(s) ?? deadlineRe_2.firstMatch(s) ?? deadlineRe_3.firstMatch(s);
  if (deadlineMatch != null) {
    s = s.replaceFirst(deadlineMatch.group(0)!, "").trim();
    newToH.deadline = extractDeadline(deadlineMatch.group(0)!);
  }

  RegExpMatch? durationMatch = hasDurationRe.firstMatch(s);
  if (durationMatch != null) {
    // Extract duration from word after whitespace after "timer" e.g. ' timer 3h2m'
    Map<String, String> dur = extractDuration(s.split(durationMatch.group(0)!)[1].split(" ")[0]);
    newToH.timeLimit = durationFromMap(dur);
    s = s.replaceFirst(durationMatch.group(0)! + stringFromDuration(dur), "").trim();
  }

  RegExpMatch? externalMatch = externalRe.firstMatch(s);
  if (externalMatch != null) {
    newToH.requiredToHs = processExternalMatch(externalMatch.group(0)!);
    s = s.replaceFirst(externalMatch.group(0)!, "").trim();
  }

  if (s.endsWith("!")) {
    newToH.isHighlighted = true;
    s = s.substring(0, s.length - 1).trim();
  }
  for (String word in s.split(" ")) {
    if (word.isEmpty) continue;
    if (iconKeywords.containsKey(word.toLowerCase())) {
      newToH.icon = iconKeywords[word.toLowerCase()];
      break;
    }
  }

  return newToH;
}

void handleConstraints(List<ToH> children) {
  final List<ToH> childrenCopy = List.from(children);
  childrenCopy.sort((a, b) => a.constraintDepth.compareTo(b.constraintDepth));

  List<ToH> lastConstraintToHs = [];
  List<ToH> currentConstraintToHs = [];
  int tempConstraintDepth = 0;
  for (ToH child in childrenCopy) {
    if (child.constraintDepth == tempConstraintDepth) {
      currentConstraintToHs.add(child);
    } else if (child.constraintDepth > tempConstraintDepth) {
      lastConstraintToHs = currentConstraintToHs;
      currentConstraintToHs = [child];
    } else {
      throw Exception("Fatal Error during Sorting of constraints!");
    }
    if (tempConstraintDepth != 0) {
      child.requiredToHs != null
          ? child.requiredToHs!.addAll(lastConstraintToHs)
          : child.requiredToHs = lastConstraintToHs;
    }
    tempConstraintDepth = child.constraintDepth;
  }
}

List<ToH> parseTasks(Date listDate, String listName, int defaultIndex, Color taskColor, String text) {
  List<String> segmentedText = text.trim().split("\n");

  bool isDateFirstLine = dateRe.hasMatch(segmentedText[0].trim());
  if (isDateFirstLine) {
    listDate = extractDate(segmentedText[0].trim());
  }

  if (segmentedText.length == 1 || (segmentedText.length == 2 && isDateFirstLine)) {
    return [extractTaskSingleLine(listDate, listName, defaultIndex, taskColor, segmentedText[0].trim())];
  }

  if (isDateFirstLine) {
    segmentedText = segmentedText.sublist(1);
  }
  List<ToH> newToHs = <ToH>[];
  late ToH currentParent;
  Map<int, List<ToH>> tasksWithConstraintDepth = {};
  int lastRecursionDepth = 0;

  for (String line in segmentedText) {
    int recursionDepth = line.length - line.trimLeft().length;
    String modifiedLine = line.trim();

    int constraintDepth = 0;
    String? constraintString = constraintRe.firstMatch(modifiedLine)?.group(0);
    if (constraintString != null) {
      constraintDepth = constraintString.length;
      modifiedLine = modifiedLine.replaceFirst(constraintString, "").trimLeft();
    }

    ToH newToH = extractTaskSingleLine(listDate, listName, defaultIndex, taskColor, modifiedLine);
    newToH.recursionDepth = recursionDepth;
    newToH.constraintDepth = constraintDepth;
    if (recursionDepth == 0) {
      newToHs.add(newToH);
      currentParent = newToH;
    } else {
      if (recursionDepth == lastRecursionDepth) {
        newToH.parent = currentParent;
        currentParent.children!.add(newToH);
      } else if (recursionDepth > lastRecursionDepth) {
        currentParent = currentParent.children!.last;
        newToH.parent = currentParent;
        currentParent.children = <ToH>[newToH];
      } else {
        handleConstraints(currentParent.children!);
        int recursionOffset = lastRecursionDepth - recursionDepth;
        while (recursionOffset > 0) {
          currentParent = currentParent.parent!;
          recursionOffset--;
        }
        newToH.parent = currentParent;
        currentParent.children!.add(newToH);
      }
    }

    lastRecursionDepth = recursionDepth;
    tasksWithConstraintDepth.containsKey(constraintDepth)
        ? tasksWithConstraintDepth[constraintDepth]!.add(newToH)
        : tasksWithConstraintDepth[constraintDepth] = [newToH];
  }
  handleConstraints(newToHs);
  return newToHs;
}

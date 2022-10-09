import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:planer/backend/tasks.dart';

class Date{
  final int year;
  final int month;
  final int day;
  @override
  final int hashCode;

  Date(this.day, this.month, this.year) : hashCode = day * 1000000 + month * 10000 + year;

  Date.fromDateTime(DateTime dateTime) : year = dateTime.year, month = dateTime.month, day = dateTime.day,
        hashCode = dateTime.day * 1000000 + dateTime.month * 10000 + dateTime.year;

  factory Date.now() {return Date.fromDateTime(DateTime.now());}

  @override
  String toString(){
    return "$day.$month.$year";
  }

  factory Date.fromString(String s) {
    List<String> subStrings = s.split(".");
        return Date(int.parse(subStrings[0]), int.parse(subStrings[1]), int.parse(subStrings[2]));
  }

  DateTime toDateTime(){
    return DateTime(year, month, day);
  }

  @override
  bool operator ==(Object other) {
    return other is Date && hashCode == other.hashCode;
  }

}

bool isSameDate(Date a, Date b){
  return a.day == b.day && a.month == b.month && a.year == b.year;
}

int getHashCode(Date key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

Future<void> createJsons() async{
  todoLists.addAll({"Meine Liste" : LinkedHashMap.from({Date.now(): <ToH>[]})});
  todoPools.addAll({"Todo" : <ToH>[]});

  initTodoListsDebug();
  initTodoPoolsDebug();

  await saveTodoLists();
  await saveTodoPools();
  await saveOtherToHs();
}
final Map<String, LinkedHashMap<Date, List<ToH>>> todoLists = {};
final Map<String, List<ToH>> todoPools = {};
final List<StructureToH> structureToHs = <StructureToH>[];
final List<PeriodicToH> periodicToHs = <PeriodicToH>[];
final List<ToH> templateToHs = <ToH>[];

late final File taskListsFile;
late final File taskPoolsFile;
late final File structureToHFile;
late final File periodicToHFile;
late final File templateToHFile;


void initTodoListsDebug() {
  todoLists["Meine Liste"] = LinkedHashMap.from({
      Date.now(): [ToH.debugFactory(0), ToH.debugFactory(1)]
    });
}

String encodeTodoLists() {
  return jsonEncode({
    for (String key in todoLists.keys)
      key: {
        for (Date d in todoLists[key]!.keys)
          d.toString(): [
            for (ToH toh in todoLists[key]![d]!)
              toh.toJson()]
    }
  });
}

void initTodoLists(String encoded) {
  Map<String, dynamic> decoded = jsonDecode(encoded);
  todoLists.addAll({
    for (String key in decoded.keys)
      key: LinkedHashMap<Date, List<ToH>>(
        equals: isSameDate,
        hashCode: getHashCode,
      )..addAll({
        for (String date in decoded[key]!.keys)
          Date.fromString(date): [
            for (Map<String, dynamic> jsonToH in decoded[key]![date]!)
              ToH.fromJson(jsonToH)]
      })
  });
}

void initTodoPoolsDebug() {
  todoPools['Todo'] = [ToH.debugFactory(0), ToH.debugFactory(1)];
}

String encodeTodoPools() {
  return jsonEncode({
    for (String key in todoPools.keys)
      key: [
            for (ToH toh in todoPools[key]!)
              toh.toJson()]
  });
}

void initTodoPools(String encoded) {
  Map<String, dynamic> decoded = jsonDecode(encoded);
  todoPools.addAll({
    for (String key in decoded.keys)
      key: [
            for (Map<String, dynamic> jsonToH in decoded[key]!)
              ToH.fromJson(jsonToH)]
  });
}

void initOtherToHs(String encodedS, String encodedP, String encodedT){
  structureToHs.addAll([for(Map<String, dynamic> jsonS in jsonDecode(encodedS)) StructureToH.fromJson(jsonS)]);
  periodicToHs.addAll([for(Map<String, dynamic> jsonP in jsonDecode(encodedP)) PeriodicToH.fromJson(jsonP)]);
  templateToHs.addAll([for(Map<String, dynamic> jsonT in jsonDecode(encodedT)) ToH.fromJson(jsonT)]);
}

Future<void> saveTodoLists() async{
  await taskListsFile.writeAsString(encodeTodoLists());
}

Future<void> saveTodoPools()async{
  await taskPoolsFile.writeAsString(encodeTodoPools());
}

Future<void> saveOtherToHs()async{
  await structureToHFile.writeAsString(jsonEncode([for(StructureToH s in structureToHs) s.toJson()]));
  await periodicToHFile.writeAsString(jsonEncode([for(PeriodicToH p in periodicToHs) p.toJson()]));
  await templateToHFile.writeAsString(jsonEncode([for(ToH t in templateToHs) t.toJson()]));
}
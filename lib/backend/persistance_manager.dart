import 'dart:collection';
import 'dart:convert';
import 'package:planer/backend/tasks.dart';
import 'package:table_calendar/table_calendar.dart';

void createTaskJson() {
  //db.execute("CREATE TABLE todoListNames(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, UNIQUE(name)");
  //db.execute("CREATE TABLE tohs(uid INTEGER PRIMARY KEY, name TEXT, notes TEXT, timeLimit INT, ");
}

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

/*
Future<List<Ingredient>> getIngredientsFromDb(String tableIdentifier) async {
  final List<Map<String, dynamic>> maps = await db.query(tableIdentifier);
  return List.generate(maps.length, (i) {
    return Ingredient(
      id: maps[i]['id'],
      name: maps[i]['name'],
      amount: maps[i]['amount'],
      categoryIndex: maps[i]['category_id'],
      lifetime: maps[i]['lifetime'],
      measure: unitFromString(maps[i]['measure']),
    );
  });
}

Future<void> insertIngredient(String tableIdentifier, Ingredient ingredient) async {
  await db.insert(
    tableIdentifier,
    ingredient.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateIngredient(String tableIdentifier, Ingredient ingredient) async {
  await db.update(
    tableIdentifier,
    ingredient.toMap(),
    where: 'id = ?',
    whereArgs: [ingredient.id],
  );
}

Future<void> deleteIngredient(String tableIdentifier, int id) async {
  await db.delete(
    tableIdentifier,
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<List<String>> getSearchKeywordsFromDb(String tableIdentifier) async {
  final List<Map<String, dynamic>> maps = await db.query(tableIdentifier);
  return List.generate(maps.length, (i) {
    return maps[i]['name'];
  });
}
*/

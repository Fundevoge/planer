import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planer/backend/persistance_manager.dart';
import 'package:planer/backend/tasks.dart';
import 'package:planer/pages/main_page.dart';
import 'backend/preference_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  initializeDateFormatting('de_DE').then((_) => runApp(
      MaterialApp(
            title: "Planer",
            initialRoute: "/",
            routes: <String, WidgetBuilder>{
              "/": (_) => const MainPage(),
            },
            debugShowCheckedModeBanner: false,
          ))
  );
}

Future<void> init() async {
  bool doOneTimeSetup = true; await jsonStorageSetup();
  if(doOneTimeSetup){
    await initialOneTimeSetup();
  }
  await initState();
}

Future<bool> jsonStorageSetup() async {
  final String directoryPath = (await getApplicationDocumentsDirectory()).path;
  final File taskListFile = File("$directoryPath/taskLists.json");
  final String contents = await taskListFile.readAsString();
  final bool exists = !contents.isNotEmpty;
  if(exists) initTodoLists(contents);
  return !exists;
}

Future<void> initialOneTimeSetup() async {
  createTaskJson();
  myPreferences.setInt('firstOpenedYear', DateTime.now().year);
}

Future<void> initState() async {
  await initPreferences();
  initColors();
  initIcon();
  initTodoListsDebug();
}

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
  bool doOneTimeSetup = true;
  await jsonStorageSetup();
  if(doOneTimeSetup){
    await initialOneTimeSetup();
  }
  await initState();
}

Future<bool> jsonStorageSetup() async {
  final String directoryPath = (await getApplicationDocumentsDirectory()).path;
  taskListsFile = File("$directoryPath/taskLists.json");
  final String taskListContents = await taskListsFile.readAsString();
  taskPoolsFile = File("$directoryPath/taskPools.json");
  final String taskPoolsContents = await taskPoolsFile.readAsString();
  structureToHFile = File("$directoryPath/structureTasks.json");
  final String structureToHContents = await taskPoolsFile.readAsString();
  periodicToHFile = File("$directoryPath/periodicTasks.json");
  final String periodicToHContents = await taskPoolsFile.readAsString();
  templateToHFile = File("$directoryPath/templateTasks.json");
  final String templateToH = await taskPoolsFile.readAsString();
  final bool exists = !taskListContents.isNotEmpty;
  if(exists) {
    initTodoLists(taskListContents);
    initTodoPools(taskPoolsContents);
    initOtherToHs(structureToHContents, periodicToHContents, templateToH);
  }
  return !exists;
}

Future<void> initialOneTimeSetup() async {
  createJsons();
  myPreferences.setInt('firstOpenedYear', DateTime.now().year);
}

Future<void> initState() async {
  await initPreferences();
  initColors();
  initIcon();
  initTodoListsDebug();
}

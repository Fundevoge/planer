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
  taskPoolsFile = File("$directoryPath/taskPools.json");
  structureToHFile = File("$directoryPath/structureTasks.json");
  periodicToHFile = File("$directoryPath/periodicTasks.json");
  templateToHFile = File("$directoryPath/templateTasks.json");

  final bool exists = await taskListsFile.exists();

  if(exists) {
    final String taskListContents = await taskListsFile.readAsString();
    final String taskPoolsContents = await taskPoolsFile.readAsString();
    final String structureToHContents = await taskPoolsFile.readAsString();
    final String periodicToHContents = await taskPoolsFile.readAsString();
    final String templateToH = await taskPoolsFile.readAsString();
    initTodoLists(taskListContents);
    initTodoPools(taskPoolsContents);
    initOtherToHs(structureToHContents, periodicToHContents, templateToH);
  }
  else{
    await taskListsFile.create(recursive: true);
    await taskPoolsFile.create(recursive: true);
    await structureToHFile.create(recursive: true);
    await periodicToHFile.create(recursive: true);
    await templateToHFile.create(recursive: true);
    await createJsons();
  }
  return !exists;
}

Future<void> initialOneTimeSetup() async {
  myPreferences.setInt('firstOpenedYear', DateTime.now().year);
}

Future<void> initState() async {
  await initPreferences();
  initColors();
  initIcon();
  initTodoListsDebug();
}

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:planer/backend/db_manager.dart';
import 'package:planer/backend/tasks.dart';
import 'package:planer/pages/main_page.dart';

import 'backend/preference_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPreferences();
  initColors();
  initIcon();
  initTodoLists();
  checkFirstOpen();
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

void checkFirstOpen(){
  if(myPreferences.getInt('firstOpenedYear') != null) return;
  myPreferences.setInt('firstOpenedYear', DateTime.now().year);
}
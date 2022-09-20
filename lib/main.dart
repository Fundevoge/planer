import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:planer/pages/main_page.dart';

import 'backend/preference_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPreferences();
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

// TODO: Make Routines definable: Wie Wecker, teilweise auch mehrmals täglich oder Monatlich;
//  -> Tagesplan mit subroutines; Template creation farblich anders
//  -> Long term Tds e.g. Stromvertrag
// TODO: Groups with header
//  -> folded and unfolded
//  -> collapse daily routine to colored lines
// TODO: Sequential TODOS with constraints; Show additional info on what type of task
//   e.g. calling somewhere  or working etc.
// TODO: Menu for easily interacting with the Tds;
//  -> Add Multiple tds at once with linebreaks
// TODO: Make listitems interactive
//  -> Move to next day or delete
// TODO: Add deadlines / specific times to todos
// TODO: Create Pools of Tds/Things to do
//  -> Can be pulled into plan without going away
//  -> Extra pool for shared lists
//  -> can be pulled from another pool?
//  -> Task specific pools e.g. recipes for breakfast etc.
// TODO: Add Calendar view with appointments
//  -> show tasks from different groups in different colors
// TODO: Make shared somehow
//    Multiple Lists, when shared lists send requests
//    option to move td between lists
//    custom icons and names
//    option for read-only-share; irgendwie ausgegraut
// TODO: AUtomatic and manual backups
// TODO: Fun things; relaxing views e.g. file transfer
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:planer/pages/main_page.dart';

import 'helper/preference_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPreferences();
  initializeDateFormatting('de_DE').then((_) => runApp(
      MaterialApp(
            title: "Planer",
            initialRoute: "/",
            routes: <String, WidgetBuilder>{
              "/": (_) => const MainPage(),
            },
          ))
  );

}

// TODO: Make Routines definable: Wie Wecker, teilweise auch mehrmals täglich oder Monatlich;
//  Tagesplan mit subroutines; Template creation farblich anders
// TODO: Groups with header; folded and unfolded
// TODO: Sequential TODOS with constraints; Show additional info on what type of task
//   e.g. calling somewhere  or working etc.
// TODO: Menu for easily interacting with the Tds;
//  -> Add Multiple tds at once with linebreaks
// TODO: Make listitems interactive
//  -> Move to next day or delete
// TODO: Add deadlines / specific times to todos
// TODO: Add Calendar view with apppointments
// TODO: Make shared somehow
//    Multiple Lists, when shared lists send requests
//    option to move td to shared list
//    custom icons and names
// TODO: Fun things; relaxing views e.g. file transfer
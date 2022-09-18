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
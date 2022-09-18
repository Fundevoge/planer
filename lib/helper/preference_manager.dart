import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences myPreferences;

Future<void> initPreferences() async {
  myPreferences = await SharedPreferences.getInstance();
}

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceSingleton {
  static late SharedPreferences sharedPreferences;
  static Future<void> initialise() async =>
      sharedPreferences = await SharedPreferences.getInstance();
}

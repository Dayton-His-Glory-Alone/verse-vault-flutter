import 'package:shared_preferences/shared_preferences.dart';

class ProgressManager {
  static Future<int> getCurrentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentMode') ?? 0;
  }

  static Future<void> setCurrentMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentMode', mode);
  }
}

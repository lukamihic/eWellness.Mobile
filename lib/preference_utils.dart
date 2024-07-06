import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static const String _keyUserId = 'userId';

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }
}

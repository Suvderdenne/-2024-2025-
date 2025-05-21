import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;  // Return 0 if user_id is not found
  }

  static Future<void> setUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);  // Save user_id to SharedPreferences
  }

  static Future<void> clearUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token'); // Устгах token
    await prefs.remove('refresh_token'); // Устгах refresh token
  }
}

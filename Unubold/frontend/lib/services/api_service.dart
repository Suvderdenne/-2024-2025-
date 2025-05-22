import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Android Emulator-д зориулсан IP

  /// ✅ Token хадгалах
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  /// ✅ Token устгах (logout-д ашиглана)
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  /// ✅ Token авах
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// ✅ GET хүсэлт
  Future<http.Response> get(String endpoint) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// ✅ POST хүсэлт
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');

    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  /// ✅ Refresh токен ашиглан access_token шинэчлэх (шаардлагатай үед)
  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return;

    final url = Uri.parse('$baseUrl/token/refresh/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccess = data['access'];
      await prefs.setString('access_token', newAccess);
    } else {
      await clearTokens(); // Token хугацаа дууссан бол logout
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Get the stored auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Add auth headers to requests that need authentication
  static Future<Map<String, String>> getHeaders() async {
    final token = await getAuthToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  // Generic GET request with authentication
  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse(getApiUrl(endpoint)),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Generic POST request with authentication
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse(getApiUrl(endpoint)),
        headers: headers,
        body: json.encode(data),
      );

      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // Helper method to process response
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      Map<String, dynamic> error = {'status': response.statusCode};
      try {
        error.addAll(json.decode(response.body));
      } catch (_) {}
      throw error;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
  }

  static String getApiUrl(String endpoint) {
    return '$baseUrl/$endpoint';
  }
}

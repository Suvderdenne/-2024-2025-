import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString('user_email');
    
    if (currentEmail == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(utf8.decode(response.bodyBytes));
      final user = users.firstWhere(
        (user) => user['email'] == currentEmail,
        orElse: () => null,
      );
      
      if (user != null) {
        // Ensure the photo URL is properly formatted
        if (user['photo'] != null && !user['photo'].startsWith('http')) {
          user['photo'] = 'http://127.0.0.1:8000${user['photo']}';
        }
        // Update stored username
        if (user['username'] != null) {
          await prefs.setString('username', user['username']);
        }
        return user;
      }
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Store user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('username', data['username']);
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Нэвтрэх үед алдаа гарлаа');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Бүртгүүлэх үед алдаа гарлаа');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('username');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') != null;
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<dynamic>> fetchTeams() async {
    final response = await http.get(Uri.parse('$baseUrl/teams/'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load teams');
    }
  }

  Future<List<dynamic>> fetchTeamStats() async {
    final response = await http.get(Uri.parse('$baseUrl/teamstats/'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load team stats');
    }
  }

  Future<List<dynamic>> fetchPlayers() async {
    final response = await http.get(Uri.parse('$baseUrl/players/'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load players');
    }
  }

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse('$baseUrl/news/'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load news');
    }
  }

  Future<List<dynamic>> fetchGames() async {
    final response = await http.get(Uri.parse('$baseUrl/games/'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<List<dynamic>> fetchPlayerSeasonStats() async {
    final response = await http.get(Uri.parse('$baseUrl/playerseasonstats/'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load player season stats');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String email,
    String? username,
    dynamic photo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString('user_email');
    
    if (currentEmail == null) {
      throw Exception('User not logged in');
    }

    final uri = Uri.parse('$baseUrl/users/update/');
    final request = http.MultipartRequest('PUT', uri);

    // Add email
    request.fields['email'] = email;

    // Add username if provided
    if (username != null) {
      request.fields['username'] = username;
    }

    // Add photo if provided
    if (photo != null) {
      if (kIsWeb) {
        // For web, use XFile
        final XFile xFile = photo as XFile;
        final bytes = await xFile.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: xFile.name,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      } else {
        // For mobile, use File
        final File file = photo as File;
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'photo',
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Update stored email if it changed
        if (email != currentEmail) {
          await prefs.setString('user_email', email);
        }
        // Update stored username if it changed
        if (username != null) {
          await prefs.setString('username', username);
        }
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}

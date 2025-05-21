// auth_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  int _coins = 0;
  List<int> _completedLevels = [1]; // Initialize with level 1 unlocked
  int _englishWordsGuessed = 0;
  int _mongolianWordsGuessed = 0;

  // Getters
  String? get token => _token;
  String? get username => _username;
  int get coins => _coins;
  List<int> get completedLevels => _completedLevels;
  int get englishWordsGuessed => _englishWordsGuessed;
  int get mongolianWordsGuessed => _mongolianWordsGuessed;
  bool get isAuthenticated => _token != null;

  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.185:8000/api/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _username = data['username'];
        _coins = data['coins'] ?? 0;
        _completedLevels = List<int>.from(data['completed_levels'] ?? [1]);
        _englishWordsGuessed = data['english_words_guessed'] ?? 0;
        _mongolianWordsGuessed = data['mongolian_words_guessed'] ?? 0;
        notifyListeners();
      } else {
        throw Exception(data['detail'] ?? 'Failed to login');
      }
    } catch (e) {
      // Generic error handling
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> register(
    String fullName,
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.185:8000/api/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        _token = data['token'];
        _username = data['username'];
        _coins = data['coins'] ?? 0;
        _completedLevels = List<int>.from(data['completed_levels'] ?? [1]);
        notifyListeners();
      } else {
        throw Exception(data['detail'] ?? 'Failed to register');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Method to update user stats
  void updateUserStats(Map<String, dynamic> data) {
    _coins = data['coins'] ?? _coins;
    _completedLevels = List<int>.from(
      data['completed_levels'] ?? _completedLevels,
    );
    _englishWordsGuessed =
        data['english_words_guessed'] ?? _englishWordsGuessed;
    _mongolianWordsGuessed =
        data['mongolian_words_guessed'] ?? _mongolianWordsGuessed;
    notifyListeners();
  }

  // Method to log out
  void logout() {
    _token = null;
    _username = null;
    _coins = 0;
    _completedLevels = [1];
    _englishWordsGuessed = 0;
    _mongolianWordsGuessed = 0;
    notifyListeners();
  }
}

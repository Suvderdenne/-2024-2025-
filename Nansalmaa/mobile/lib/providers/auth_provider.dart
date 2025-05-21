import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;
  String? _error;
  final String baseUrl = 'http://127.0.0.1:8000/api';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await _storage.read(key: 'token');
      if (_token != null) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);
      _token = response['token'];
      _user = response['user'];
      _isAuthenticated = true;
      await _storage.write(key: 'token', value: _token);
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _user = null;
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String username,
    String password,
    String email,
    String firstName,
    String lastName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(
        username,
        password,
        email,
        firstName,
        lastName,
      );
      _token = response['token'];
      _user = response['user'];
      _isAuthenticated = true;
      await _storage.write(key: 'token', value: _token);
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } finally {
      await _storage.delete(key: 'token');
      _isAuthenticated = false;
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        profileImage: profileImage,
      );
      _user = response;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String base64Image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateProfileImage(base64Image);
      _user = response;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
// game_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class GameProvider with ChangeNotifier {
  List<List<String>> _grid = [];
  int _gridSize = 0; // Changed to 0 initially
  List<String> _wordsToFind = [];
  List<String> _foundWords = [];
  Set<String> _selectedCells = {};
  int _coins = 0;
  String _language = 'EN';
  int _currentLevel = 1; // Track current level
  bool _levelCompleted = false;

  // Getters
  List<List<String>> get grid => _grid;
  int get gridSize => _gridSize;
  List<String> get wordsToFind => _wordsToFind;
  List<String> get foundWords => _foundWords;
  int get coins => _coins;
  String get language => _language;
  int get currentLevel => _currentLevel;
  bool get levelCompleted => _levelCompleted;

  // Set language
  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // Initialize game
  Future<void> initGame(int level, BuildContext context) async {
    _currentLevel = level;
    _levelCompleted = false;
    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      ); // Get AuthProvider
      final token = authProvider.token;

      if (token == null) {
        throw Exception(
          'User not authenticated',
        ); // Handle case where token is missing
      }

      final response = await http.get(
        Uri.parse('http://192.168.4.185:8000/api/levels/$level/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Token-оо оруулж байгаа эсэх
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _gridSize = data['grid_size'];
        _wordsToFind = List<String>.from(
          data['words'].map((word) => word['word']),
        );
        _grid = List<List<String>>.generate(
          _gridSize,
          (i) => List<String>.filled(_gridSize, ''),
        );
        _foundWords.clear();
        _selectedCells.clear();
        generateGrid(data['grid_data']);
        notifyListeners();
      } else {
        throw Exception('Failed to load level data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error initializing game: $e');
    }
  }

  String getCellLetter(int row, int col) {
    if (row < 0 ||
        row >= _grid.length ||
        col < 0 ||
        col >= _grid[0].length ||
        _grid.isEmpty) {
      return '';
    }
    return _grid[row][col];
  }

  bool isSelected(int row, int col) {
    return _selectedCells.contains('$row-$col');
  }

  void selectCell(int row, int col, BuildContext context) {
    _selectedCells.add('$row-$col');
    notifyListeners();
  }

  void clearSelection() {
    _selectedCells.clear();
    notifyListeners();
  }

  Future<void> submitWord(BuildContext context) async {
    String selectedWord =
        _selectedCells
            .map(
              (key) => getCellLetter(
                int.parse(key.split('-')[0]),
                int.parse(key.split('-')[1]),
              ),
            )
            .join();

    if (_wordsToFind.contains(selectedWord) &&
        !_foundWords.contains(selectedWord)) {
      _foundWords.add(selectedWord);
      _selectedCells.clear();
      notifyListeners();

      if (_foundWords.length == _wordsToFind.length) {
        _levelCompleted = true;
        notifyListeners();
        await completeLevel(context);
      }
    } else {
      _selectedCells.clear();
      notifyListeners();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Word not found!')));
    }
  }

  Future<void> completeLevel(BuildContext context) async {
    // Send level completion to the backend
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.185:8000/api/users/complete_level/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({'level': _currentLevel, 'language': _language}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        authProvider.updateUserStats(data); // Update AuthProvider
        notifyListeners();
      } else {
        throw Exception('Failed to complete level');
      }
    } catch (e) {
      throw Exception('Error completing level: $e');
    }
  }

  Future<bool> useHint(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.coins < 200) {
      return false; // Not enough coins
    }

    // Deduct coins and update on server
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.185:8000/api/users/use_hint/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${authProvider.token}',
        },
        body: json.encode({'coins_to_deduct': 200}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        authProvider.updateUserStats(data);
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to use hint');
      }
    } catch (e) {
      throw Exception('Error using hint: $e');
    }
  }

  bool _isLevelLocked(int level, List<int> completedLevels) {
    return level > 1 && !completedLevels.contains(level - 1);
  }

  void generateGrid(List<List<String>> gridData) {
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        _grid[i][j] = gridData[i][j];
      }
    }
  }
}

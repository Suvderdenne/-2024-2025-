import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../models/game.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Use your Django server URL

  Future<List<Player>> getPlayers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/players/'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        // Limit to most recent 10 players
        return data.map((json) => Player.fromJson(json))
            .toList()
            .take(10)
            .toList();
      } else {
        throw Exception('Failed to load players');
      }
    } catch (e) {
      print('Error fetching players: $e');
      return [];  // Return empty list on error
    }
  }

  Future<List<Game>> getGames() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/games/'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Game.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load games');
      }
    } catch (e) {
      print('Error fetching games: $e');
      return [];
    }
  }

  Future<void> createGame(int playerId, int score, {
    required String gameType,
    String? gameName,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'player': playerId,
        'score': score,
        'game_type': gameType,
        'game_name': gameName ?? 'Memory Match',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/games/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to save game score: ${response.body}');
      }
    } catch (e) {
      print('Error saving game: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<bool> checkNameExists(String name) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/players/check-name/$name/'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body)['exists'];
      }
      return false;
    } catch (e) {
      print('Error checking name: $e');
      return false;
    }
  }

  Future<Player> createPlayer(String name) async {
    // First check if name exists
    final nameExists = await checkNameExists(name);
    if (nameExists) {
      throw Exception('Энэ нэр аль хэдийн бүртгэгдсэн байна');
    }

    // If name doesn't exist, create new player
    try {
      final Map<String, dynamic> body = {
        'name': name,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/players/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      
      if (response.statusCode == 201) {
        return Player.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create player');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> getGameProgress(int playerId, String gameType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game-progress/get_progress/')
            .replace(queryParameters: {
          'player_id': playerId.toString(),
          'game_type': gameType,
        }),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load game progress');
      }
    } catch (e) {
      print('Error fetching game progress: $e');
      return null;
    }
  }

  Future<void> saveGameProgress(int playerId, String gameType, {
    required int currentLevel,
    required int score,
    required List<String> cardImages,
    required List<bool> flippedCards,
    required List<bool> matchedCards,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'player_id': playerId,
        'game_type': gameType,
        'current_level': currentLevel,
        'score': score,
        'card_images': cardImages,
        'flipped_cards': flippedCards,
        'matched_cards': matchedCards,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/game-progress/save_progress/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to save game progress: ${response.body}');
      }
    } catch (e) {
      print('Error saving game progress: $e');
      throw Exception('Network error: $e');
    }
  }
} 
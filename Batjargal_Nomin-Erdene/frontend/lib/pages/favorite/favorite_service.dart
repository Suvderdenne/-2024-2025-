//favorite_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> _getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userid')?.toString();
}

class FavoriteService {
  static const String baseUrl = 'http://0.0.0.0:8000/favorite/';

  static Future<void> addFavorite(Map<String, dynamic> book) async {
    final userId = await _getUserId();
    if (userId == null) return;

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'add', 'user_id': userId, 'book': book}),
    );

    if (response.statusCode != 200) {
      throw Exception('Ном хадгалах үед алдаа гарлаа');
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'get', 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return List<Map<String, dynamic>>.from(body['data']);
    } else {
      throw Exception('Хадгалсан ном авах үед алдаа гарлаа');
    }
  }

  static Future<void> removeFavorite(String bookId) async {
    final userId = await _getUserId();
    if (userId == null) return;

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'remove',
        'user_id': userId,
        'book_id': bookId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Хадгалсан ном устгах үед алдаа гарлаа');
    }
  }
}

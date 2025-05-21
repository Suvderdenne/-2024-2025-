// ✅ review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<List<dynamic>> fetchReviews(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$productId/reviews/'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Сэтгэгдэл уншиж чадсангүй");
    }
  }

  Future<bool> submitReview(int productId, int rating, String comment) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/products/$productId/review/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    return res.statusCode == 201;
  }

  Future<bool> updateReview(int reviewId, int rating, String comment) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/reviews/$reviewId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteReview(int reviewId) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/reviews/$reviewId/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 204;
  }
}

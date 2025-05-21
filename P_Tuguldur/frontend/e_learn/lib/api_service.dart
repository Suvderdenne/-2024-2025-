// services/api_service.dart

import 'dart:convert';
import 'package:e_learn/tools/quiz_question.dart'; // Assuming QuizQuestion is defined here or in tools/
import 'package:e_learn/tools/user_stats.dart'; // Assuming UserStats is defined here or in tools/
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your actual backend URL
  final String baseUrl = 'http://127.0.0.1:8000'; // өөрийн URL

  // Method to fetch user statistics
  Future<UserStats> fetchUserStats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-stats/'),
      headers: {
        'Authorization': 'Bearer $token', // Include the token for authentication
      },
    );

    // Decode the response body, handling potential non-200 status codes
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return UserStats.fromJson(responseBody); // Return UserStats object
    } else {
      // Throw an exception with error details from the server
      throw Exception('Failed to load user stats. Status code: ${response.statusCode}. Error: ${responseBody['error'] ?? 'Unknown error'}');
    }
  }

  // Method to fetch quiz questions
  Future<List<QuizQuestion>> fetchQuiz(String token, String category, String level) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get-quiz/?category=$category&level=$level'),
      headers: {
        'Authorization': 'Bearer $token', // Include the token for authentication
      },
    );

    // Decode the response body, handling potential non-200 status codes
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      List<dynamic> data = responseBody; // Data is already decoded
      return data.map((q) => QuizQuestion.fromJson(q)).toList();
    } else {
      // Provide more specific error information
      throw Exception('Failed to load quiz. Status code: ${response.statusCode}. Error: ${responseBody['error'] ?? 'Unknown error'}');
    }
  }

  // Method to submit test answers
  Future<Map<String, dynamic>> submitTest(String token, List<Map<String, dynamic>> answers, String category, String level) async {
    if (answers.isEmpty || category.isEmpty || level.isEmpty) {
      throw Exception('All fields (answers, category, level) are required.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/submit-test/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'answers': answers,
        'category': category,
        'level': level,
      }),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception('Failed to submit test. Status code: ${response.statusCode}. Error: ${responseBody['error'] ?? 'Unknown error'}');
    }
  }

  // Method to fetch user profile information
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user-profile/'),
      headers: {
        'Authorization': 'Bearer $token', // Include the token for authentication
        'Content-Type': 'application/json', // Specify content type
      },
    );

    // Decode the response body, handling potential non-200 status codes
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      return responseBody; // Return profile information
    } else {
      // Throw an exception with error details from the server
      throw Exception('Failed to load user profile. Status code: ${response.statusCode}. Error: ${responseBody['error'] ?? 'Unknown error'}');
    }
  }



  // Add methods for categories and levels if needed here, or keep them in LessonScreen if that's where they are used
   Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories/'));
    // No auth header needed for categories/levels if they are publicly accessible
    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load categories (${response.statusCode})');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLevels() async {
    final response = await http.get(Uri.parse('$baseUrl/levels/'));
     // No auth header needed for categories/levels if they are publicly accessible
    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load levels (${response.statusCode})');
    }
  }
}

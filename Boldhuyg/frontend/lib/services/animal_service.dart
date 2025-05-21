import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimalService {
  static const String baseUrl =
      'http://localhost:8000/'; // Adjust this to your backend URL

  Future<List<Map<String, dynamic>>> getAnimalTypes() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/animal-types-with-animals/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load animal types');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAnimalsBySubject(int subjectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/animals/by-subject/$subjectId/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load animals');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String apiUrl =
      'http://192.168.0.242:8000/api/categories/'; // Replace with your actual API URL

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
          data.map((item) => item as Map<String, dynamic>));
    } else {
      throw Exception('Failed to load categories');
    }
  }
}

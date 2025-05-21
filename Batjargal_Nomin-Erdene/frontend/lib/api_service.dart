import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://10.0.2.2:8000/api"; // Emulator-ээс API дуудах
  static const String domogEndpoint = "$baseUrl/domog/";

  static Future<List<dynamic>> fetchDomogs() async {
    try {
      final response = await http.get(Uri.parse(domogEndpoint));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load domogs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching domogs: $e");
      throw Exception("Error fetching domogs");
    }
  }
}

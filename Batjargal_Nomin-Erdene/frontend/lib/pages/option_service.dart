import 'dart:convert';
import 'package:http/http.dart' as http;

class OptionService {
  final String apiUrl = "http://0.0.0.0:8000/search/options/";

  Future<Map<String, List<String>>> fetchOptions() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "types": List<String>.from(data["types"]),
        "genres": List<String>.from(data["genres"]),
      };
    } else {
      throw Exception("Failed to load options");
    }
  }

  Future<List<String>> fetchGenresByType(String type) async {
    final url = Uri.parse('$apiUrl?type=$type');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data["genres"]);
    } else {
      throw Exception("Failed to load genres by type");
    }
  }
}

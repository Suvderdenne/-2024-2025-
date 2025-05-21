//history_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  static Future<void> saveReadingHistory(int userId, int bookId) async {
    final url = Uri.parse("http://0.0.0.0:8000/readinghistory/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "addreadinghistory",
        "user_id": userId,
        "book_id": bookId,
      }),
    );

    if (response.statusCode != 200) {
      print("Хадгалах үед алдаа гарлаа.");
    }
  }
}

//watched_history_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WatchedHistoryTab extends StatefulWidget {
  final int userId;
  const WatchedHistoryTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<WatchedHistoryTab> createState() => _WatchedHistoryTabState();
}

class _WatchedHistoryTabState extends State<WatchedHistoryTab> {
  List<Map<String, dynamic>> watchedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWatchedBooks();
  }

  Future<void> fetchWatchedBooks() async {
    const String apiUrl = 'http://0.0.0.0:8000/readinghistory/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "action": "getreadinghistory",
          "user_id": widget.userId,
        }),
      );

      print("userId: ${widget.userId}");
      print("RESPONSE STATUS: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        setState(() {
          watchedBooks = List<Map<String, dynamic>>.from(responseData['data']);
          isLoading = false;
        });
      } else {
        print("⚠️ 'data' key not found in response.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching watched books: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (watchedBooks.isEmpty) {
      return const Center(child: Text("Үзсэн түүх алга байна."));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: watchedBooks.length,
        itemBuilder: (context, index) {
          final book = watchedBooks[index];
          final String watchedAt = dateFormat.format(
            DateTime.parse(book['watched_at']),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 2)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    book['img_url'] ?? '',
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Үзсэн огноо: $watchedAt",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class NewsDetailsScreen extends StatefulWidget {
  final int newsId;

  NewsDetailsScreen({required this.newsId});

  @override
  _NewsDetailsScreenState createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  late Future<Map<String, dynamic>> newsDetails;

  Future<Map<String, dynamic>> fetchNewsDetails() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/news/${widget.newsId}/'),
    );

    if (response.statusCode == 200) {
      var decodedJson = utf8.decode(response.bodyBytes);
      return json.decode(decodedJson);
    } else {
      throw Exception('Failed to load news details. Status code: ${response.statusCode}');
    }
  }

  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;

    // Remove the header "data:image/jpeg;base64," if present
    final regex = RegExp(r'data:image/[^;]+;base64,');
    base64String = base64String.replaceAll(regex, '');

    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    newsDetails = fetchNewsDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News Details"),
        backgroundColor: Color(0xFF4169E1), // Set AppBar color to royal blue
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: newsDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No details available"));
          }

          var news = snapshot.data!;
          Uint8List? imageBytes = decodeBase64Image(news['image_base64']);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                SizedBox(height: 16),
                Text(
                  news['title'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Published by ${news['publisher']} on ${news['created_at']}",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                Text(
                  news['description'],
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEAB308),
                  ),
                  onPressed: () {
                    // Optionally open news source
                  },
                  child: Text("Read More"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

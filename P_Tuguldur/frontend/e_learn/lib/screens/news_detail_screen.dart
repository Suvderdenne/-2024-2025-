import 'dart:convert';
import 'package:flutter/material.dart';

// Define the primary green color
const Color primaryGreen = Color(0xFF8BC34A);
const Color whiteColor = Colors.white;

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final imageBase64 = news['image_base64'];
    final title = news['title'];
    final content = news['content'];
    final author = news['author'];
    final date = news['created_at'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News Detail',
          style: TextStyle(color: whiteColor), // Set title text color to white
        ),
        backgroundColor: primaryGreen, // Set AppBar background color to primary green
        foregroundColor: whiteColor, // Set icon/button color in AppBar to white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBase64 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(imageBase64),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Keep title text dark for readability
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By $author • $date',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey, // Keep date/author text grey
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87, // Keep content text dark for readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class Book {
  final String id;
  final String name;
  final String title;
  final String type;
  final DateTime date;
  final String imgUrl;
  final List<String> altImgUrls;
  final String audioUrl;
  final int score;
  final String review;
  final num height;
  final int duration; // Duration in minutes
  final String turul;
  final String summary;
  final double progress;
  bool isFavorite;

  Book({
    required this.id,
    required this.title,
    required this.name,
    required this.type,
    required this.date,
    required this.imgUrl,
    required this.altImgUrls, // Хувилбар зураг
    required this.audioUrl,
    required this.score,
    required this.review,
    required this.height,
    required this.duration,
    required this.turul,
    required this.summary,
    required this.progress,
    this.isFavorite = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      date: DateTime.tryParse(json['date']) ?? DateTime(1970),
      imgUrl: json['img_url'] ?? '',
      altImgUrls:
          (json['alt_img_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      audioUrl: json['audio_url'] ?? '', // Аудио ном
      score: json['score'] ?? 0,
      review: json['review'] ?? '',
      height: num.tryParse(json['height'].toString()) ?? 0,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      turul: json['turul'] ?? '',
      summary: json['summary'] ?? '',
      progress:
          (json['progress'] != null)
              ? double.tryParse(json['progress'].toString()) ?? 0.0
              : Random().nextDouble() * 0.9,
      isFavorite: false,
    );
  }

  static Future<List<Book>> fetchBooks(BuildContext context) async {
    final url = Uri.parse(baseUrl + 'book/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'getallbook'}),
      );

      if (response.statusCode == 200) {
        final successData = json.decode(response.body);
        if (successData['resultCode'] == 200) {
          final List booksJson = successData['data'] ?? [];
          return booksJson.map((json) => Book.fromJson(json)).toList();
        } else {
          _showSnackbar(context, 'Алдаа: ${successData['resultMessage']}');
        }
      } else {
        _showSnackbar(context, 'Сервертэй холбогдож чадсангүй.');
      }
    } catch (e) {
      print(e);
      _showSnackbar(context, 'Алдаа гарлаа: $e');
    }
    print("return []");
    return [];
  }

  static Book getRandomBook(List<Book> books) {
    if (books.isEmpty)
      return Book(
        id: '',
        title: '',
        name: '',
        type: '',
        date: DateTime.now(),
        imgUrl: '',
        altImgUrls: [],
        audioUrl: '',
        score: 0,
        review: '',
        height: 0,
        duration: 0,
        turul: '',
        summary: '',
        progress: 0,
      );
    final random = Random();
    return books[random.nextInt(books.length)];
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Хайлтын функц нэмэх
  static Future<List<Book>> searchBooks(
    BuildContext context,
    String query,
  ) async {
    final url = Uri.parse(baseUrl + 'book/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'searchbook', 'query': query}),
      );

      if (response.statusCode == 200) {
        final successData = json.decode(response.body);
        if (successData['resultCode'] == 200) {
          final List booksJson = successData['data'] ?? [];
          return booksJson.map((json) => Book.fromJson(json)).toList();
        } else {
          _showSnackbar(context, 'Алдаа: ${successData['resultMessage']}');
        }
      } else {
        _showSnackbar(context, 'Сервертэй холбогдож чадсангүй.');
      }
    } catch (e) {
      print(e);
      _showSnackbar(context, 'Алдаа гарлаа: $e');
    }
    print("return []");
    return [];
  }
}

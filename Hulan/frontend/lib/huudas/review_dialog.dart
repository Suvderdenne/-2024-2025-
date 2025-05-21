import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewDialog extends StatefulWidget {
  final int productId;
  final int? initialRating;
  final String? initialComment;
  final int? reviewId; // if editing

  const ReviewDialog({
    super.key,
    required this.productId,
    this.initialRating,
    this.initialComment,
    this.reviewId,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  final String baseUrl = 'http://127.0.0.1:8000';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 5;
    _commentController.text = widget.initialComment ?? '';
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<void> _submitReview() async {
    final token = await _getAccessToken();
    if (token == null) return;

    setState(() => _isSubmitting = true);

    final url = widget.reviewId == null
        ? '$baseUrl/api/products/${widget.productId}/reviews/'
        : '$baseUrl/api/reviews/${widget.reviewId}/';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'rating': _rating,
        'comment': _commentController.text,
      }),
    );

    setState(() => _isSubmitting = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Сэтгэгдэл илгээхэд алдаа гарлаа')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reviewId != null ? 'Сэтгэгдэл засах' : 'Шинэ сэтгэгдэл'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() => _rating = index + 1);
              },
            )),
          ),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Сэтгэгдэл бичих',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Болих'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: Text(_isSubmitting ? 'Илгээж байна...' : 'Илгээх'),
        )
      ],
    );
  }
}

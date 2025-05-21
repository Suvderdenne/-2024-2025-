import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommentInputWidget extends StatefulWidget {
  final int postId;
  final VoidCallback onCommentAdded;

  CommentInputWidget({required this.postId, required this.onCommentAdded});

  @override
  _CommentInputWidgetState createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();

  Future<void> submitComment() async {
    if (_controller.text.trim().isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication token not found")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/posts/${widget.postId}/comment/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': _controller.text}),
    );

    if (response.statusCode == 201) {
      _controller.clear();
      widget.onCommentAdded();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post comment: ${response.reasonPhrase}")),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Add a comment...",
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.indigo[800],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white, size: 20),
            onPressed: submitComment,
          ),
        ),
      ],
    ),
  );
}

}

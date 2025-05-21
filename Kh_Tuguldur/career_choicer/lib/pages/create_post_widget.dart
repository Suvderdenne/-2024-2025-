import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreatePostScreen extends StatefulWidget {
  final VoidCallback onPostCreated;
  CreatePostScreen({required this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile;
  String? _imageFileWeb;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() => _imageFileWeb = pickedFile.path);
      } else {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<void> createPost() async {
    final uri = Uri.parse('http://127.0.0.1:8000/posts/');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Authentication token not found")));
      return;
    }

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = _titleController.text
      ..fields['content'] = _contentController.text;

    if (_imageFile != null && !kIsWeb) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _imageFile!.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    } else if (_imageFileWeb != null && kIsWeb) {
      final bytes = await XFile(_imageFileWeb!).readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'upload.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      widget.onPostCreated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create post")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const royalBlue = Color(0xFF4169E1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: royalBlue,
        title: Text("Create Post", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: royalBlue),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Content",
                labelStyle: TextStyle(color: royalBlue),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Image Picker Display
            if (_imageFile != null && !kIsWeb)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 180, width: double.infinity, fit: BoxFit.cover),
              )
            else if (_imageFileWeb != null && kIsWeb)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_imageFileWeb!, height: 180, width: double.infinity, fit: BoxFit.cover),
              )
            else
              OutlinedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image, color: royalBlue),
                label: Text("Pick Image", style: TextStyle(color: royalBlue)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: royalBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

            SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                onPressed: createPost,
                icon: Icon(Icons.send),
                label: Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: royalBlue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

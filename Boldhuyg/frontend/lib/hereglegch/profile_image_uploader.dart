import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileImageUploader extends StatefulWidget {
  final int userId;

  const ProfileImageUploader({super.key, required this.userId});

  @override
  State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  File? _image; // The selected image file
  String? _imageUrl; // The image URL returned from the server

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Store the selected image
        });
        await _uploadImage(_image!); // Upload the image to the server
      } else {
        debugPrint("No image selected");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Зураг сонгоход алдаа гарлаа.')));
      }
    }
  }

  // Function to upload the image to the server
  Future<void> _uploadImage(File image) async {
    try {
      var uri = Uri.parse(
          'http://127.0.0.1:8000/api/user/${widget.userId}/upload-profile/');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        // Assuming the server returns a JSON response with 'image_url'
        final Map<String, dynamic> responseData = json.decode(resBody);
        final imageUrl = 'http://127.0.0.1:8000${responseData['image_url']}';

        setState(() {
          _imageUrl = imageUrl; // Store the image URL
        });
        debugPrint("Image uploaded successfully: $imageUrl");
      } else {
        debugPrint('Failed to upload image: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Зураг илгээхэд алдаа гарлаа.')));
        }
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Зураг илгээхэд алдаа гарлаа.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage, // On tap, pick an image from the gallery
          child: CircleAvatar(
            radius: 60,
            backgroundImage: _imageUrl != null
                ? NetworkImage(
                    _imageUrl!) // If an image URL is available, use it
                : _image != null
                    ? FileImage(_image!)
                        as ImageProvider // If the user selected an image
                    : AssetImage('assets/ami.jpg')
                        as ImageProvider, // Default image if no image is selected
            child: _image == null && _imageUrl == null
                ? Icon(Icons.camera_alt,
                    size: 40,
                    color: Colors.white) // Icon to prompt for image selection
                : null,
          ),
        ),
        SizedBox(height: 16),
        Text('Зураг оруулахын тулд дараарай'), // Instruction to select an image
      ],
    );
  }
}

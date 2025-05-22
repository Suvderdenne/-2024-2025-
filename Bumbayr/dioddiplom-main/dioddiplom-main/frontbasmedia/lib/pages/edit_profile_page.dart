import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _apiService = ApiService();
  String? _username;
  String? _email;
  dynamic _image;
  Uint8List? _imageBytes;
  String? _photoUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = await _apiService.getCurrentUsername();
    final email = await _apiService.getCurrentUserEmail();
    try {
      final userData = await _apiService.getCurrentUser();
      setState(() {
        _photoUrl = userData['photo'];
      });
    } catch (e) {
      print('Error loading user photo: $e');
    }
    setState(() {
      _username = username;
      _email = email;
    });
  }

  Future<void> _getImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        if (kIsWeb) {
          _loadImageBytes(pickedFile);
        }
      });
    }
  }

  Future<void> _loadImageBytes(XFile file) async {
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updateProfile(
        email: _email ?? '',
        username: _username,
        photo: _image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Профайл амжилттай шинэчлэгдлээ'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Профайл шинэчлэхэд алдаа гарлаа: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Профайл засах',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.blue),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _getImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _getBackgroundImage(),
                          backgroundColor: Colors.grey[800],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: _username,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Нэр',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _username = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: _email,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'И-мэйл',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                ],
              ),
            ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (_image != null) {
      if (kIsWeb) {
        if (_imageBytes != null) {
          return MemoryImage(_imageBytes!);
        }
        return null;
      } else {
        return FileImage(_image as File);
      }
    }
    if (_photoUrl != null) {
      return NetworkImage(_photoUrl!);
    }
    return null;
  }
}
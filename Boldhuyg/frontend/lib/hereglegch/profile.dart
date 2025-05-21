import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'profile_image_uploader.dart'; // Энэ файлаа заавал импортлоорой
import 'home_page.dart'; // Add this import

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  dynamic user;
  bool isLoading = true;
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _colorController;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _colorController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8000/api/user/profile/${widget.userId}/'));

      if (response.statusCode == 200) {
        user = jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        user = null;
        debugPrint('Failed to load profile data');
      }
    } catch (e) {
      user = null;
      debugPrint('Error loading profile: $e');
    }

    setState(() => isLoading = false);
  }

  String getValue(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') {
      return 'Байхгүй';
    }
    return value.toString();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Widget buildProfileCard(String title, String content, IconData icon) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.95).animate(_scaleController),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD1DC),
                  Color(0xFFFFB6C1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Color(0xFFFF69B4),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.comicNeue(
                            fontSize: 18,
                            color: Color(0xFFE75480),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          content,
                          style: GoogleFonts.comicNeue(
                            fontSize: 20,
                            color: Color(0xFFE75480),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF0F5),
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceController.value * 3),
              child: Text(
                'Миний Профайл',
                style: GoogleFonts.comicNeue(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.pink.withOpacity(0.3),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        backgroundColor: Color(0xFFFF69B4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Нүүр хуудас',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Гарах',
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateController.value * 0.1,
                        child: ProfileImageUploader(userId: widget.userId),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildProfileCard(
                    'Нэр',
                    getValue(user['username']),
                    Icons.person,
                  ),
                  buildProfileCard(
                    'И-мэйл',
                    getValue(user['email']),
                    Icons.email,
                  ),
                  buildProfileCard(
                    'Утасны дугаар',
                    getValue(user['phone']),
                    Icons.phone,
                  ),
                ],
              ),
            ),
    );
  }
}

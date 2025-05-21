import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapnvibefe/pages/first_page.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Lan extends StatefulWidget {
  const Lan({super.key});

  @override
  _LanState createState() => _LanState();
}

class _LanState extends State<Lan> with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    _initializeUserAndData(); // Moved this here for proper init
    _loadLanguage();
    _bgAnimation = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    super.dispose();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? lang = prefs.getString('language');

    if (lang != null && lang.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstPage()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirstPage()),
    );
  }

  Future<void> _initializeUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('user_id', userId);
    }

    await _registerUserOnServer(userId);
  }

  Future<void> _registerUserOnServer(String userId) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/user/"),
        // Uri.parse("http://192.168.4.245/user/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("User registered successfully.");
      } else {
        debugPrint("Failed to register user: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error registering user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(Colors.pink[100], Colors.purple[100],
                      _bgAnimation.value)!,
                  Color.lerp(Colors.orange[100], Colors.blue[100],
                      _bgAnimation.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _languageButton(
                              imagePath: 'assets/images/eng.png',
                              text: 'English',
                              onTap: () => _saveLanguage("eng"),
                            ),
                            const SizedBox(width: 20),
                            _languageButton(
                              imagePath: 'assets/images/mon.png',
                              text: 'Монгол',
                              onTap: () => _saveLanguage("mon"),
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

  Widget _languageButton({
    required String imagePath,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFe0166d), width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath,
                  width: 50.0,
                  height: 40.0,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFf88dbb),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

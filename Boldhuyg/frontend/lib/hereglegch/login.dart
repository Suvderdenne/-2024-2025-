import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/hereglegch/home_page.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String phone = '';
  String password = '';
  bool _isLoading = false;
  late AnimationController _bounceController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://127.0.0.1:8000/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = json.decode(response.body);
      debugPrint("Login response data: $data");

      if (response.statusCode == 200) {
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final user = data['user'];
        final userId = user?['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', accessToken);
        await prefs.setString('refresh', refreshToken);
        if (userId != null && userId is int) {
          await prefs.setInt('user_id', userId);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  "Амжилттай нэвтэрлээ!",
                  style: GoogleFonts.baloo2(fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.all(16),
          ),
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                        parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  data['error'] ?? 'Нэвтрэхэд алдаа гарлаа',
                  style: GoogleFonts.baloo2(fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      debugPrint("Login error: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Сүлжээний алдаа',
                style: GoogleFonts.baloo2(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE0F3), // Light pink
              Color(0xFFE8F5FF), // Light blue
              Color(0xFFF0E5FF), // Light purple
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Animated welcome character
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceController.value * 10),
                          child: Lottie.asset(
                            'assets/animations/aaa.json',
                            width: 200,
                            height: 200,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    // Welcome text with animation
                    TweenAnimationBuilder(
                      duration: Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Text(
                            "ТАВТАЙ МОРИЛ!",
                            style: GoogleFonts.baloo2(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[600],
                              shadows: [
                                Shadow(
                                  color: Colors.purple.withValues(alpha: 0.2),
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    // Phone number input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.baloo2(
                          fontSize: 18,
                          color: Colors.purple[700],
                        ),
                        decoration: InputDecoration(
                          labelText: "Утасны дугаар",
                          labelStyle: GoogleFonts.baloo2(
                            color: Colors.purple[600],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(Icons.phone_android,
                              color: Colors.purple[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.purple.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                        ),
                        onChanged: (val) => phone = val,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Утас оруулна уу'
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Password input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        obscureText: true,
                        style: GoogleFonts.baloo2(
                          fontSize: 18,
                          color: Colors.purple[700],
                        ),
                        decoration: InputDecoration(
                          labelText: "Нууц үг",
                          labelStyle: GoogleFonts.baloo2(
                            color: Colors.purple[600],
                            fontSize: 16,
                          ),
                          prefixIcon:
                              Icon(Icons.lock, color: Colors.purple[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.purple.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                        ),
                        onChanged: (val) => password = val,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Нууц үг оруулна уу'
                            : null,
                      ),
                    ),
                    SizedBox(height: 30),
                    // Login button with animation
                    _isLoading
                        ? Lottie.asset(
                            'assets/animations/stars.json',
                            width: 100,
                            height: 100,
                          )
                        : GestureDetector(
                            onTapDown: (_) => _scaleController.forward(),
                            onTapUp: (_) {
                              _scaleController.reverse();
                              login();
                            },
                            onTapCancel: () => _scaleController.reverse(),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 1, end: 0.95)
                                  .animate(_scaleController),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple[400]!,
                                      Colors.pink[300]!
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.purple.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Нэвтрэх",
                                  style: GoogleFonts.baloo2(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

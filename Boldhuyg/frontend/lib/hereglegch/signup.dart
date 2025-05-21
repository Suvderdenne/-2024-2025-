import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String email = '';
  String password = '';
  String phone = '';
  bool _isLoading = false;

  late AnimationController _rippleController;
  late AnimationController _bounceController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _rippleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
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
    _rippleController.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://127.0.0.1:8000/register/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Бүртгэл амжилттай!",
                    style: GoogleFonts.baloo2(fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: EdgeInsets.all(16),
            ),
          );
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LoginPage(),
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
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    data['error'] ?? 'Алдаа гарлаа',
                    style: GoogleFonts.baloo2(fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          CustomPaint(
              size: size, painter: RipplePainter(animation: _rippleController)),
          _buildSignupForm(context),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFE0F3), // Light pink
            Color(0xFFE8F5FF), // Light blue
            Color(0xFFF0E5FF), // Light purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
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
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  width: size.width < 600 ? double.infinity : 500,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Тавтай морил!",
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
                        const SizedBox(height: 30),
                        _buildInputField(
                          "Хэрэглэгчийн нэр",
                          Icons.person,
                          (val) => username = val,
                          (val) => val == null || val.isEmpty
                              ? 'Нэр оруулна уу'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          "И-мэйл",
                          Icons.email,
                          (val) => email = val,
                          (val) => val == null || val.isEmpty
                              ? 'Имэйл оруулна уу'
                              : null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          "Утасны дугаар",
                          Icons.phone_android,
                          (val) => phone = val,
                          (val) => val == null || val.isEmpty
                              ? 'Утасны дугаар оруулна уу'
                              : null,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          "Нууц үг",
                          Icons.lock,
                          (val) => password = val,
                          (val) => val == null || val.isEmpty
                              ? 'Нууц үг оруулна уу'
                              : null,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
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
                                  signup();
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
                                          color: Colors.purple
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "Бүртгүүлэх",
                                      style: GoogleFonts.baloo2(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        LoginPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.8, end: 1.0)
                                          .animate(
                                        CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutBack),
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: Text(
                            "Нэвтрэх",
                            style: GoogleFonts.baloo2(
                              fontSize: 18,
                              color: Colors.purple[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    void Function(String) onChanged,
    String? Function(String?) validator, {
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Container(
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
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: GoogleFonts.baloo2(
          fontSize: 18,
          color: Colors.purple[700],
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.baloo2(
            color: Colors.purple[600],
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: Colors.purple[400]),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.purple),
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Animation<double> animation;

  RipplePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.purple.withValues(alpha: 0.1);
    final center = Offset(size.width / 2, size.height / 2);
    final rippleRadius = 60 + sin(animation.value * 2 * pi) * 20;

    canvas.drawCircle(center, rippleRadius, paint);

    final bubblePaint = Paint()..color = Colors.pink.withValues(alpha: 0.2);
    for (int i = 0; i < 10; i++) {
      final dx = (size.width * 0.2) + sin(animation.value * 2 * pi + i) * 100;
      final dy = (size.height * 0.2) + cos(animation.value * 2 * pi + i) * 100;
      canvas.drawCircle(Offset(dx, dy), 10 + i.toDouble(), bubblePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

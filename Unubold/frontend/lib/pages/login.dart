import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'sign_up.dart';
import 'forget_password.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:8000/api/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access'];
        final refreshToken = data['refresh'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showErrorDialog(
          'Нэвтрэхэд алдаа гарлаа',
          'Таны оруулсан мэдээлэл буруу байна. Дахин оролдоно уу.',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
        'Холболтын алдаа',
        'Сервертэй холбогдож чадсангүй. Интернэт холболтоо шалгана уу.',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Ойлголоо'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/zs.jpg',
            ), // Background image of historical landmark
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(
                0,
                0,
                0,
                0.4,
              ), // Darkened overlay for better text readability
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and app name
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Түүхэн дурсгалт газар',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Монголын түүхийг нээж, танилцъя',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Form
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Нэвтрэх',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF36454F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Email field
                        const Text(
                          'Имэйл хаяг',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF36454F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'example@mail.com',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF607D8B),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Color(0xFF607D8B),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        // Password field
                        const Text(
                          'Нууц үг',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF36454F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: '•••••••',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF607D8B),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xFF607D8B),
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscureText = !_obscureText,
                                  ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Color(0xFF607D8B),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgetPassword(),
                                  ),
                                ),
                            style: TextButton.styleFrom(
                              foregroundColor: Color(0xFF607D8B),
                            ),
                            child: const Text(
                              'Нууц үгээ мартсан уу?',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _login(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF36454F),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                              elevation: 2,
                              shadowColor: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'НЭВТРЭХ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register link
                        Center(
                          child: GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUp(),
                                  ),
                                ),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Шинэ хэрэглэгч үү? ',
                                style: TextStyle(
                                  color: Color(0xFF36454F),
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Бүртгүүлэх',
                                    style: TextStyle(
                                      color: Color(0xFF607D8B),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer text
                  Text(
                    '© 2025 Түүхэн дурсгалт газар',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
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
}

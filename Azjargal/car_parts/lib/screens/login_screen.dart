import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'register_screen.dart';
import '../utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _obscurePassword = true;

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Хэрэглэгчийн нэр болон нууц үг оруулна уу';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        setState(() {
          _message = 'Амжилттай нэвтэрлээ!';
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        setState(() {
          _message = data['error'] ?? 'Нэвтрэх үйлдэл амжилтгүй';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Алдаа гарлаа: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset('assets/azaa.jpg', fit: BoxFit.cover),
          ),
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.6)),
          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    '',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0),
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    'Gmail',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(_usernameController, 'Email', Icons.email),
                  const SizedBox(height: 30),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  _buildPasswordField(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Нууц үг мартсан',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF89232),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_message.isNotEmpty)
                    Text(
                      _message,
                      style: TextStyle(
                        color: _message.contains('Амжилттай')
                            ? Colors.green[300]
                            : Colors.red[300],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white30)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Эсвэл',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white30)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 60,
                    child: OutlinedButton(
                      onPressed: _register,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Бүртгүүлэх',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData iconData,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(iconData, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Нууц үг',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.lock, color: Colors.white54),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: _togglePasswordVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

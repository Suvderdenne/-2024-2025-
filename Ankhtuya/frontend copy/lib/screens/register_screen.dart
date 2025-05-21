import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;
  bool obscurePassword = true;
  bool isEmailValid = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      final email = emailController.text.trim();
      setState(() {
        isEmailValid = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
        ).hasMatch(email);
      });
    });
  }

  Future<void> register() async {
    if (!isEmailValid) {
      Fluttertoast.showToast(msg: 'Зөв имэйл хаяг оруулна уу');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(msg: 'Нууц үг таарахгүй байна');
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'password2': confirmPasswordController.text,
      }),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Fluttertoast.showToast(msg: 'Амжилттай бүртгэгдлээ');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Fluttertoast.showToast(msg: 'Бүртгэхэд алдаа гарлаа');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: 280,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/plant_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Wavy white container
          Container(
            margin: const EdgeInsets.only(top: 220),
            child: ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Бүртгүүлэх',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Таны шинэ аккаунтыг үүсгээрэй',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      _buildInputField(
                        controller: usernameController,
                        icon: Icons.person,
                        hintText: 'Нэр',
                      ),
                      _buildInputField(
                        controller: emailController,
                        icon: Icons.email,
                        hintText: 'Имэйл хаяг',
                        suffixIcon: emailController.text.isEmpty
                            ? null
                            : isEmailValid
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                      ),
                      _buildInputField(
                        controller: passwordController,
                        icon: Icons.lock,
                        hintText: 'Нууц үг',
                        obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      _buildInputField(
                        controller: confirmPasswordController,
                        icon: Icons.lock_outline,
                        hintText: 'Нууц үгээ баталгаажуулах',
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Бүртгүүлэх',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Аккаунттай юу? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              "Нэвтрэх",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          hintText: hintText,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// 🌊 Wavy clipper for top of form
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width * 0.25, -20, size.width * 0.5, 10);
    path.quadraticBezierTo(size.width * 0.75, 40, size.width, 10);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

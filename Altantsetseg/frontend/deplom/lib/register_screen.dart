import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> registerUser() async {
  final url = Uri.parse('http://127.0.0.1:8000/api/register/');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': _usernameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'password': _passwordController.text,
    }),
  );

  if (response.statusCode == 201) {
    // 🎉 Successfully registered
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Амжилттай бүртгэгдлээ')),
    );
    Navigator.pushReplacementNamed(context, '/login');
  } else {
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Алдаа: ${data.toString()}')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFFFFF)], // 🟡 Шаргал → Цагаан
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ✅ Анимэйшн
                  SizedBox(
                    height: 180,
                    child: Lottie.asset(
                      'assets/animation/zibleed.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Бүртгүүлэх',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField(_usernameController, 'Хэрэглэгчийн нэр'),
                  const SizedBox(height: 12),

                  _buildTextField(_emailController, 'Имэйл', isEmail: true),
                  const SizedBox(height: 12),

                  _buildTextField(_phoneController, 'Утасны дугаар', keyboard: TextInputType.phone),
                  const SizedBox(height: 12),

                  _buildTextField(_passwordController, 'Нууц үг', isPassword: true),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      
                      if (_formKey.currentState!.validate()) {
                         registerUser();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Амжилттай бүртгэгдлээ')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Бүртгүүлэх'),
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Нэвтрэх хуудас руу очих',
                      style: TextStyle(color: Colors.brown),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isEmail = false,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboard ?? (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label шаардлагатай';
        if (isPassword && value.length < 6) return 'Хамгийн багадаа 6 тэмдэгт байх ёстой';
        return null;
      },
    );
  }
}

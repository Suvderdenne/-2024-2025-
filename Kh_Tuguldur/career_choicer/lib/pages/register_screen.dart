import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const royalBlue = Color(0xFF4169E1);
const accentBlue = Color(0xFF5C8DFF);

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String message = "";
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() => message = "All fields are required");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() => message = "Passwords do not match");
      return;
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text,
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => message = "Registration Successful!");
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, "/login");
        });
      } else {
        setState(() => message = "Registration Failed: ${jsonDecode(response.body)['error']}");
      }
    } catch (e) {
      setState(() => message = "Connection error");
    } finally {
      setState(() => isLoading = false);
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
            colors: [royalBlue, Color(0xFF2A4E9E)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 50),
                child: Opacity(
                  opacity: _animation.value,
                  child: child,
                ),
              );
            },
            child: _buildRegisterCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'logo',
              child: CircleAvatar(
                radius: 50,
                backgroundColor: royalBlue,
                child: FlutterLogo(size: 40, textColor: Colors.white),
              ),
            ),
            SizedBox(height: 30),
            Text("Бүртгэл үүсгэх",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 25),
            _buildInputField(
              controller: usernameController,
              icon: Icons.person_outline,
              hint: "Username",
            ),
            SizedBox(height: 20),
            _buildInputField(
              controller: emailController,
              icon: Icons.email_outlined,
              hint: "Email",
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            _buildInputField(
              controller: passwordController,
              icon: Icons.lock_outline,
              hint: "Password",
              isPassword: true,
              isVisible: isPasswordVisible,
              onVisibilityChanged: () => setState(() => isPasswordVisible = !isPasswordVisible),
            ),
            SizedBox(height: 20),
            _buildInputField(
              controller: confirmPasswordController,
              icon: Icons.lock_reset,
              hint: "Confirm Password",
              isPassword: true,
              isVisible: isConfirmPasswordVisible,
              onVisibilityChanged: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
            ),
            SizedBox(height: 25),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: isLoading
                  ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(royalBlue))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      onPressed: register,
                      child: Text("Бүртгүүлэх",
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1.2,
                              color: Colors.white)),
                    ),
            ),
            SizedBox(height: 15),
            Text(message,
                style: TextStyle(
                    color: message.contains("Successful") ? Colors.green : Colors.red)),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/login"),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: royalBlue),
                  children: [
                    TextSpan(text: "Already have an account? "),
                    TextSpan(
                      text: "Login now",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool isVisible = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onVisibilityChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[100],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: royalBlue),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: royalBlue,
                  ),
                  onPressed: onVisibilityChanged,
                )
              : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
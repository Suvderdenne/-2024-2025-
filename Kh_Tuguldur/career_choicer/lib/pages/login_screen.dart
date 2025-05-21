import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const royalBlue = Color(0xFF4169E1);
const accentBlue = Color(0xFF5C8DFF);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String message = "";
  bool isLoading = false;
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

  Future<void> login() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String token = data['access'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setState(() => message = "Invalid credentials");
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
            child: _buildLoginCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
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
          Text("Тавтай морил",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(height: 25),
          _buildInputField(
            controller: usernameController,
            icon: Icons.person,
            hint: "Username",
          ),
          SizedBox(height: 20),
          _buildInputField(
            controller: passwordController,
            icon: Icons.lock,
            hint: "Password",
            isPassword: true,
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
                    onPressed: login,
                    child: Text("Нэвтэрэх",
                        style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.2,
                            color: Colors.white)),
                  ),
          ),
          SizedBox(height: 15),
          Text(message,
              style: TextStyle(
                  color: message.contains("Invalid") ? Colors.red : Colors.green)),
          SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/register"),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: royalBlue),
                children: [
                  TextSpan(text: "New user? "),
                  TextSpan(
                    text: "Create account",
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
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[100],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: royalBlue),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
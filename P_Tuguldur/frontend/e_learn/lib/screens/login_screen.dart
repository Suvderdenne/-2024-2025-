import 'package:e_learn/tools/bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // Import the Lottie package
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // Animation variables
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start the animation when the widget is built
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    // Basic validation
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/login/'), // Make sure this URL is correct
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      final data = json.decode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        // Save the token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        // Assuming your backend returns 'access' for the token
        await prefs.setString('token', data['access']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        // Navigate to the BottomNavScreen and replace the current screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavScreen(token: data['access'])),
        );
      } else {
        // Handle specific backend errors if available, otherwise show generic message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Login failed. Please check your credentials.')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      // Handle network or other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define soft green colors
    const Color primaryGreen = Color(0xFF8BC34A); // A pleasant soft green

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back!', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        elevation: 0, // Remove shadow
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( // Allow scrolling if content overflows
          padding: const EdgeInsets.all(24.0),
          child: SlideTransition( // Apply slide animation
            position: _slideAnimation,
            child: FadeTransition( // Apply fade animation
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch elements horizontally
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    'images/study.json', // Path to your Lottie JSON file
                    height: 180, // Adjust the height as needed
                    width: 180, // Adjust the width as needed
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Login to your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Username Field
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, color: primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none, // No border line initially
                      ),
                      filled: true,
                      fillColor: Colors.grey[200], // Soft grey fill
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      // Add a suffix icon for password visibility toggle if desired
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  isLoading
                      ? Center(child: CircularProgressIndicator(color: primaryGreen))
                      : ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen, // Button color
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 5, // Add a subtle shadow
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Register Text Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: primaryGreen, // Text color
                    ),
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(fontSize: 16),
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
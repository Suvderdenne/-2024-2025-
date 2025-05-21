import 'package:career_choicer/Tools/main_tab.dart';
import 'package:flutter/material.dart';
// Remove SharedPreferences import here if checkLoginStatus moves to SplashScreen
import 'pages/login_screen.dart';
import 'pages/register_screen.dart';
import 'pages/splash_screen.dart'; // Make sure this import points to your SplashScreen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Optional: You can keep checkLoginStatus here if SplashScreen imports main.dart
  // or move this logic entirely into SplashScreen or an AuthService.
  // Future<bool> checkLoginStatus() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("token") != null;
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Career Guide",
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // <-- Correct: Always start with SplashScreen on cold boot
      // home: SplashScreen(), // home is ignored when initialRoute is set, can be removed or kept as fallback
      routes: {
        "/splash": (context) => SplashScreen(), // SplashScreen will handle navigation
        "/login": (context) => LoginScreen(),
        "/home": (context) => MainTab(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
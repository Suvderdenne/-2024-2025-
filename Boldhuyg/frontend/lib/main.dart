import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hereglegch/dashboard.dart';
import 'hereglegch/home_page.dart';

void main() {
  runApp(SuraltsApp());
}

class SuraltsApp extends StatelessWidget {
  const SuraltsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Суралц Апп',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ComicNeue',
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return HomePage(); // Хэрвээ токен байгаа бол шууд HomePage руу
          } else {
            return KidsDashboard(); // Токен байхгүй бол Login/Signup dashboard руу
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }
}

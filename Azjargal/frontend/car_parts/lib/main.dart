import 'package:car_parts/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'screens/detail_page.dart';
import 'package:car_parts/screens/detail_page.dart';
import 'utils/api_service.dart';

void main() {
  runApp(const AutoPartsApp());
}

class AutoPartsApp extends StatelessWidget {
  const AutoPartsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Авто Сэлбэгийн Худалдаа',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: ApiService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If logged in, go to HomePage, otherwise LoginScreen
          final bool isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? CarPartsApp() : LoginPage();
        },
      ),
    );
  }
}

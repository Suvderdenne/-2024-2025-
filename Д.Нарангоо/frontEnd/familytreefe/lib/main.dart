import 'package:flutter/material.dart';
import 'login.dart';
import 'api/api_service.dart';
import 'home_screen.dart';
import 'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          authService.isLoggedIn()
              ? HomeScreen(authService: authService)
              : LoginScreen(authService: authService),
      routes: {
        '/login': (context) => LoginScreen(authService: authService),
        '/home': (context) => HomeScreen(authService: authService),
        '/register': (context) => RegisterScreen(authService: authService),
      },
    );
  }
}

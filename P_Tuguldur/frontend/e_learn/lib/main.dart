import 'package:e_learn/screens/login_screen.dart';
import 'package:e_learn/screens/register_screen.dart';
import 'package:e_learn/screens/home_screen.dart';
import 'package:e_learn/screens/lesson_screen.dart';
import 'package:e_learn/screens/progress_screen.dart';
import 'package:e_learn/screens/profile_screen.dart';
import 'package:e_learn/screens/test_screen.dart'; // Import TestScreen
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? globalToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  globalToken = await preloadToken();
  final initialRoute = globalToken != null ? '/home' : '/login';
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String?> preloadToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        if (settings.name == '/lessons') {
          return MaterialPageRoute(
            builder: (_) => LessonScreen(token: globalToken ?? ''),
          );
        } else if (settings.name == '/quiz') {
          return MaterialPageRoute(
            builder: (_) => TestScreen(token: globalToken ?? ''), // Handle /quiz route
          );
        }
        return null;
      },
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/progress': (context) => ProgressScreen(token: globalToken ?? ''),
        '/profile': (context) => ProfileScreen(token: globalToken ?? ''),
      },
    );
  }
}

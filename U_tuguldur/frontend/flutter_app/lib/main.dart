import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/language_screen.dart';
import 'screens/level_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/game_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Search Journey',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF6A11CB),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/language': (context) => const LanguageScreen(),
        '/level': (context) => const LevelScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/game': (context) => const GameScreen(),
      },
      onGenerateRoute: (settings) {
        // Check authentication for protected routes
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isAuthenticated &&
            settings.name != '/login' &&
            settings.name != '/register') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return null;
      },
    );
  }
}
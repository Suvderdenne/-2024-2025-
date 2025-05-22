import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/card_game_page.dart';
import 'pages/sequence_memory_page.dart';
import 'pages/chimp_test_page.dart';

void main() {
  runApp(const MemoryGamesApp());
}

class MemoryGamesApp extends StatelessWidget {
  const MemoryGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white70,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateToGame(BuildContext context, String game) {
    switch (game) {
      case 'Хөзрийн тоглоом':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CardGamePage()),
        );
        break;
      case 'Байрлалын ангууч':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SequenceMemoryPage()),
        );
        break;
      case 'Дарааллын санах ой':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChimpTestPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$game тоглоомыг тун удахгүй нээх болно!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF2196F3),
              Color(0xFF4CAF50),
              Color(0xFFFF9800),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'memorygames',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: screenSize.width * 0.08,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MenuPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1D1E33),
              Color(0xFF2D2E42),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.02),
                  _buildGameCard(
                    context,
                    Icons.style,
                    'Хөзрийн тоглоом',
                    'Хөзөр дээр дарж хос хосоор нь нийлүүлээрэй',
                    const Color(0xFF4CAF50),
                    () => _navigateToGame(context, 'Хөзрийн тоглоом'),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildGameCard(
                    context,
                    Icons.visibility_rounded,
                    'Байрлалын ангууч',
                    'Зургуудыг цээжлээд дарааллыг нь санаарай',
                    const Color(0xFF2196F3),
                    () => _navigateToGame(context, 'Байрлалын ангууч'),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildGameCard(
                    context,
                    Icons.psychology_rounded,
                    'Дарааллын санах ой',
                    'Тоонуудыг дарааллаар нь санаарай',
                    const Color(0xFFFF9800),
                    () => _navigateToGame(context, 'Дарааллын санах ой'),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.12;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 600,
            minHeight: screenSize.height * 0.15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: color,
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.05,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    color: Colors.white70,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';

void main() {
  runApp(SuraltsApp());
}

class SuraltsApp extends StatelessWidget {
  const SuraltsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Суралц Апп',
      theme: ThemeData(fontFamily: 'ComicNeue'),
      home: KidsDashboard(),
    );
  }
}

class KidsDashboard extends StatefulWidget {
  const KidsDashboard({super.key});

  @override
  KidsDashboardState createState() => KidsDashboardState();
}

class KidsDashboardState extends State<KidsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<Offset> _loginOffsetAnimation;
  late Animation<Offset> _signupOffsetAnimation;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _loginOffsetAnimation =
        Tween<Offset>(begin: Offset(-1.5, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _signupOffsetAnimation =
        Tween<Offset>(begin: Offset(1.5, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _floatController =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat(reverse: true);

    _buttonController.forward();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink.shade200,
                  Colors.lightBlue.shade200,
                  Colors.yellow.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 2. Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bbb.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // 3. Glassmorphism card
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                double floatValue =
                    (screenHeight * 0.06) * _floatController.value;
                return Transform.translate(
                  offset: Offset(0, -floatValue),
                  child: child,
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: screenWidth * 0.85,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.04,
                        horizontal: screenWidth * 0.05,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SlideTransition(
                                position: _loginOffsetAnimation,
                                child: _buildRoundedButton(
                                  context: context,
                                  text: 'Нэвтрэх',
                                  color: Colors.orangeAccent
                                      .withValues(alpha: 0.95),
                                  icon: Icons.login_rounded,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                    );
                                  },
                                ),
                              ),
                              SlideTransition(
                                position: _signupOffsetAnimation,
                                child: _buildRoundedButton(
                                  context: context,
                                  text: 'Бүртгүүлэх',
                                  color: Colors.greenAccent.shade400
                                      .withValues(alpha: 0.95),
                                  icon: Icons.person_add_alt_1_rounded,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignupPage()),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. App name and icon
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                children: [
                  Icon(
                    Icons.child_care,
                    size: screenWidth * 0.1,
                    color: Colors.white,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Суралц Апп",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedButton({
    required BuildContext context,
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double buttonSize = screenWidth * 0.3;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: screenWidth * 0.08,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                text,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

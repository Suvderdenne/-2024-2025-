import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapnvibefe/pages/colorwar.dart';
import 'package:yapnvibefe/pages/second_page.dart';
import 'package:yapnvibefe/pages/spy.dart';
import 'package:yapnvibefe/pages/feedback.dart'; // Make sure this exists

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with TickerProviderStateMixin {
  bool _showButtons = false;
  String _language = "eng";
  late AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _startAnimation();
    _bgAnimation = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    super.dispose();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? "eng";
    });
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showButtons = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AnimatedBuilder(
          animation: _bgAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(Colors.pink[100], Colors.purple[100],
                        _bgAnimation.value)!,
                    Color.lerp(Colors.orange[100], Colors.blue[100],
                        _bgAnimation.value)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: AnimatedOpacity(
                      opacity: _showButtons ? 1.0 : 0.0,
                      duration: const Duration(seconds: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildGameButton(
                            title: _language == "eng"
                                ? '🎤 Q/A'
                                : '🎤 Асуулт/Хариулт',
                            icon: Icons.question_answer,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SecondPage()),
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildGameButton(
                            title:
                                _language == "eng" ? '🕵️ SPY' : '🕵️ Тагнуул',
                            icon: Icons.visibility,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Spy()),
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildGameButton(
                            title: _language == "eng"
                                ? '💣 Pop'
                                : '💣 Тэсрэх бөмбөг',
                            icon: Icons.bubble_chart,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Feedback icon in top right corner
                  Positioned(
                    top: 50,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.feedback,
                          color: Colors.pink, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FeedbackPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pinkAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.pink),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf88dbb),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

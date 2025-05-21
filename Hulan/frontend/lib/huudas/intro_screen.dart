import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _pageTimer;

  @override
  void initState() {
    super.initState();

    _pageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageTimer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
    required String imagePath,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(color: const Color.fromRGBO(0, 0, 0, 0.6)),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 60, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPage(
                icon: Icons.shopping_bag_outlined,
                title: "Тавтай морил!",
                description: "Манай платформоор хамгийн загварлаг бүтээгдэхүүнүүдийг захиалаарай.",
                imagePath: "assets/images/bbb1.jpg",
              ),
              _buildPage(
                icon: Icons.star_outline,
                title: "Онцлох сонголт",
                description: "Шилдэг борлуулалттай, онцгой хямдралтай бараанууд таныг хүлээж байна.",
                imagePath: "assets/images/bbb3.jpg",
              ),
              _buildPage(
                icon: Icons.lock_outline,
                title: "Аюулгүй төлбөр",
                description: "Төлбөрийн найдвартай систем болон хэрэглэгчийн мэдээлэл хамгаалагдсан.",
                imagePath: "assets/images/bbb4.jpg",
              ),
            ],
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                _pageTimer.cancel();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              child: const Text(
                "Алгасах",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

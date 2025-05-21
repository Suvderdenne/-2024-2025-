import 'package:flutter/material.dart';
import 'package:career_choicer/pages/home_screen.dart';
import 'package:career_choicer/pages/jobs_screen.dart';
import 'package:career_choicer/pages/university_screen.dart';
import 'package:career_choicer/pages/post_screen.dart'; // Import PostScreen

const royalBlue = Color(0xFF4169E1);
const lavender = Color(0xFF6A5ACD);
const darkGray = Color(0xFF374151);
const softBlue = Color(0xFF1E40AF);

class MainTab extends StatefulWidget {
  final int initialIndex;

  const MainTab({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  final List<Widget> _screens = [
    HomeScreen(),
    UniversityScreen(),
    CareerScreen(),
    PostScreen(), // Add PostScreen
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _animationControllers = List.generate(
      _screens.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      ),
    );

    _animations = _animationControllers.map(
      (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      ),
    ).toList();

    // Start animation for initial index
    _animationControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateToScreen(int index) {
    if (index == _currentIndex) return;

    _animationControllers[_currentIndex].reverse();
    _animationControllers[index].forward();

    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index); // Instantly navigate without animation
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    _animationControllers[_currentIndex].reverse();
    _animationControllers[index].forward();

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            physics: BouncingScrollPhysics(),
            children: _screens,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildAnimatedNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width * 0.95, // Make it wider
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkGray.withOpacity(0.95), softBlue.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
        borderRadius: BorderRadius.all(Radius.circular(50)), // Slightly smaller rounding
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Reduce side padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem(Icons.home, 'Нүүр', 0)),
            Expanded(child: _buildNavItem(Icons.school, 'Их сургууль', 1)),
            Expanded(child: _buildNavItem(Icons.work, 'Мэргэжилүүд', 2)),
            Expanded(child: _buildNavItem(Icons.post_add, 'Пост', 3)), // Add Post tab
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = index == _currentIndex;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _animations[index],
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white24 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 28,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/pages/login.dart';
 // Import the Login page

// Main Introduction Screen that manages the page views
class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for the introduction screens
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              IntroPage(
                title: "Discover Amsazing Places",
                description: "Find new and exciting destinations all around the world with our curated travel guides.",
                imagePath: "assets/tata.png",
                pageIndex: 0,
                currentPage: _currentPage,
              ),
              IntroPage(
                title: "Plan Your Perfect Trip",
                description: "Create customized itineraries, book accommodations, and find the best local experiences.",
                imagePath: "assets/q.png",
                pageIndex: 1,
                currentPage: _currentPage,
              ),
              IntroPage(
                title: "Let's Discover World",
                description: "Planning trips made easy! Just a small effort helps you enjoy your holiday time while getting your own.",
                imagePath: "assets/erere.png",
                pageIndex: 2,
                currentPage: _currentPage,
                isLastPage: true,
                onGetStarted: () {
                  // Navigate to login page using the same method as the original code
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
          
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: _currentPage < 2 ? TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ) : const SizedBox.shrink(),
          ),
          
          // Next and Previous buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _currentPage < 2 ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous button (only if not on first page)
                _currentPage > 0
                    ? IconButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF2196F3),
                        ),
                      )
                    : const SizedBox(width: 48), // Placeholder for spacing
                
                // Page indicators
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF2196F3)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(
                            _currentPage == index ? 4 : 4),
                      ),
                    ),
                  ),
                ),
                
                // Next button
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Individual introduction page
class IntroPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final int pageIndex;
  final int currentPage;
  final bool isLastPage;
  final VoidCallback? onGetStarted;

  const IntroPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.pageIndex,
    required this.currentPage,
    this.isLastPage = false,
    this.onGetStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2196F3), // Blue at top
            Colors.white, // White at bottom
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sun
                Positioned(
                  top: 50,
                  right: 30,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFAB40),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Clouds
                Positioned(
                  top: 70,
                  left: 40,
                  child: _buildCloud(80, 40),
                ),
                Positioned(
                  top: 50,
                  right: 120,
                  child: _buildCloud(100, 50),
                ),
                Positioned(
                  top: 120,
                  left: 140,
                  child: _buildCloud(120, 60),
                ),
                
                // Wave shape
                Positioned(
                  bottom: 150,
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // Character image
                Positioned(
                  bottom: 250,
                  child: Image.asset(
                    imagePath,
                    height: 200,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom content area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5), // Indigo color
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Show page indicator only on the last page
                isLastPage ? _buildPageIndicator(pageIndex) : const SizedBox.shrink(),
                
                const SizedBox(height: 40),
                
                // Get Started button only on the last page
                isLastPage
                    ? SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onGetStarted, // This will now correctly use the Navigator.pushReplacement
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  Widget _buildPageIndicator(int activePage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: activePage == 0 ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            shape: activePage == 0 ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: activePage == 0 ? BorderRadius.circular(4) : null,
            color: activePage == 0 ? const Color(0xFF2196F3) : Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: activePage == 1 ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            shape: activePage == 1 ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: activePage == 1 ? BorderRadius.circular(4) : null,
            color: activePage == 1 ? const Color(0xFF2196F3) : Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: activePage == 2 ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            shape: activePage == 2 ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: activePage == 2 ? BorderRadius.circular(4) : null,
            color: activePage == 2 ? const Color(0xFF2196F3) : Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}

// Custom clipper for the wave shape
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    
    var firstControlPoint = Offset(size.width * 0.75, size.height * 0.3);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(
      firstControlPoint.dx, 
      firstControlPoint.dy, 
      firstEndPoint.dx, 
      firstEndPoint.dy
    );
    
    var secondControlPoint = Offset(size.width * 0.25, size.height * 0.5);
    var secondEndPoint = Offset(0, 0);
    path.quadraticBezierTo(
      secondControlPoint.dx, 
      secondControlPoint.dy, 
      secondEndPoint.dx, 
      secondEndPoint.dy
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
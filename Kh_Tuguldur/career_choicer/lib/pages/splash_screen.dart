import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Add this import

const royalBlue = Color(0xFF4169E1);

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<String> introTexts = [
    "Таны сонирхолд тохирсон мэргэжлийг олоорой",
    "Ирээдүйгээ төлөвлөж, зөв замыг сонгоорой",
    "Манай Mirrai танд туслахад бэлэн!"
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    // Consider if 60 seconds is the desired duration.
    // It might be better to navigate after a shorter time,
    // or perhaps after the user views the last page.
    _timer = Timer(Duration(seconds: 60), _navigate);
  }

  // --- MODIFIED: Check login status before navigating ---
  void _navigate() async {
    // Cancel the timer if it's still active (e.g., if called by _skip)
    _timer?.cancel();

    if (!mounted) return; // Check if the widget is still in the tree

    // Check login status
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getString("token") != null;

    if (mounted) { // Double-check mounted after async operation
      if (isLoggedIn) {
        // User is logged in, go to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User is not logged in, go to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
  // --- END MODIFICATION ---

  void _skip() {
    // _navigate() already cancels the timer, so just call it.
    _navigate(); // Navigate immediately, checking login status
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Ensure timer is cancelled when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: royalBlue,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: introTexts.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              // Optional: You could reset or cancel the timer here if needed,
              // or start a shorter timer only when the last page is reached.
            },
            itemBuilder: (context, index) {
              return _buildPage(introTexts[index]);
            },
          ),
          Positioned(
            top: 50, // Adjust based on safe area if needed
            right: 20,
            child: TextButton(
              onPressed: _skip, // Calls the updated _navigate
              child: Text("Skip", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                introTexts.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Optional: Add a "Next" or "Get Started" button on the last page
          if (_currentPage == introTexts.length - 1)
             Positioned(
               bottom: 60, // Adjust position as needed
               right: 20,
               child: ElevatedButton(
                 onPressed: _navigate, // Navigate when pressed
                 child: Text("Get Started"),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.white, // Button background color
                   foregroundColor: royalBlue, // Text color
                 ),
               ),
             )
        ],
      ),
    );
  }

  Widget _buildPage(String text) {
    // Ensure your Lottie file path is correct and the file is included in pubspec.yaml assets
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150, // Increased size slightly
            width: 150,  // Increased size slightly
            child: ClipOval(
              child: Lottie.asset(
                'images/student.json', // Make sure this path is correct (e.g., assets/student.json)
                fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) {
                   // Show an error message or placeholder if Lottie fails
                   print("Error loading Lottie: $error");
                   return Icon(Icons.error_outline, color: Colors.red, size: 50);
                 },
              ),
            ),
          ),
          SizedBox(height: 40), // Increased spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0), // Increased padding
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20, // Adjusted font size
                color: Colors.white,
                fontWeight: FontWeight.w500, // Slightly less bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:e_learn/screens/home_screen.dart';
import 'package:e_learn/screens/lesson_screen.dart';
import 'package:e_learn/screens/new_word_screen.dart';
import 'package:e_learn/screens/progress_screen.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  final String token;

  const BottomNavScreen({super.key, required this.token});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Define the screens that correspond to each tab
    // Note: It's generally better practice to initialize this list outside the build method
    // if the screens themselves don't depend on build context variables that change frequently.
    // However, passing the token requires it here or managing state differently.
    final List<Widget> screens = [
      const HomeScreen(), // Screen for the 'Home' tab
      LessonScreen(token: widget.token), // Screen for the 'Lessons' tab, requires token
      NewWordScreen(token: widget.token), // Screen for the 'New Words' tab, requires token
      ProgressScreen(token: widget.token), // Screen for the 'Progress' tab, requires token
    ];

    return Scaffold(
      // Display the currently selected screen
      body: screens[_selectedIndex],
      // Configure the bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlights the current tab
        onTap: (int index) {
          // Update the state when a tab is tapped
          setState(() {
            _selectedIndex = index;
          });
        },
        // *** Style Updates ***
        backgroundColor: Colors.white, // Set background color to white
        selectedItemColor: const Color(0xFF8BC34A), // Set selected item color to the specified green
        unselectedItemColor: Colors.grey, // Keep unselected item color as grey
        // It's often good practice to set the type when you have more than 3 items
        // or want labels to always show. fixed ensures labels are always visible.
        type: BottomNavigationBarType.fixed,
        // Define the items (tabs) in the navigation bar
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Lessons'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'New Words'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
        ],
      ),
    );
  }
}

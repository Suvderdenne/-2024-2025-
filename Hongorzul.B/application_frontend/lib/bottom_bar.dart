import 'package:flutter/material.dart';
import 'service.dart';
import 'profile.dart';
import 'booking.dart';
import 'worker.dart';
import 'location.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart'; // Import LoginPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salon App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _bottomNavIndex = 0;

  final iconList = <IconData>[
    Icons.home,
    Icons.face,
    Icons.location_on,
    Icons.account_circle,
  ];

  final List<Widget> _pages = [
    ServicePage(),
    WorkerPage(),
    LocationPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  // Check if the user is logged in by looking for the access token
  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  void _onTabTapped(int index) async {
    if (index == 3) {
      // If the Profile page is tapped, check if the user is logged in
      bool loggedIn = await _isLoggedIn();
      if (!loggedIn) {
        // If not logged in, redirect to LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Otherwise, navigate to ProfilePage
        setState(() {
          _bottomNavIndex = index;
        });
      }
    } else {
      // For other tabs, just update the bottom nav index
      setState(() {
        _bottomNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_bottomNavIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingPage()),
          );
        },
        child: Icon(Icons.calendar_month, color: Colors.white),
        backgroundColor: Color(0xFF872BC0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Color(0xFF872BC0) : Colors.white;
          return Icon(iconList[index], size: 24, color: color);
        },
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        backgroundColor: Color(0xFFDAAFFF),
        onTap: _onTabTapped,
      ),
    );
  }
}

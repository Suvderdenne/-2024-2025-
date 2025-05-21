import 'package:flutter/material.dart';
import 'package:frontend/screens/OnboardingScreen.dart';
import 'package:frontend/screens/ToolkitSection.dart';
import 'package:frontend/screens/findplants.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/plant_detail.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/my_plants_screen.dart';
import 'package:frontend/screens/add_plant_screen.dart';
import 'package:frontend/widgets/animated_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  List<String> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  List<Widget> _getScreens() {
    List<Widget> screens = [
      HomePage(),
      FindPlantsPage(),
      if (_isLoggedIn) AddPlantPage(),
      if (_isLoggedIn) MyPlantsScreen(),
      ToolkitSection(),
      if (!_isLoggedIn) LoginScreen(),
      if (!_isLoggedIn) RegisterScreen(),
      if (_isLoggedIn) const SizedBox(), // Placeholder for Logout
    ];

    _tabKeys = [
      'home',
      'search',
      if (_isLoggedIn) 'add',
      if (_isLoggedIn) 'myplants',
      'toolkit',
      if (!_isLoggedIn) 'login',
      if (!_isLoggedIn) 'register',
      if (_isLoggedIn) 'logout',
    ];

    return screens;
  }

  Future<void> _handleTabChange(int index) async {
    final selectedTab = _tabKeys[index];

    if (selectedTab == 'logout') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access');
      await prefs.remove('refresh');

      setState(() {
        _isLoggedIn = false;
        _currentIndex = 0;
      });

      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      return;
    }

    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();

    return MaterialApp(
      title: 'Plantanhaa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Gilroy'),
      home: Scaffold(
        body: screens[_currentIndex],
        bottomNavigationBar: AnimatedNavbar(
          selectedIndex: _currentIndex,
          onTabChange: _handleTabChange,
          isLoggedIn: _isLoggedIn,
        ),
      ),
      routes: {
        '/register': (context) => RegisterScreen(),
        // '/': (context) => const OnboardScreen(),
        '/login': (context) => LoginScreen(),
        '/plant_detail': (context) => PlantDetailScreen(),
        '/home': (context) => const MyApp(),
      },
    );
  }
}

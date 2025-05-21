import 'package:familytreefe/profile.dart';
import 'package:flutter/material.dart';
import 'family_tree_screen.dart';
import 'api/api_service.dart';
import 'clan_members_screen.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _motionTabBarController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _selectedIndex == 1
              ? FamilyTreeScreen(authService: widget.authService)
              : (_selectedIndex == 2
                  ? ProfileScreen(
                    authService: widget.authService,
                    uid: widget.authService.userInfo?['uid'] ?? '',
                  )
                  : ClanMembersScreen(authService: widget.authService)),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "Овгийн гишүүд",
        labels: const ["Овгийн гишүүд", "Ургийн мод", "Профайл"],
        icons: const [Icons.family_restroom, Icons.account_tree, Icons.person],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: Colors.black,
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: Colors.green,
        tabIconSelectedColor: Colors.white,
        tabBarColor: Colors.grey[300],
        onTabItemSelected: (int value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AnimatedNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;
  final bool isLoggedIn;

  const AnimatedNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: GNav(
          rippleColor: Colors.green.shade100,
          hoverColor: Colors.green.shade100,
          gap: 6,
          activeColor: Colors.green,
          iconSize: 26,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.green.shade50,
          color: Colors.black,
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
          tabs: [
            const GButton(icon: Icons.home),
            const GButton(icon: Icons.search),
            if (isLoggedIn) const GButton(icon: Icons.add),
            if (isLoggedIn)
              const GButton(icon: Icons.local_florist),
            const GButton(icon: Icons.handyman),
            if (!isLoggedIn) const GButton(icon: Icons.login),
            if (isLoggedIn) const GButton(icon: Icons.logout),
          ],
        ),
      ),
    );
  }
}

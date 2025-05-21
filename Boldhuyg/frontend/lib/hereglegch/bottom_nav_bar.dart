import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'tsetserleg/duu.dart'; // Дуу
import 'profile.dart'; // Профайл
import 'tsetserleg/ulger.dart'; // FairyTalePage (Үлгэр хуудас)
import 'shared_preferences_helper.dart'; // Utility file for managing SharedPreferences

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar(
      {super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      height: 60,
      backgroundColor: Colors.deepPurple[600],
      items: [
        TabItem(icon: Icons.home, title: 'Нүүр'),
        TabItem(icon: Icons.music_note, title: 'Дуу'),
        TabItem(icon: Icons.book, title: 'Үлгэр'),
        TabItem(icon: Icons.person, title: 'Профайл'),
      ],
      initialActiveIndex: selectedIndex,
      onTap: (index) {
        onTap(index);
        _handleTap(context, index);
      },
      style: TabStyle.react,
    );
  }

  void _handleTap(BuildContext context, int index) async {
    if (!context.mounted) return;

    if (index == 1) {
      // Дуу tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicPage()),
      ).then((_) {
        if (context.mounted) {
          onTap(0);
        }
      });
    } else if (index == 2) {
      // Үлгэр tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FairyTalePage(subjectId: 8)),
      ).then((_) {
        if (context.mounted) {
          onTap(0);
        }
      });
    } else if (index == 3) {
      // Профайл tab
      int userId = await SharedPreferencesHelper.getUserId();
      if (!context.mounted) return;

      if (userId != 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: userId),
          ),
        ).then((_) {
          if (context.mounted) {
            onTap(0);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Та нэвтэрсэн байхгүй байна.')),
        );
      }
    }
  }
}

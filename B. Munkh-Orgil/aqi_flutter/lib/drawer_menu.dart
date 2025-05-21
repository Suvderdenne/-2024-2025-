import 'package:flutter/material.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/login_screen.dart';
import '../services/auth_state_service.dart';
import 'screens/my_trips_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/promotions_screen.dart';
import 'screens/feedback_screen.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AppDrawer({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFF2D1B69),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
                ),
                SizedBox(height: 12),
                Text(
                  userData['full_name'] ?? 'Нэргүй',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  userData['phone_number'] ?? 'Утасны дугааргүй',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  userData['email'] ?? 'И-мэйлгүй',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Машин: ${userData['car_model'] ?? 'Марк'} - ${userData['car_plate'] ?? 'Дугаар'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.edit,
                  title: 'Профайл засах',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileEditScreen(userData: userData),
                      ),
                    );
                    if (result == true) {
                      // Refresh the drawer if profile was updated
                      Navigator.pop(context, true);
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Миний аяллууд',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyTripsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Тохиргоо',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.credit_card,
                  title: 'Хэтэвч',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.access_time,
                  title: 'Урамшуулал',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PromotionsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.flag_outlined,
                  title: 'Санал, гомдол',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedbackScreen()),
                    );
                  },
                ),
                Divider(),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Гарах',
                  onTap: () async {
                    await AuthStateService.clearUserData();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLanguageButton('Монгол', true),
                _buildLanguageButton('English', false),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageButton(String language, bool isSelected) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.white : Colors.grey[200],
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(language),
        ),
      ),
    );
  }
} 
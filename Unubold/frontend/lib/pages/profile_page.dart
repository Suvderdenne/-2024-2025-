import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons_named/ionicons_named.dart';
import 'package:frontend/widgets/custom_icon_button.dart';
import 'dart:convert';
import 'package:frontend/services/api_service.dart'; // Import the new API service

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Define a modern color palette
  final Color primaryColor = const Color(0xFF00A896);
  final Color accentColor = const Color(0xFF05668D);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2D3142);
  final Color textSecondaryColor = const Color(0xFF9A9FB3);
  
  // Create an instance of our API service
  final ApiService _apiService = ApiService();

  // User profile data
  Map<String, dynamic> _userData = {
    'name': 'Ачаалж байна...',
    'email': 'loading@example.com',
  };

  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Use the API service to make a GET request
      final response = await _apiService.get('/profile/');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() => _userData = data);
        } catch (e) {
          print('JSON задлах үед алдаа гарлаа: $e');
          _showErrorDialog('Профайл мэдээлэл задлах үед алдаа гарлаа');
        }
      } else {
        print('Серверийн хариу: ${response.body}');
        _showErrorDialog('Профайл ачаалахад алдаа гарлаа: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Профайл ачаалах үед алдаа гарлаа: $e');
      if (mounted) {
        _showErrorDialog('Серверт холбогдоход алдаа гарлаа: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Алдаа', style: GoogleFonts.poppins(color: Colors.red)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Ойлголоо',
              style: GoogleFonts.poppins(color: primaryColor),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Use API service to clear tokens
      await _apiService.clearTokens();
      
      // Navigate to login page
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('Гарах үед алдаа гарлаа: $e');
      if (mounted) {
        _showErrorDialog('Системээс гарах үед алдаа гарлаа');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        centerTitle: true,
        title: Text(
          "Профайл",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
        ),
        actions: [
          CustomIconButton(
            icon: Icon(
              ionicons['settings_outline'] ?? Icons.settings,
              color: primaryColor,
              size: 24,
            ),
            onTap: () {
              // TODO: Тохиргоо хуудас руу шилжих
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: _fetchUserProfile,
          child: _isLoading 
              ? _buildLoadingState()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 30),
                      _buildProfileSection(),
                      const SizedBox(height: 16),
                      _buildAccountSection(),
                      const SizedBox(height: 16),
                      _buildPreferencesSection(),
                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          color: primaryColor,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              child: Icon(
                ionicons['person'] ?? Icons.person, 
                size: 55, 
                color: primaryColor
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['name'] ?? 'Хэрэглэгч',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['email'] ?? 'email@example.com',
            style: GoogleFonts.poppins(
              fontSize: 14, 
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          'Гарах',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: "Профайл",
      items: [
        _buildProfileItem(
          icon: ionicons['person_outline'] ?? Icons.person_outline,
          title: "Профайл засах",
          onTap: () {
            // TODO: Профайл засах хуудас руу шилжих
          },
        ),
        _buildProfileItem(
          icon: ionicons['shield_outline'] ?? Icons.shield_outlined,
          title: "Нууцлал",
          onTap: () {
            // TODO: Нууцлалын тохиргоо хуудас руу шилжих
          },
        ),
        _buildProfileItem(
          icon: ionicons['lock_closed_outline'] ?? Icons.lock_outline,
          title: "Аюулгүй байдал",
          onTap: () {
            // TODO: Аюулгүй байдлын тохиргоо хуудас руу шилжих
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: "Бүртгэл",
      items: [
        _buildProfileItem(
          icon: ionicons['card_outline'] ?? Icons.credit_card,
          title: "Төлбөрийн хэрэгслүүд",
          onTap: () {
            // TODO: Төлбөрийн хэрэгслүүдийн хуудас руу шилжих
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: "Тохиргоо",
      items: [
        _buildProfileItem(
          icon: ionicons['language_outline'] ?? Icons.language,
          title: "Хэл",
          onTap: () {
            // TODO: Хэл сонгох хуудас руу шилжих
          },
        ),
        _buildProfileItem(
          icon: ionicons['moon_outline'] ?? Icons.dark_mode_outlined,
          title: "Харанхуй горим",
          trailing: Switch.adaptive(
            value: _isDarkMode,
            activeColor: primaryColor,
            activeTrackColor: primaryColor.withOpacity(0.3),
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
                // TODO: Харанхуй горим тохируулах логик
              });
            },
          ),
        ),
        _buildProfileItem(
          icon: ionicons['notifications_outline'] ?? Icons.notifications_outlined,
          title: "Мэдэгдлүүд",
          onTap: () {
            // TODO: Мэдэгдлүүдийн тохиргоо хуудас руу шилжих
          },
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimaryColor,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15, 
              fontWeight: FontWeight.w500,
              color: textPrimaryColor,
            ),
          ),
          trailing: trailing ??
              Icon(
                ionicons['chevron_forward_outline'] ?? Icons.chevron_right, 
                color: textSecondaryColor,
                size: 20,
              ),
        ),
      ),
    );
  }
}
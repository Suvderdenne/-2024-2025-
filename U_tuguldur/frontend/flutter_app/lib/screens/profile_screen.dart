import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar( // Stack-ийг авч хаясан
                  radius: 60,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  authProvider.username ?? 'N/A',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileDetailCard(context, 'Coins', '${authProvider.coins}'),
              _buildProfileDetailCard(context, 'Levels Completed', '${authProvider.completedLevels}'),
              _buildProfileDetailCard(context, 'English Words Guessed', '${authProvider.englishWordsGuessed}'),
              _buildProfileDetailCard(context, 'Mongolian Words Guessed', '${authProvider.mongolianWordsGuessed}'),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.red[400],
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailCard(BuildContext context, String title, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
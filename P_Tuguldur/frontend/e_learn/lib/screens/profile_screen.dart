import 'dart:convert';
import 'package:e_learn/tools/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String token;
  const ProfileScreen({required this.token, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> futureProfile;

  @override
  void initState() {
    super.initState();
    futureProfile = fetchUserProfile(widget.token);
  }

  Future<UserProfile> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // Decode using UTF-8
      return UserProfile.fromJson(json.decode(decodedBody));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Color getLevelColor(String level) {
    switch (level) {
      case 'C2':
      case 'C1':
        return Colors.green.shade700;
      case 'B2':
        return Colors.lightGreen;
      case 'B1':
        return const Color(0xFF8BC34A);
      case 'A2':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF7),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<UserProfile>(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final p = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFF8BC34A),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    p.username,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(p.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 45),

                  _buildInfoCard("Last Score", p.lastScore.toString()),
                  _buildInfoCard("Last Category", p.lastCategory),
                  _buildLevelCard(p.level),
                ],
              ),
            );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLevelCard(String level) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: getLevelColor(level),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Your Level: $level",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

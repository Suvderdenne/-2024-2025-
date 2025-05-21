import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  bool isAdmin = false;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    if (token == null) {
      setState(() {
        error = "Нэвтэрсэн хэрэглэгч олдсонгүй.";
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        username = data['username'];
        email = data['email'];
        isAdmin = data['is_admin'];
        isLoading = false;
      });
    } else {
      setState(() {
        error = "Мэдээлэл ачаалахад алдаа гарлаа.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Миний Профайл'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: 'login-img',
                        child: Image.asset(
                          'images/aaa.png',
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 15),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Профайл мэдээлэл",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            profileRow(Icons.person, "Хэрэглэгчийн нэр", username),
                            const SizedBox(height: 10),
                            profileRow(Icons.email, "Имэйл", email),
                            const SizedBox(height: 10),
                            profileRow(Icons.verified_user, "Эрх", isAdmin ? "Админ" : "Энгийн хэрэглэгч"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget profileRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value ?? '',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

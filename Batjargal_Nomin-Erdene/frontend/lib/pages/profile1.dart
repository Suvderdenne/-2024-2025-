import 'dart:convert';
import 'package:ebook_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';

class Profile1Page extends StatefulWidget {
  @override
  _Profile1PageState createState() => _Profile1PageState();
}

class _Profile1PageState extends State<Profile1Page> {
  String username = "";
  String email = "";
  String profileImageBase64 = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Таны нэр';
      email = prefs.getString('email') ?? 'Таны имэйл';
      profileImageBase64 = prefs.getString('profileImage') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (profileImageBase64.isNotEmpty) {
      try {
        final rawBase64 =
            profileImageBase64.contains(',')
                ? profileImageBase64.split(',').last
                : profileImageBase64;
        imageProvider = MemoryImage(base64Decode(rawBase64));
      } catch (e) {
        imageProvider = const AssetImage('assets/images/profile.jpeg');
      }
    } else {
      imageProvider = const AssetImage('assets/images/profile.jpeg');
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 232, 255),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(radius: 50, backgroundImage: imageProvider),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            Text(
              email,
              style: const TextStyle(color: Colors.black, fontSize: 17),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Профайл засах',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfilePage()),
                      );
                    },
                  ),

                  // ГАРАХ товч – хүрээтэй, голд байрласан
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('userid');
                          await prefs.remove('token');
                          await prefs.remove('isLoggedIn');

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Гарах',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

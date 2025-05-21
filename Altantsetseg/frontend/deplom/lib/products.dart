import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  String phone = '';
  List<dynamic> orderHistory = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Нэр байхгүй';
      email = prefs.getString('email') ?? 'И-мэйл байхгүй';
      phone = prefs.getString('phone') ?? 'Утас байхгүй';

      final ordersJson = prefs.getString('order_history');
      if (ordersJson != null) {
        orderHistory = jsonDecode(ordersJson);
      }
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFE0B2)], // 🟠 Цагаан → Улбар шар
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Миний профайл'),
          backgroundColor: Colors.orange.shade700,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logout,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.orange.shade100,
                child: const Icon(Icons.person, size: 50, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              Center(child: Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Center(child: Text(email, style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(Icons.phone, color: Colors.orange),
                  title: const Text('Утас'),
                  subtitle: Text(phone),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Захиалсан бараанууд', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (orderHistory.isEmpty)
                const Text('Захиалга бүртгэгдээгүй байна')
              else
                ...orderHistory.map((item) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text('${item['quantity']}ш x ${item['price']}₮'),
                      trailing: Text(
                        '${(item['price'] as num) * (item['quantity'] ?? 1)}₮',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

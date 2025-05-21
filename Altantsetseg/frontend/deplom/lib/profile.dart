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
  List<Map<String, dynamic>> orderHistory = [];

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

      final orderJsonList = prefs.getStringList('order_history');
      if (orderJsonList != null) {
        orderHistory = orderJsonList.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
      }
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> deleteOrder(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orderHistory.removeAt(index);
    });
    final updatedOrderList = orderHistory.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('order_history', updatedOrderList);
  }

  Future<void> clearAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orderHistory.clear();
    });
    await prefs.remove('order_history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Change the background color to match the WelcomeScreen style
      appBar: AppBar(
        title: const Text('Миний профайл'),
        backgroundColor: Colors.orange,  // AppBar background color (matching with WelcomeScreen)
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
                leading: const Icon(Icons.phone),
                title: const Text('Утас'),
                subtitle: Text(phone),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Захиалсан бараанууд', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (orderHistory.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Бүх захиалгыг устгах уу?'),
                          content: const Text('Энэ үйлдлийг буцаах боломжгүй!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Цуцлах'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await clearAllOrders();
                                if (!mounted) return;
                                Navigator.pop(context);
                              },
                              child: const Text('Тийм', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (orderHistory.isEmpty)
              const Text('Захиалга бүртгэгдээгүй байна', style: TextStyle(color: Colors.grey))
            else
              ...orderHistory.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> item = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text('${item['quantity'] ?? 1}ш × ${item['price']}₮'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(item['price'] as num) * (item['quantity'] ?? 1)}₮',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Устгах уу?'),
                                content: Text('${item['name']} захиалгыг устгах уу?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Цуцлах'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await deleteOrder(index);
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Тийм', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final adminStatus = prefs.getBool('is_admin') ?? false;

    if (!adminStatus) {
      // Хэрвээ admin биш бол settings хуудсанд оруулахгүй
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context); // Буцаана
      });
    } else {
      setState(() {
        isAdmin = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ Тохиргоо'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Бүтээгдэхүүн удирдах'),
            onTap: () => Navigator.pushNamed(context, '/admin/products'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Хэрэглэгч удирдах'),
            onTap: () => Navigator.pushNamed(context, '/admin/users'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Захиалгууд'),
            onTap: () => Navigator.pushNamed(context, '/admin/orders'),
          ),
          const Divider(),
          SwitchListTile(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              // Theme toggle logic here if needed
            },
            title: const Text('Dark Mode'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Гарах'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}

// lib/admin_dashboard.dart
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Админ хяналтын самбар')),
      body: const Center(child: Text('Энд админ удирдлагын мэдээллүүд харагдана')),
    );
  }
}

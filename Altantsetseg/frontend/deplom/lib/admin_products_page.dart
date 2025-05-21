// lib/admin_products_page.dart
import 'package:flutter/material.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Бүтээгдэхүүн хянах')),
      body: const Center(child: Text('Бүх бараа, нэмэх/засах/устгах боломж')),
    );
  }
}

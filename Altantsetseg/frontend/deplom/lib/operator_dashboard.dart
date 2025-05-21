import 'package:flutter/material.dart';

class OperatorDashboard extends StatelessWidget {
  const OperatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оператор Хяналтын Хуудас'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Оператор эрхтэй хэрэглэгчийн хяналт',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: const Text('Захиалгын мэдээлэл шалгах'),
              onTap: () => Navigator.pushNamed(context, '/operator/orders'),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Тайлан, статистик үзэх'),
              onTap: () => Navigator.pushNamed(context, '/operator/reports'),
            ),
          ],
        ),
      ),
    );
  }
}

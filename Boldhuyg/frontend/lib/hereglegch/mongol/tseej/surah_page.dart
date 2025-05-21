import 'package:flutter/material.dart';

class SurahPage extends StatelessWidget {
  const SurahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Сурах"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Сурах хуудас",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

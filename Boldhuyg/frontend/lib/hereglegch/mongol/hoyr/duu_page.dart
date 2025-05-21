import 'package:flutter/material.dart';

class DuuPage extends StatelessWidget {
  const DuuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Дуу"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Text(
          "Дуу хуудас",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

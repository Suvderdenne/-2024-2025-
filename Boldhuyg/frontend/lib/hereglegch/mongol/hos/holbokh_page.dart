import 'package:flutter/material.dart';

class HolbokhPage extends StatelessWidget {
  const HolbokhPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Холбох"),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Text(
          "Холбох хуудас",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

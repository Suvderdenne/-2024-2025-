import 'package:flutter/material.dart';

class BatatgakhPage extends StatelessWidget {
  const BatatgakhPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Бататгах"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Center(
        child: Text(
          "Бататгах хуудас",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

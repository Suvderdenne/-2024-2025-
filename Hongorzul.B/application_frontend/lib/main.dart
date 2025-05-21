import 'package:flutter/material.dart';
import 'bottom_bar.dart'; // Import the bottom bar

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(), // Start with the Login Page
    );
  }
}

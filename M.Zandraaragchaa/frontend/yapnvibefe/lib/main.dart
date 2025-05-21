import 'package:flutter/material.dart';
import 'package:yapnvibefe/pages/lan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Lan(),
    );
  }
}

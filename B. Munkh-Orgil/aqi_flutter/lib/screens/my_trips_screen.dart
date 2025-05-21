import 'package:flutter/material.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Миний аяллууд'),
      ),
      body: Center(
        child: Text('Миний аяллууд хуудас'),
      ),
    );
  }
} 
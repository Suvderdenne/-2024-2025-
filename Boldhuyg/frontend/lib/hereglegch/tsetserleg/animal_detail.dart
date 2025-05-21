import 'package:flutter/material.dart'; // Flutter-ын бүх UI классууд эндээс импортлогддог

class AnimalDetailPage extends StatelessWidget {
  final int animalId;

  // `super.key`-ийг зөв ашиглах
  const AnimalDetailPage({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Амьтны дэлгэрэнгүй')),
      body: Center(child: Text('Амьтны дэлгэрэнгүй мэдээлэл: $animalId')),
    );
  }
}

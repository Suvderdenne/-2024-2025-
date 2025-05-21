import 'package:flutter/material.dart';

class BetterSleepScreen extends StatelessWidget {
  const BetterSleepScreen({super.key});

  static const List<Map<String, String>> plants = [
    {
      'name': 'Лаванда (Lavender)',
      'description':
          'Амралт, тайвшрал өгөх эфирийн тос ялгаруулдаг тул унтахад дэмжлэг үзүүлдэг.',
      'image': '/images/lavender.jpg',
    },
    {
      'name': 'Сансевиерия (Snake Plant)',
      'description':
          'Шөнийн цагаар хүчилтөрөгч ялгаруулж, агаарын чанарыг сайжруулна.',
      'image': '/images/snake.jpg',
    },
    {
      'name': 'Жасмин (Jasmine)',
      'description':
          'Сэтгэл санааг тайвшруулж, унтах чанарыг дээшлүүлдэг анхилуун үнэртэй.',
      'image': '/images/jasmine.jpg',
    },
    {
      'name': 'Алоэ вера',
      'description':
          'Агаар дахь хорт бодисыг цэвэрлэж, амгалан тайван орчин бүрдүүлнэ.',
      'image': '/images/aloevera.jpg',
    },
    {
      'name': 'Ангилалгүй кактус',
      'description':
          'Агаар чийгшүүлж, цахилгаан соронзон долгион шингээдэг гэж үздэг.',
      'image': '/images/cactus123.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Сайн нойрны ургамлууд'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.asset(
                    plant['image']!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant['name']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant['description']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AirPurifyingPage extends StatelessWidget {
  const AirPurifyingPage({super.key});

  static const List<Map<String, String>> plants = [
    {
      'name': 'Мөнгөний мод (Crassula)',
      'description':
          'Агаар дахь хорт хий, ялангуяа формальдегидийг шингээж, орчны энергийг сайжруулдаг ургамал.',
      'image': '/images/money.jpg',
    },
    {
      'name': 'Сансевиерия',
      'description':
          'Унтлагын өрөөнд хамгийн тохиромжтой ургамал. Шөнийн цагаар ч хүчилтөрөгч ялгаруулдаг.',
      'image': '/images/money2.jpg',
    },
    {
      'name': 'Хятад сарнай (Hibiscus)',
      'description':
          'Агаар чийгшүүлж, орчны чимээ багасгах, сэтгэл санаа тогтворжуулах үйлчилгээтэй.',
      'image': '/images/china.jpg',
    },
    {
      'name': 'Алоэ вера',
      'description':
          'Арьс арчилгаанд ашиглахаас гадна формальдегид болон бензол зэрэг бодисыг шингээдэг.',
      'image': '/images/aloevera.jpg',
    },
    {
      'name': 'Нулимс мод (Areca Palm)',
      'description':
          'Агаар чийгшүүлэх сайн чадвартай. Дотоод орчныг цэвэршүүлж, хүчилтөрөгчөөр баяжуулна.',
      'image': '/images/arabbb.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Агаар цэвэршүүлэгч ургамлууд'),
        centerTitle: true,
        backgroundColor: Colors.teal[600],
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 18),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant['name']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant['description']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
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

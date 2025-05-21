import 'package:flutter/material.dart';

class ShadeLovingPage extends StatelessWidget {
  const ShadeLovingPage({super.key});

  static const List<Map<String, String>> plants = [
    {
      'name': 'Потос (Pothos)',
      'description':
          'Бараан орчинд ургадаг, арчилгаа багатай, агаар цэвэршүүлдэг.',
      'image': '/images/pothos.jpg',
    },
    {
      'name': 'Замаг мод (ZZ plant)',
      'description':
          'Харанхуйн орчинд тэсвэртэй, хуурай нөхцөлд ургадаг хатуулаг ургамал.',
      'image': '/images/zz_plant.jpg',
    },
    {
      'name': 'Филодендрон (Philodendron)',
      'description':
          'Бага гэрэлд ургаж чаддаг, дотоод чимэглэлд тохиромжтой ургамал.',
      'image': '/images/philodendron.jpg',
    },
    {
      'name': 'Дал мод (Parlor Palm)',
      'description':
          'Гэрлийн хэрэгцээ бага тул оффис, гэрийн сүүдэртэй хэсэгт тохиромжтой.',
      'image': '/images/parlor_palm.jpg',
    },
    {
      'name': 'Ферн (Boston Fern)',
      'description':
          'Сүүдэрт нөхцөлд чийгшүүлэлт шаарддаг, гоёлын ногоон ургамал.',
      'image': '/images/boston_fern.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text('Сүүдэрт дуртай ургамлууд'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                      const BorderRadius.vertical(top: Radius.circular(20)),
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

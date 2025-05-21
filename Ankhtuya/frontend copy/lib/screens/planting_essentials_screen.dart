import 'package:flutter/material.dart';

class PlantingEssentialsScreen extends StatefulWidget {
  const PlantingEssentialsScreen({super.key});

  @override
  _PlantingEssentialsScreenState createState() =>
      _PlantingEssentialsScreenState();
}

class _PlantingEssentialsScreenState extends State<PlantingEssentialsScreen> {
  // Тэмдэглэлийн хувьсагч
  String? _note = '';

  final List<Map<String, dynamic>> essentials = [
    {
      'title': 'Хөрс',
      'description': 'Дотор ургамлын хөрс',
      'icon': Icons.landscape,
      'color': Colors.brown.shade100,
      'tip': 'Хөрс нь дотор ургамалд тохиромжтой.',
    },
    {
      'title': 'Сав',
      'description': 'Ус зайлуулах нүхтэй сав',
      'icon': Icons.landscape_outlined,
      'color': Colors.orange.shade100,
      'tip': 'Ус зайлуулах сав нь ургамлын үндсийг чийгтэй байлгана.',
    },
    {
      'title': 'Услах сав',
      'description': 'Нарийн хошуутай услах сав',
      'icon': Icons.water_drop,
      'color': Colors.blue.shade100,
      'tip': 'Услах сав нь ургамалд төгс услах боломж олгодог.',
    },
    {
      'title': 'Хайч',
      'description': 'Хурц, цэвэр хайч',
      'icon': Icons.content_cut,
      'color': Colors.green.shade100,
      'tip': 'Хайч нь ургамлын навчийг сайтар тайрч авахад хэрэгтэй.',
    },
    {
      'title': 'Бордоо',
      'description': 'Тэнцвэртэй ургамлын хүнс',
      'icon': Icons.spa,
      'color': Colors.purple.shade100,
      'tip': 'Бордоог ургамалд зохих хэмжээгээр хэрэглээрэй.',
    },
    {
      'title': 'Шүршигч',
      'description': 'Чийглэгт дуртай ургамлын хувьд',
      'icon': Icons.water,
      'color': Colors.cyan.shade100,
      'tip': 'Шүршигч нь чийглэгт дуртай ургамалд тохиромжтой.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ургамал тарих хэрэгсэл',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ургамал арчилгааны хэрэгсэл',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Амжилттай ургамал арчилгааны тулд шаардлагатай хэрэгсэл, материал.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: essentials.length,
              itemBuilder: (context, index) {
                final item = essentials[index];
                return GestureDetector(
                  onTap: () {
                    _showEssentialDetail(context, item);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item['color'],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (item['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 32,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Шаардлагатай дэлгэрэнгүй мэдээлэл харах дэлгэц
  void _showEssentialDetail(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController _noteController = TextEditingController();
    _noteController.text = _note ?? '';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    item['icon'],
                    size: 36,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item['title'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item['description'],
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Тэмдэглэл нэмэх',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _note = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Хадгалах'),
              ),
            ],
          ),
        );
      },
    );
  }
}

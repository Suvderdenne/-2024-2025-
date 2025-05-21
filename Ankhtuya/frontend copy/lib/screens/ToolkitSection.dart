import 'package:flutter/material.dart';
import 'package:frontend/screens/water_calculator_screen.dart';
import 'package:frontend/screens/light_meter_screen.dart';
import 'package:frontend/screens/planting_essentials_screen.dart';
import 'package:frontend/screens/nearby_stores_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolkitSection extends StatelessWidget {
  const ToolkitSection({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {
        'title': 'Усны тооцоолуур',
        'icon': Icons.opacity,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WaterCalculatorScreen(),
            ),
          );
        },
      },
      {
        'title': 'Гэрлийн хэмжигч',
        'icon': Icons.wb_sunny,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LightMeterScreen(),
            ),
          );
        },
      },
      {
        'title': 'Ургамал тарих хэрэгсэл',
        'icon': Icons.format_list_bulleted,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlantingEssentialsScreen(),
            ),
          );
        },
      },
      {
        'title': 'Ойролцоох дэлгүүр',
        'icon': Icons.map_outlined,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NearbyStoresScreen(),
            ),
          );
        },
      },
    ];

    final List<Map<String, dynamic>> tutorials = [
      {
        'title': 'Ургамал тарих анхны алхамууд',
        'videoUrl': 'https://www.youtube.com/watch?v=LuZsYOHU5Zo',
        'description': 'Ургамал тарих үндсэн алхамуудыг сурцгаая',
        'thumbnail': 'https://img.youtube.com/vi/LuZsYOHU5Zo/maxresdefault.jpg',
      },
      {
        'title': 'Ургамлын хамгаалалт',
        'videoUrl': 'https://www.youtube.com/watch?v=Hja0SLs2kus',
        'description': 'Ургамлыг хэрхэн хамгаалах талаар',
        'thumbnail': 'https://img.youtube.com/vi/Hja0SLs2kus/maxresdefault.jpg',
      },
      {
        'title': 'Ургамлын үржүүлэлт',
        'videoUrl': 'https://www.youtube.com/watch?v=Jh5oX0VRnzk',
        'description': 'Ургамлыг хэрхэн үржүүлэх талаар',
        'thumbnail': 'https://img.youtube.com/vi/Jh5oX0VRnzk/maxresdefault.jpg',
      },
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Дээд хэрэгслүүд',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final tool = tools[index];
                return GestureDetector(
                  onTap: tool['onTap'] as void Function(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tool['icon'] as IconData,
                          size: 32,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tool['title'].toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Ургамал тарих заавар',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tutorials.length,
              itemBuilder: (context, index) {
                final tutorial = tutorials[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _launchUrl(tutorial['videoUrl']),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  tutorial['thumbnail'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.play_circle_outline,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tutorial['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tutorial['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
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
          ],
        ),
      ),
    );
  }
}

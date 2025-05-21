import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart'; // make sure white, black, green are defined
import 'camera_screen.dart';
import 'plant_detail_screen.dart';
import 'better_sleep.dart';
import 'air_purifying.dart';
import 'shade_loving.dart';

class FindPlantsPage extends StatefulWidget {
  const FindPlantsPage({super.key});

  @override
  State<FindPlantsPage> createState() => _FindPlantsPageState();
}

class _FindPlantsPageState extends State<FindPlantsPage> {
  List<dynamic> picks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlantPicks();
  }

  Future<void> fetchPlantPicks() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/plants/'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          picks = data;
          isLoading = false;
        });
      } else {
        throw Exception('Ургамлыг ачахад алдаа гарлаа');
      }
    } catch (e) {
      print('Алдаа: $e');
      setState(() => isLoading = false);
    }
  }

  final List<Map<String, String>> categories = [
    {'label': 'Сайн нойр', 'image': 'assets/images/bed.jpg'},
    {'label': 'Агаар цэвэршүүлэгч', 'image': 'assets/images/air.jpg'},
    {'label': 'Сүүдэрт дуртай', 'image': 'assets/images/shade.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Хайх + Тодорхойлох
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Хайх',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text("Тодорхойлох"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ургамлын ангилал

              Padding(
                padding: const EdgeInsets.all(16), // бүх талаас 16 пиксел
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Санал болгох',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 19),
                    SizedBox(
                      height:
                          150, // Increased to fit larger CircleAvatar + text
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 19), // Equal padding both sides
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 23), // Spacing between items
                        itemBuilder: (_, index) {
                          final item = categories[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to the respective page based on the label
                              if (item['label'] == 'Сайн нойр') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BetterSleepScreen(),
                                  ),
                                );
                              } else if (item['label'] ==
                                  'Агаар цэвэршүүлэгч') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AirPurifyingPage(),
                                  ),
                                );
                              } else if (item['label'] == 'Сүүдэрт дуртай') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ShadeLovingPage(),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Centering the content
                              children: [
                                CircleAvatar(
                                  radius: 50, // Your requested size
                                  backgroundImage: AssetImage(item['image']!),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['label']!,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: picks.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // хоёр багана
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            0.75, // зургийн өндөр, өргөний харьцаа
                      ),
                      itemBuilder: (context, index) {
                        final plant = picks[index];
                        String? base64Image = plant['image_base64'];
                        Widget plantImage;

                        if (base64Image != null && base64Image.isNotEmpty) {
                          base64Image = base64Image.replaceAll(
                            RegExp(r'^data:image/[^;]+;base64,'),
                            '',
                          );
                          try {
                            plantImage = Image.memory(
                              base64Decode(base64Image),
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          } catch (e) {
                            plantImage = Container(
                              height: 130,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.red,
                              ),
                            );
                          }
                        } else {
                          plantImage = Container(
                            height: 130,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.local_florist,
                              size: 40,
                              color: Colors.green,
                            ),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: white,
                            boxShadow: [
                              BoxShadow(
                                color: black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: plantImage,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plant['name'] ?? 'Мэдэгдэхгүй',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.grass,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            plant['watering'] ?? 'Мэдэгдэхгүй',
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.wb_sunny_outlined,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            plant['temperature'] ??
                                                'Мэдэгдэхгүй',
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }
}

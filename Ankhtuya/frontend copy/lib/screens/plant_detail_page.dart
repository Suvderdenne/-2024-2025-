import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantDetailPage extends StatefulWidget {
  final int plantId;

  const PlantDetailPage({super.key, required this.plantId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  Map<String, dynamic>? plant;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlant();
  }

  Future<void> fetchPlant() async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/plants/${widget.plantId}/',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          plant = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load plant');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade700),
              ),
              const SizedBox(height: 16),
              Text(
                "Ургамлын мэдээлэл ачаалж байна...",
                style: TextStyle(color: Colors.green.shade700),
              )
            ],
          ),
        ),
      );
    }

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 70, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                'Ургамал олдсонгүй',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Буцах'),
              )
            ],
          ),
        ),
      );
    }

    String? imageBase64 = plant!['image_base64'];
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      imageBase64 = imageBase64.replaceAll(
        RegExp(r"^data:image\/[a-zA-Z]+;base64,"),
        "",
      );
    }

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero image section
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Plant image
                if (imageBase64 != null && imageBase64.isNotEmpty)
                  Image.memory(
                    base64Decode(imageBase64),
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: Colors.green.shade300,
                    child: const Icon(
                      Icons.local_florist,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Plant name overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant!['name'] ?? 'Нэргүй ургамал',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black45,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Гэрийн ургамал",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Care info section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _careInfoCard(
                            context,
                            Icons.wb_sunny_outlined,
                            "Нар",
                            plant!['sunlight'] ?? '—',
                            Colors.orange.shade700,
                          ),
                          _divider(),
                          _careInfoCard(
                            context,
                            Icons.water_drop_outlined,
                            "Усалгаа",
                            plant!['watering'] ?? '—',
                            Colors.blue.shade700,
                          ),
                          _divider(),
                          _careInfoCard(
                            context,
                            Icons.thermostat_outlined,
                            "Темп",
                            plant!['temperature'] ?? '—',
                            Colors.red.shade700,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description section
                    const Text(
                      "Тайлбар",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        plant!['description'] ?? 'Тайлбар байхгүй.',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Additional tips section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Арчилгааны зөвлөмж",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "• Шим тэжээлийн хэрэгцээг хангахын тулд 3 сард нэг удаа бордоо хийх\n• Ургамлын навчин дээр тоос хуримтлагдахаас зайлсхийх\n• Хөрсний чийгийг тогтмол шалгах",
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Add to my plants button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/addplant');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Миний ургамалд нэмэх",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _careInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/plant_detail_screen.dart';

class MyPlantsScreen extends StatefulWidget {
  @override
  _MyPlantsScreenState createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  List<dynamic> myPlants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyPlants();
  }

  Future<void> fetchMyPlants() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    if (token == null) {
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/api/user/my_plants/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        myPlants = jsonDecode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      print('Failed to load my plants');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F5),
      appBar: AppBar(
        title: const Text(
          'Миний ургамал',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/add'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            )
          : myPlants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.nature_outlined,
                        size: 64,
                        color: Colors.green.shade200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ургамал байхгүй байна',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Эхний ургамалаа нэмж эхэлнэ үү',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Ургамал нэмэх'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchMyPlants,
                  color: Colors.green.shade600,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          0.7, // Adjusted aspect ratio for flexibility
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: myPlants.length,
                    itemBuilder: (context, index) {
                      final plant = myPlants[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlantDetailScreen(plantId: plant['id']),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Plant Image
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1, // Made it flexible
                                  child: Builder(
                                    builder: (context) {
                                      final base64Image =
                                          plant['image_base64'] ??
                                              plant['plant']['image_base64'];
                                      if (base64Image == null ||
                                          base64Image.isEmpty) {
                                        return Container(
                                          color: Colors.green.shade50,
                                          child: Icon(
                                            Icons.nature,
                                            size: 40,
                                            color: Colors.green.shade200,
                                          ),
                                        );
                                      }

                                      try {
                                        final cleanedBase64 =
                                            base64Image.contains(',')
                                                ? base64Image.split(',').last
                                                : base64Image;

                                        final imageBytes =
                                            base64Decode(cleanedBase64);
                                        return Image.memory(
                                          imageBytes,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        );
                                      } catch (e) {
                                        print(
                                            'Error decoding base64 image: $e');
                                        return Container(
                                          color: Colors.green.shade50,
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.green.shade200,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              // Plant Info
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plant['nickname'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            plant['plant']['name'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.water_drop,
                                            size: 14,
                                            color: Colors.blue.shade300,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              plant['last_watered'] ??
                                                  'Усаагүй',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue.shade300,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

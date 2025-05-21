import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PlantDetailScreen extends StatefulWidget {
  final int plantId;

  const PlantDetailScreen({Key? key, required this.plantId}) : super(key: key);

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Map<String, dynamic>? plantData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPlantDetails();
  }

  Future<void> fetchPlantDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      if (token == null) {
        setState(() {
          error = 'Please login to view plant details';
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
          'http:/127.0.0.1:8000/api/plants/user/plant/${widget.plantId}/');
      print('Fetching plant details from: $url'); // Debug print

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status code: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        setState(() {
          plantData = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load plant details: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching plant details: $e'); // Debug print
      setState(() {
        error = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F5),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: fetchPlantDetails,
                        child: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 300.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.green.shade600,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          plantData?['nickname'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (plantData?['image_base64'] != null)
                              Image.memory(
                                base64Decode(
                                  plantData!['image_base64'].split(',').last,
                                ),
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                color: Colors.green.shade100,
                                child: const Icon(
                                  Icons.nature,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoCard(
                              title: 'Plant Type',
                              content: plantData?['plant']['name'] ?? 'Unknown',
                              icon: Icons.spa,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              title: 'Last Watered',
                              content: plantData?['last_watered'] != null
                                  ? DateFormat('MMMM d, y').format(
                                      DateTime.parse(
                                          plantData!['last_watered']),
                                    )
                                  : 'Never',
                              icon: Icons.water_drop,
                              daysAgo: plantData?['days_since_watered'],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              title: 'Next Watering',
                              content: plantData?['next_watering_date'] != null
                                  ? DateFormat('MMMM d, y').format(
                                      DateTime.parse(
                                          plantData!['next_watering_date']),
                                    )
                                  : 'Not scheduled',
                              icon: Icons.calendar_today,
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement water plant functionality
                              },
                              icon: const Icon(Icons.water_drop),
                              label: const Text('Water Plant'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    int? daysAgo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                if (daysAgo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$daysAgo days ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

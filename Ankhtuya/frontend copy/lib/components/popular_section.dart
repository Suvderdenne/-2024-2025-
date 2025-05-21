import 'package:flutter/material.dart';
import 'package:frontend/screens/plant_detail_page.dart';
import 'dart:convert'; // For base64Decode
import '../constants.dart';

class PopularSection extends StatelessWidget {
  final List<Map<String, dynamic>> plants;

  const PopularSection({required this.plants, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Алдартай',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Let parent scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3, // Adjust this for your layout
            ),
            itemCount: plants.length,
            itemBuilder: (_, index) {
              final plant = plants[index];
              String? imageBase64 = plant['image_base64'];

              if (imageBase64 != null && imageBase64.isNotEmpty) {
                imageBase64 = imageBase64.replaceAll(
                  RegExp(r"^data:image\/[a-zA-Z]+;base64,"),
                  "",
                );
              }

              return GestureDetector(
                onTap: () {
                  final plantId = plant['id'];
                  if (plantId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantDetailPage(plantId: plantId),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: green.withOpacity(0.1), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageBase64 != null && imageBase64.isNotEmpty
                            ? Image.memory(
                                base64Decode(imageBase64),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                plant['image'] ??
                                    'assets/images/default_image.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.green.shade100,
                                  child: const Icon(Icons.local_florist),
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          plant['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: black.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: green,
                        child: Image.asset(
                          'assets/icons/more.png',
                          color: white,
                          height: 13,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 13,
                          ),
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
    );
  }
}

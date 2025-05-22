import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllPlacesPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> places;

  const AllPlacesPage({super.key, required this.title, required this.places});

  @override
  Widget build(BuildContext context) {
    final Color persianGreen = const Color(0xFF00A896);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: persianGreen,
        elevation: 2,
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];

          final String imageUrl = (place['image'] ?? '').toString().isNotEmpty
              ? place['image']
              : 'https://via.placeholder.com/60';

          final String name = place['name']?.toString() ?? 'Нэргүй газар';
          final String description = place['description']?.toString() ?? 'Тайлбар байхгүй';
          final String rating = place['rating']?.toString() ?? '0.0';

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  ),
                ),
              ),
              title: Text(
                name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // optionally: navigate to detail page
              },
            ),
          );
        },
      ),
    );
  }
}

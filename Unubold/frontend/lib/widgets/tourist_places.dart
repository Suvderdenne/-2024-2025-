import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/models/tourist_places_model.dart';

class TouristPlaces extends StatefulWidget {
  const TouristPlaces({Key? key}) : super(key: key);

  @override
  State<TouristPlaces> createState() => _TouristPlacesState();
}

class _TouristPlacesState extends State<TouristPlaces> {
  final Color persianGreen = const Color(0xFF00A896);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: touristPlaces.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final place = touristPlaces[index];
          return GestureDetector(
            onTap: () => print('Selected: ${place.name}'),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: persianGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForCategory(place.name),
                      size: 24,
                      color: persianGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'car':
        return Icons.car_rental;
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      default:
        return Icons.location_on;
    }
  }
}

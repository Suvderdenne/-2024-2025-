import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/models/nerby_places_model.dart';
import 'package:frontend/pages/tourist_details_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NerbyPlaces extends StatefulWidget {
  const NerbyPlaces({super.key});

  @override
  _NerbyPlacesState createState() => _NerbyPlacesState();
}

class _NerbyPlacesState extends State<NerbyPlaces> {
  late Future<List<NerbyPlacesModel>> _nearbyPlacesFuture;

  @override
  void initState() {
    super.initState();
    _nearbyPlacesFuture = fetchNearbyPlaces();
  }

  Future<List<NerbyPlacesModel>> fetchNearbyPlaces() async {
    try {
      Position position = await _getCurrentLocation();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      print("TOKEN: $token");
      if (token == null) throw Exception('Access token not found');

      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/nearby_places/?lat=${position.latitude}&lon=${position.longitude}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final utf8Decoded = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(utf8Decoded);

        return data.map((item) {
          var place = NerbyPlacesModel.fromJson(item);
          place.distance ??= calculateDistance(place, position);
          return place;
        }).toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nearby places: $e');
      return [];
    }
  }

  double calculateDistance(NerbyPlacesModel place, Position position) {
    try {
      double lat = place.latitude ?? 0.0;
      double lon = place.longitude ?? 0.0;
      return Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            lat,
            lon,
          ) /
          1000;
    } catch (e) {
      print('Distance calc error: $e');
      return 0.0;
    }
  }

  Future<Position> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Location permission denied.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260, // Increased height for more content
          child: FutureBuilder<List<NerbyPlacesModel>>(
            future: _nearbyPlacesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Алдаа: ${snapshot.error}',
                        style: GoogleFonts.poppins(color: Colors.red.shade300),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: NearbyPlaceCard(place: snapshot.data![index]),
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Ойролцоо газар олдсонгүй',
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class NearbyPlaceCard extends StatelessWidget {
  final NerbyPlacesModel place;
  const NearbyPlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Slightly wider card
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // Rounder corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0, // No card elevation since we're using custom shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _navigateToDetails(context),
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.blue.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildPlaceImage(),
                  // Gradient overlay for better text visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Rating badge in top-right corner
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.rating?.toStringAsFixed(1) ?? '-.-',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Distance badge at bottom
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: _buildDistanceBadge(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name ?? 'Нэргүй газар',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.blue.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.location ?? 'Байршил тодорхойгүй',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // View Details Button
                    Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _navigateToDetails(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: Text(
                              'Дэлгэрэнгүй',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceImage() {
    return place.image != null && place.image!.isNotEmpty
        ? Hero(
            tag: 'place_image_${place.id}',
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: Image.network(
                place.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                      color: Colors.blue.shade300,
                    ),
                  );
                },
              ),
            ),
          )
        : _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildDistanceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_walk_rounded,
            color: Colors.blue.shade600,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            place.distance != null && place.distance! > 0
                ? '${place.distance!.toStringAsFixed(1)} км'
                : 'Ойрхон',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    final allImages = [
      if (place.image != null && place.image!.isNotEmpty) place.image!,
      ...place.images.where((img) => img.isNotEmpty),
    ];

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TouristDetailsPage(
              image: place.image ?? (allImages.isNotEmpty ? allImages.first : ''),
              images: allImages,
              name: place.name ?? 'Unknown Place',
              location: place.location ?? 'Unknown Location',
              description: place.description ?? 'No description available',
              phoneNumber: place.phoneNumber ?? 'Not available',
              rating: place.rating ?? 0.0,
              hotelRating: place.hotelRating ?? '0.0',
              placeId: place.id ?? 0,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
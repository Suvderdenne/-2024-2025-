import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = const LatLng(47.918873, 106.917701);
  
  // Enhanced color scheme
  final Color primaryColor = const Color(0xFF00A896);
  final Color backgroundColor = const Color(0xFFF9FAFB);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF2D3748);
  final Color accentColor = const Color(0xFFFFC107);

  List<Map<String, dynamic>> _places = [];

  Set<Marker> get _markers => _places.map((place) {
        return Marker(
          markerId: MarkerId(place['name']),
          position: place['position'],
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: 'Үнэлгээ: ${place['rating']}',
          ),
        );
      }).toSet();

  Future<void> _fetchTopRatedNearbyPlaces() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        print("❌ Access token байхгүй байна!");
        return;
      }

      final url = Uri.parse(
        'http://127.0.0.1:8000/api/top_rated_nearby_places/?lat=${position.latitude}&lon=${position.longitude}',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _places = data.map((place) {
            return {
              'name': place['name'],
              'position': LatLng(place['latitude'], place['longitude']),
              'rating': place['rating'],
              'image': place['image'] ?? '',
            };
          }).toList();
        });
      } else {
        print('⚠️ Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching places: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTopRatedNearbyPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '🌍 Хамгийн их үнэлгээтэй ойролцоох газрууд',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 20,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          // Map section with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              // Subtle gradient overlay for better text visibility at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom decoration for map
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Featured Places text
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              children: [
                Icon(
                  Icons.place_outlined, 
                  color: primaryColor, 
                  size: 24
                ),
                const SizedBox(width: 8),
                Text(
                  'Онцлох Газрууд',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          
          // Places list
          Expanded(
            child: _places.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _places.length,
                    itemBuilder: (context, index) {
                      final place = _places[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLng(place['position']),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Place image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    place['image'].isNotEmpty 
                                        ? place['image'] 
                                        : 'https://via.placeholder.com/70',
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported, 
                                          color: Colors.grey[400],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                
                                // Place details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: accentColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${place['rating']}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: textColor.withOpacity(0.7),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.location_on,
                                            color: primaryColor,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Arrow icon
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: primaryColor.withOpacity(0.5),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      // Floating action button for current location
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withBlue(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final position = await Geolocator.getCurrentPosition();
              _mapController.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(position.latitude, position.longitude),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.my_location_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
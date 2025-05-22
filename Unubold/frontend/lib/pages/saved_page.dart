import 'package:flutter/material.dart';
import 'package:frontend/models/reccommended_places_model.dart';
import 'package:frontend/pages/tourist_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late Future<List<ReccommendedPlacesModel>> _likedPlacesFuture;
  final Color _primaryColor = const Color(0xFF00A896);
  final Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _likedPlacesFuture = _fetchLikedPlaces();
  }

  Future<List<ReccommendedPlacesModel>> _fetchLikedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final likedIds = prefs.getStringList('likedPlaces') ?? [];
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Access token not found.');
    }

    if (likedIds.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/recommended_places/'),
        headers: {'Authorization': 'Bearer $token', 'Accept-Charset': 'utf-8'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((item) => ReccommendedPlacesModel.fromJson(item))
            .where((place) => likedIds.contains(place.id.toString()))
            .toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch liked places: $e');
    }
  }

  Future<void> _removeLikedPlace(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedIds = prefs.getStringList('likedPlaces') ?? [];
    likedIds.remove(placeId);
    await prefs.setStringList('likedPlaces', likedIds);
    setState(() {
      _likedPlacesFuture = _fetchLikedPlaces();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite_border_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Removed from saved places',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Хадгалсан газрууд',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.black87,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FutureBuilder<List<ReccommendedPlacesModel>>(
        future: _likedPlacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Уншиж байна...',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildLikedPlacesGrid(snapshot.data!);
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Алдаа гарлаа',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _likedPlacesFuture = _fetchLikedPlaces();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Text(
                'Дахин оролдох',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Хадгалсан газрууд байхгүй',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '"Like" дарж дуртай газраа хадгалаарай',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _primaryColor.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.favorite_rounded, size: 30, color: _primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedPlacesGrid(List<ReccommendedPlacesModel> places) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final place = places[index];
        return GestureDetector(
          onTap: () => _navigateToDetails(context, place),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image container with gradient overlay
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            place.image,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  height: 130,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_rounded,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                                ),
                          ),
                        ),
                        // Gradient overlay for better text readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: _primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      place.location,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      place.rating.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Favorite button with animated container
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeLikedPlace(place.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context, ReccommendedPlacesModel place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TouristDetailsPage(
              image: place.image,
              images: place.images,
              name: place.name,
              location: place.location,
              description: place.description,
              phoneNumber: place.phoneNumber,
              hotelRating: place.hotelRating,
              rating: place.rating,
              placeId: int.parse(place.id),
            ),
      ),
    );
  }
}

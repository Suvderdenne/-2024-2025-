import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/models/reccommended_places_model.dart';
import 'package:frontend/pages/tourist_details_page.dart';
import 'package:ionicons_named/ionicons_named.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReccommendedPlaces extends StatefulWidget {
  const ReccommendedPlaces({super.key});

  @override
  _ReccommendedPlacesState createState() => _ReccommendedPlacesState();
}

class _ReccommendedPlacesState extends State<ReccommendedPlaces> {
  late Future<List<ReccommendedPlacesModel>> _recommendedPlacesFuture;
  List<String> _likedPlacesIds = [];
  final Color primaryColor = const Color(0xFF00A896);
  final Color secondaryColor = const Color(0xFF05668D);
  final Color accentColor = const Color(0xFFF0F3BD);

  @override
  void initState() {
    super.initState();
    _recommendedPlacesFuture = _loadRecommendedPlaces();
    _loadLikedPlaces();
  }

  Future<void> _loadLikedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _likedPlacesIds = prefs.getStringList('likedPlaces') ?? [];
    });
  }

  Future<void> _toggleLike(String placeId) async {
    if (placeId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_likedPlacesIds.contains(placeId)) {
        _likedPlacesIds.remove(placeId);
      } else {
        _likedPlacesIds.add(placeId);
      }
    });
    await prefs.setStringList('likedPlaces', _likedPlacesIds);
  }

  Future<List<ReccommendedPlacesModel>> _loadRecommendedPlaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) throw Exception('Access token not found');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/recommended_places/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept-Charset': 'utf-8',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => ReccommendedPlacesModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch places: $e');
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Уншиж байна...',
            style: GoogleFonts.poppins(color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Газрын мэдээлэл ачаалахад алдаа гарлаа',
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, color: Colors.grey[400], size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Санал болгох газрууд олдсонгүй',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList(List<ReccommendedPlacesModel> places) {
    return SizedBox(
      height: 330, // Increased height for larger cards
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return _RecommendedPlaceCard(
            key: ValueKey(place.id),
            place: place,
            isLiked: _likedPlacesIds.contains(place.id),
            onLikePressed: () => _toggleLike(place.id),
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            accentColor: accentColor,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReccommendedPlacesModel>>(
      future: _recommendedPlacesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildPlacesList(snapshot.data!);
        } else {
          return _buildEmptyState();
        }
      },
    );
  }
}

class _RecommendedPlaceCard extends StatelessWidget {
  final ReccommendedPlacesModel place;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const _RecommendedPlaceCard({
    required Key key,
    required this.place,
    required this.isLiked,
    required this.onLikePressed,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allImages = [
      if (place.image.isNotEmpty) place.image,
      ...place.images.where((img) => img.isNotEmpty),
    ];

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TouristDetailsPage(
                    image: place.image.isNotEmpty ? place.image : (allImages.isNotEmpty ? allImages.first : ''),
                    images: allImages,
                    name: place.name,
                    location: place.location,
                    description: place.description,
                    phoneNumber: place.phoneNumber,
                    rating: place.rating,
                    hotelRating: place.hotelRating,
                    placeId: int.parse(place.id),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _buildHeroImage(allImages),
                    _buildImageOverlay(),
                    _buildLikeButton(),
                    _buildTypeTag(),
                    _buildRatingBadge(),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(ionicons['location_outline'] ?? Icons.location_on_outlined, 
                                color: primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (double.tryParse(place.hotelRating) != null && double.parse(place.hotelRating) > 0)
                              Row(
                                children: [
                                  Icon(Icons.hotel, color: secondaryColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${place.hotelRating}/5',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TouristDetailsPage(
                                      image: place.image.isNotEmpty ? place.image : (allImages.isNotEmpty ? allImages.first : ''),
                                      images: allImages,
                                      name: place.name,
                                      location: place.location,
                                      description: place.description,
                                      phoneNumber: place.phoneNumber,
                                      rating: place.rating,
                                      hotelRating: place.hotelRating,
                                      placeId: int.parse(place.id),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Харах',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
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
        ),
      ),
    );
  }

  Widget _buildHeroImage(List<String> allImages) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Image.network(
        place.image.isNotEmpty 
            ? place.image 
            : (allImages.isNotEmpty ? allImages.first : 'https://via.placeholder.com/280x180'),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey[500], size: 40),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.4),
            ],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onLikePressed,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag() {
    // This assumes there's a 'type' property in your model - use a placeholder if not available
    final placeType = place.type ?? "Аялал жуулчлал";
    
    return Positioned(
      bottom: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          placeType,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              place.rating.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
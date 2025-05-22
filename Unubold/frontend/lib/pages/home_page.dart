import 'dart:convert';
import 'package:frontend/pages/tourist_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/explore_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/saved_page.dart';
import 'package:frontend/widgets/nerby_places.dart';
import 'package:frontend/widgets/reccommended_places.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final Color primaryColor = const Color(0xFF00A896);
  final Color secondaryColor = const Color(0xFF05668D);
  final Color accentColor = const Color(0xFFF0F3BD);

  final List<Widget> _pages = [
    const HomeContent(),
    const ExplorePage(),
    const SavedPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildFloatingNavigationBar(),
    );
  }

  Widget _buildFloatingNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFloatingNavItem(Icons.home_rounded, "Нүүр", 0),
            _buildFloatingNavItem(Icons.explore_rounded, "Үнэлгээ", 1),
            _buildFloatingNavItem(Icons.bookmark_rounded, "Хадгалсан", 2),
            _buildFloatingNavItem(Icons.person_rounded, "Профайл", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey.shade400,
              size: 22,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allPlaces = [];
  String? _errorMessage;
  final Color primaryColor = const Color(0xFF00A896);
  final Color secondaryColor = const Color(0xFF05668D);
  final Color accentColor = const Color(0xFFF0F3BD);

  void _performSearch(String query) {
    final searchLower = query.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      _searchResults =
          _allPlaces.where((place) {
            final name = (place['name'] ?? '').toString().toLowerCase();
            final type = (place['type'] ?? '').toString().toLowerCase();
            final desc = (place['description'] ?? '').toString().toLowerCase();
            return name.contains(searchLower) ||
                type.contains(searchLower) ||
                desc.contains(searchLower);
          }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAllPlaces();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        _performSearch('');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPlaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      if (token == null) {
        setState(() {
          _errorMessage = 'Нэвтрээгүй байна. Token олдсонгүй.';
          _isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> combined = [];

      // Recommended places
      final res1 = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/recommended_places/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (res1.statusCode == 200) {
        final List<dynamic> data1 = json.decode(utf8.decode(res1.bodyBytes));
        combined.addAll(
          data1.map(
            (place) => {
              'id': place['id'],
              'name': place['name'] ?? '',
              'type': place['type'] ?? '',
              'description': place['description'] ?? '',
              'distance': '${place['distance_km'] ?? '---'} км',
              'rating': (place['rating'] ?? 0).toDouble(),
              'image': place['image'] ?? 'https://via.placeholder.com/150',
            },
          ),
        );
      }

      // Nearby places
      final res2 = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/nearby_places/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (res2.statusCode == 200) {
        final List<dynamic> data2 = json.decode(utf8.decode(res2.bodyBytes));
        combined.addAll(
          data2.map(
            (place) => {
              'id': place['id'],
              'name': place['name'] ?? '',
              'type': place['type'] ?? '',
              'description': place['description'] ?? '',
              'distance': '${place['distance_km'] ?? '---'} км',
              'rating': (place['rating'] ?? 0).toDouble(),
              'image': place['image'] ?? 'https://via.placeholder.com/150',
            },
          ),
        );
      }

      setState(() {
        _allPlaces = combined;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Сүлжээний алдаа: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [_buildSliverAppBar()];
        },
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _errorMessage != null
                ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                )
                : _buildContent(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: secondaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Монголын үзэсгэлэнт газрууд',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/YouTube.png', // <-- таны asset замыг энд бичнэ
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                        : null,
                hintText: 'Үзмэр хайх...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return _isSearching ? _buildSearchResults() : _buildDefaultContent();
  }

  Widget _buildDefaultContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Санал болгох газрууд'),
        const SizedBox(height: 16),
        const ReccommendedPlaces(),
        const SizedBox(height: 32),
        _buildSectionHeader('Ойролцоох газрууд'),
        const SizedBox(height: 16),
        const NerbyPlaces(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 24,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Үр дүн олдсонгүй',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final place = _searchResults[index];
            return _buildPlaceCard(place);
          },
        );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TouristDetailsPage(
                  placeId: place['id'],
                  name: place['name'],
                  image: place['image'],
                  location: place['distance'],
                  description: place['description'],
                  phoneNumber: '', // Хэрвээ backend өгдөг бол дамжуулна
                  rating: place['rating'],
                  images: const [], // Хэрвээ олон зураг байвал нэмж болно
                  hotelRating: '0', // шаардлагатай бол rating дамжуулна
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    place['image'] ?? 'https://via.placeholder.com/400x200',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        place['type'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                            '${place['rating']}',
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      place['description'] ?? 'Тодорхойлолт байхгүй',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place['distance'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TouristDetailsPage(
                                      placeId: place['id'],
                                      name: place['name'],
                                      image: place['image'],
                                      location: place['distance'],
                                      description: place['description'],
                                      phoneNumber: '',
                                      rating: place['rating'],
                                      images: const [],
                                      hotelRating: '0',
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Дэлгэрэнгүй',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:career_choicer/pages/UniversityDetailsScreen.dart';

class UniversityScreen extends StatefulWidget {
  @override
  _UniversityScreenState createState() => _UniversityScreenState();
}

class _UniversityScreenState extends State<UniversityScreen> {
  List<dynamic> universities = [];
  List<dynamic> filteredUniversities = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    fetchUniversities();
    _searchController.addListener(_filterUniversities);
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  Future<void> fetchUniversities() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/universities/'));
      if (response.statusCode == 200) {
        List<dynamic> universityList = decodeText(response.body);
        setState(() {
          universities = universityList;
          filteredUniversities = universityList;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load universities');
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> decodeText(String responseBody) {
    try {
      return json.decode(utf8.decode(responseBody.runes.toList()));
    } catch (e) {
      print("Error decoding JSON: $e");
      return [];
    }
  }

  void _filterUniversities() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUniversities = universities.where((uni) {
        return uni['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.school, color: Color(0xFFEAB308)),
                    SizedBox(width: 8),
                    Text(
                      "Их дээд сургуулиуд",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _isSearchFocused
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: "Search universities...",
                      prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
                      : filteredUniversities.isEmpty
                          ? Center(
                              child: Text(
                                "No universities found",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredUniversities.length,
                              itemBuilder: (context, index) {
                                return UniversityCard(university: filteredUniversities[index]);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
class UniversityCard extends StatefulWidget {
  final Map<String, dynamic> university;

  const UniversityCard({Key? key, required this.university}) : super(key: key);

  @override
  _UniversityCardState createState() => _UniversityCardState();
}

class _UniversityCardState extends State<UniversityCard> {
  bool _isPressed = false;

  Widget _buildImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
      );
    }

    String base64Cleaned = base64Image.split(',').last;

    try {
      final imageBytes = base64Decode(base64Cleaned);
      return Hero(
        tag: 'university-image-${widget.university['id']}',
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: 180, // Ensure the image fits within this height
            width: double.infinity, // Make the image stretch to the full width
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover, // Ensures the image covers the widget without distortion
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(child: Icon(Icons.error, color: Colors.red, size: 50)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => UniversityDetailsScreen(
              universityId: widget.university['id'],
            ),
            transitionsBuilder: (_, animation, __, child) { // Corrected parameter usage
              return FadeTransition(
                opacity: animation,
                child: child, // Corrected usage of 'child'
              );
            },
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        child: Card(
          elevation: 6,
          shadowColor: Colors.blue.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(widget.university['image_base64']),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.university['name'] ?? 'Unknown University',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.university['description'] ?? 'No description available',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade700),
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
    );
  }
}

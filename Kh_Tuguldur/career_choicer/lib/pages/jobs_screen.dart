import 'dart:convert';
import 'package:career_choicer/pages/CareerDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CareerScreen extends StatefulWidget {
  @override
  _CareerScreenState createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  List careers = [];
  List filteredCareers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  final Color primaryColor = const Color(0xFF4169E1); // Royal Blue
  final Color greyColor = const Color(0xFFF2F2F2); // Soft Grey

  @override
  void initState() {
    super.initState();
    fetchCareers();
    searchController.addListener(_filterCareers);
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  Future<void> fetchCareers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/careers/'));
      if (response.statusCode == 200) {
        List data = json.decode(utf8.decode(response.body.runes.toList()));
        setState(() {
          careers = data;
          filteredCareers = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception('Failed to load careers');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading careers: ${e.toString()}')),
      );
    }
  }

  void _filterCareers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCareers = careers.where((career) {
        final careerName = career['career']?.toLowerCase() ?? '';
        return careerName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Remove the ClipPath widget
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
                      Icon(Icons.work, color: Color(0xFFEAB308)),
                      SizedBox(width: 8),
                      Text(
                        "Мэргэжилүүд",
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
                      controller: searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search careers...",
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
                    child: isLoading
                        ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
                        : filteredCareers.isEmpty
                            ? Center(
                                child: Text(
                                  "No matching careers found",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredCareers.length,
                                itemBuilder: (context, index) {
                                  return CareerCard(
                                    career: filteredCareers[index],
                                    primaryColor: primaryColor,
                                    greyColor: greyColor,
                                  );
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

class CareerCard extends StatefulWidget {
  final Map<String, dynamic> career;
  final Color primaryColor;
  final Color greyColor;

  const CareerCard({
    Key? key,
    required this.career,
    required this.primaryColor,
    required this.greyColor,
  }) : super(key: key);

  @override
  _CareerCardState createState() => _CareerCardState();
}

class _CareerCardState extends State<CareerCard> {
  bool _isPressed = false;

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
            pageBuilder: (_, __, ___) => CareerDetailScreen(
              careerName: widget.career['career'],
              careerId: widget.career['id'].toString(),
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        child: Card(
          elevation: 4,
          shadowColor: widget.primaryColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, widget.greyColor.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCareerImage(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.career['career'] ?? 'Unknown Career',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: widget.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.career['description'] ?? 'No description available',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios,
                              size: 16, color: widget.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareerImage() {
    return Hero(
      tag: 'career-image-${widget.career['id']}',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.greyColor,
        ),
        child: widget.career['image_base64'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(widget.career['image_base64']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildErrorImage(),
                ),
              )
            : Center(
                child: Icon(Icons.work_outline,
                    size: 40, color: Colors.grey[500])),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.red[50],
      child: Center(
        child: Icon(Icons.error_outline, 
          color: Colors.red[300], size: 40),
      ),
    );
  }
}

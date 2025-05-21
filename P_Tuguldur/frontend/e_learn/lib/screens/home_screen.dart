import 'dart:convert';
import 'package:e_learn/screens/news_detail_screen.dart';
import 'package:e_learn/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<List<dynamic>> fetchNewsList() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/news/'));

    if (response.statusCode == 200) {
      // Decode the response body using UTF-8
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load news');
    }
  }

  void _navigateToLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildImageCard(String imagePath, String link) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          _navigateToLink(link);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(4, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              height: 150,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'English Learning App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8BC34A), // Use the specified color
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () async {
              final token = await getToken();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(token: token),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      backgroundColor: Colors.white, // Set background to white
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Text with more styling
              const Text(
                'Welcome to the English Learning App!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey, // Use the specified color
                ),
              ),
              const SizedBox(height: 20),

              // Quiz Button with rounded style
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/quiz');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A), // Use the specified color
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                child: const Text('Go to Quiz', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),

              // Label above horizontal images
              const Text(
                'Зарууд:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey, // Darker text for better contrast
                ),
              ),
              const SizedBox(height: 10),

              // Horizontal scrollable row (with shadow and rounded corners)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildImageCard('images/spring.jpg',
                        'https://www.facebook.com/profile.php?id=61555112785447'),
                    _buildImageCard(
                        'images/may.jpg', 'https://www.facebook.com/LCE.english'),
                    _buildImageCard('images/kurs.jpg',
                        'https://www.facebook.com/profile.php?id=100064042815294'),
                    _buildImageCard('images/free.jpg',
                        'https://www.facebook.com/profile.php?id=61555714905796'),
                    _buildImageCard('images/kurs2.jpg',
                        'https://www.facebook.com/profile.php?id=61555973966053'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // News Section Label
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A), // Green background color
                  borderRadius: BorderRadius.circular(12), // Slightly circular corners
                ),
                child: const Text(
                  'Latest News',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for contrast
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // News List Section
              FutureBuilder<List<dynamic>>(
                future: fetchNewsList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(
                                0xFF8BC34A))); // Use the specified color
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors
                                    .red))); // Keep error text red
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No news available',
                            style:
                                TextStyle(color: Colors.grey))); // Keep grey
                  }

                  final newsList = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final news = newsList[index];
                      final imageBase64 = news['image_base64'];
                      final title = news['title'];
                      final content = news['content'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NewsDetailScreen(news: news),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4, // Add elevation for a card effect
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)), // Rounded corners
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageBase64 != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.memory(
                                    base64Decode(imageBase64),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .black87), // More contrast
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      content.length > 100
                                          ? '${content.substring(0, 100)}...'
                                          : content,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors
                                              .black87), // Slightly darker
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


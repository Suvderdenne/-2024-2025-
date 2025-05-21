// screens/progress_screen.dart

import 'dart:convert';

import 'package:e_learn/api_service.dart'; // Assuming ApiService is in this path
import 'package:e_learn/tools/user_stats.dart'; // Assuming UserStats model is in this path
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProgressScreen extends StatefulWidget {
  final String token; // Add token if required by your ApiService

  const ProgressScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<UserStats> futureStats;
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    // Fetch user stats and profile when the screen initializes
    futureStats = ApiService().fetchUserStats(widget.token);
    fetchUserProfile(); // Fetch user profile
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/profile/'), // Adjust endpoint if needed
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Pass auth token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decode UTF-8
        final profileData = jsonDecode(decodedBody);
        setState(() {
          username = profileData['username'];
          email = profileData['email'];
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile: $e")),
        );
      }
    }
  }

  void _refreshStats() {
    setState(() {
      futureStats = ApiService().fetchUserStats(widget.token);
      fetchUserProfile(); // Refresh user profile as well
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF8BC34A);
    const Color whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'My Progress',
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: whiteColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
            color: whiteColor,
          ),
        ],
      ),
      body: FutureBuilder<UserStats>(
        future: futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading stats: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final stats = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                _refreshStats();
              },
              color: primaryGreen,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // User Profile Section
                  if (username != null && email != null)
                    Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Username: $username",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Email: $email",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Text(
                    'Your Overall Progress',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overall Score: ${stats.overallScore.toStringAsFixed(2)}%",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Estimated Level: ${stats.estimatedLevel}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 40, color: primaryGreen),
                  const Text(
                    'Score by Category & Level',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (stats.categoryStats.isEmpty)
                    const Text(
                      "No category stats available yet.",
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    ...stats.categoryStats.entries.map((categoryEntry) {
                      final categoryName = categoryEntry.key;
                      final levelStatsMap = categoryEntry.value;
                      return Card(
                        elevation: 1.0,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (levelStatsMap.isEmpty)
                                const Text(
                                  "No data for this category.",
                                  style: TextStyle(color: Colors.black54),
                                )
                              else
                                ...levelStatsMap.entries.map((levelEntry) {
                                  final levelName = levelEntry.key;
                                  final stat = levelEntry.value;
                                  Color scoreColor = Colors.black87;
                                  if (stat.scorePercent >= 80) {
                                    scoreColor = Colors.green.shade700;
                                  } else if (stat.scorePercent >= 50) {
                                    scoreColor = Colors.orange.shade700;
                                  } else {
                                    scoreColor = Colors.red.shade700;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 4.0,
                                      bottom: 4.0,
                                    ),
                                    child: Text(
                                      "$levelName: ${stat.correct}/${stat.total} correct (${stat.scorePercent.toStringAsFixed(2)}%)",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: scoreColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text(
                "No progress data found.",
                style: TextStyle(color: Colors.black54),
              ),
            );
          }
        },
      ),
    );
  }
}
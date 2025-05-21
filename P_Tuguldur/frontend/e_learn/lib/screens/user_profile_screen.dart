// screens/user_profile_screen.dart

import 'package:e_learn/api_service.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String token;

  const UserProfileScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().getUserProfile(token),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            final lastTestScore = profile['last_test_score'] ?? 0;
            final lastTestCategory = profile['last_test_category'] ?? 'N/A';
            final lastTestLevel = profile['last_test_level'] ?? 'N/A';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Last Test Score: $lastTestScore%", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text("Last Test Category: $lastTestCategory", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Last Test Level: $lastTestLevel", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load profile"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

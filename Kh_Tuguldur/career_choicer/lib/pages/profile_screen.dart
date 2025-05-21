import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color royalBlue = Color(0xFF4169E1); // Define royalBlue color
  Map<String, dynamic>? userData;
  List<dynamic> history = [];
  List<dynamic> userPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchUserPosts();
  }

  Future<void> fetchProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) throw Exception("No authentication token found");

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          userData = {
            'username': data['user']['username'] ?? 'Unknown',
            'email': data['user']['email'] ?? 'No email provided',
          };
          history = data['recommendation_history'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load profile");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> fetchUserPosts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) throw Exception("No authentication token found");

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/posts/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          userPosts = data ?? [];
        });
      } else {
        throw Exception("Failed to load posts");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Profile",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white, // Set AppBar title text color to white
            ),
          ),
          backgroundColor:royalBlue,
          elevation: 4,
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            unselectedLabelColor: Colors.white70, // Set unselected tab text color to white with opacity
            labelColor: Colors.white, // Set selected tab text color to white
            indicatorColor: Colors.white, // Set indicator color to white
            tabs: [
              Tab(
                text: "Түүх",
              ),
              Tab(
                text: "Нийтлэлүүд",
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: royalBlue))
            : TabBarView(
                children: [
                  _buildHistoryTab(royalBlue),
                  _buildUserPostsTab(royalBlue),
                ],
              ),
      ),
    );
  }

  Widget _buildHistoryTab(Color royalBlue) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileInfo(),
          SizedBox(height: 20),
          Text("Зөвлөмжийн түүх", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: royalBlue)),
          SizedBox(height: 10),
          if (history.isEmpty)
            Text("No recommendations found.", style: TextStyle(color: Colors.grey[600]))
          else
            ...history.map((item) => _buildHistoryCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildUserPostsTab(Color royalBlue) {
    return userPosts.isEmpty
        ? Center(child: Text("No posts found.", style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              var post = userPosts[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post['image'] != null && post['image'].isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            post['image'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 12),
                      Text(post['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: royalBlue)),
                      SizedBox(height: 6),
                      Text(post['content']),
                      SizedBox(height: 6),
                      Text("Posted on: ${post['created_at']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Хэрэглэгчийн нэр: ${userData!['username']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(height: 6),
          Text("Имайл: ${userData!['email']}", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Career: ${item['suggested_career']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            if (item['explanation'] != null && item['explanation'].toString().isNotEmpty)
              Text("Explanation: ${item['explanation']}"),
            SizedBox(height: 10),
            _buildListItem("Subjects", item['high_school_subjects']),
            _buildListItem("Recommended Universities", item['recommended_universities']),
            Text("Date: ${item['recommended_at']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String label, List<dynamic>? items) {
    if (items == null || items.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label:", style: TextStyle(fontWeight: FontWeight.w600)),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2),
              child: Text("• $e", style: TextStyle(color: Colors.grey[700])),
            )),
        SizedBox(height: 6),
      ],
    );
  }
}

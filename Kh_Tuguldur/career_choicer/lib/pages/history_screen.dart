import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    fetchRecommendationHistory();
  }

  Future<void> fetchRecommendationHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/recommendation-history/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        history = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recommendation History")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: history.isEmpty
            ? Center(child: Text("No recommendations yet."))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  var record = history[index];
                  return ListTile(
                    title: Text(record["career"]),
                    subtitle: Text("Recommended on: ${record["recommended_at"]}"),
                  );
                },
              ),
      ),
    );
  }
}

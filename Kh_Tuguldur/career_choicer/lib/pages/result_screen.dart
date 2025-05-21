import 'package:flutter/material.dart';
import 'dart:convert';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  ResultScreen({required this.data});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Color mainColor = Color(0xFF4169E1); // Royal Blue
  final Color accentColor = Color(0xFF6B7280); // Gray

  String decodeText(dynamic text) {
    if (text == null) return '';
    if (text is int || text is double) return text.toString();
    if (text is String) {
      try {
        return utf8.decode(latin1.encode(text));
      } catch (e) {
        return text;
      }
    }
    return text.toString();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: mainColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: accentColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var subjects = widget.data['high_school_subjects'] is List
        ? widget.data['high_school_subjects']
        : [];
    var universities = widget.data['universities'] is List
        ? widget.data['universities']
        : [];

    var suggestedCareer = decodeText(widget.data['suggested_career'] ?? "No career suggestion available");
    var explanation = decodeText(widget.data['explanation'] ?? "No explanation available");

    return Scaffold(
      appBar: AppBar(
        title: Text("Ажил мэргэжлийн зөвлөмжүүд",
            style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suggested Career
                Card(
                  color: mainColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Санал болгож буй ажил мэргэжил",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          suggestedCareer,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Explanation
                _buildSectionTitle("Тайлбар"),
                _buildInfoCard(explanation.replaceAll("*", "")),
                SizedBox(height: 20),

                // Required Subjects
                _buildSectionTitle("Шаардлагатай хичээлүүд"),
                subjects.isEmpty
                    ? _buildInfoCard("No subject information available")
                    : _buildInfoCard(subjects.map((s) => decodeText(s)).join(", ")),
                SizedBox(height: 20),

                // Recommended Universities
                _buildSectionTitle("Санал болгож буй их сургуулиуд"),
                universities.isEmpty
                    ? _buildInfoCard("No university recommendations available")
                    : Column(
                        children: universities.map<Widget>((university) {
                          String name = decodeText(university);
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              leading: Icon(Icons.school, color: mainColor),
                              title: Text(
                                name.isEmpty ? 'University' : name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: mainColor,
                                ),
                              ),
                              subtitle: Text(
                                "Undergraduate programs",
                                style: TextStyle(color: accentColor),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
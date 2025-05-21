import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'fourth_page.dart';

class ThirdPage extends StatefulWidget {
  final String playerName;

  ThirdPage({required this.playerName});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  String _selectedLanguage = "eng";
  List questionlevels = [];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    fetchQuestionlevels();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? "eng";
    });
  }

  Future<void> fetchQuestionlevels() async {
    final url = Uri.parse('http://127.0.0.1:8000/levels/');
    // final url = Uri.parse('http://192.168.4.245/levels/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data["questionlevels"] != null) {
          setState(() {
            questionlevels = data["questionlevels"];
          });
        } else {
          print("Invalid response format or missing data.");
        }
      } else {
        print("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Color getLevelColor(int index) {
    if (index == 0) {
      return Colors.green;
    } else if (index == 1) {
      return Colors.yellow.shade700;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = (screenHeight - 130) / 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: questionlevels.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: questionlevels.length,
                itemBuilder: (context, index) {
                  var item = questionlevels[index];

                  String name = _selectedLanguage == "eng"
                      ? item["eng_name"]
                      : item["mon_name"];

                  String description = _selectedLanguage == "eng"
                      ? item["eng_desc"]
                      : item["mon_desc"];

                  return GestureDetector(
                    onTap: () {
                      // Navigate to FourthPage and pass the correct data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FourthPage(
                            playerName: widget.playerName, // Corrected here
                            levelName: name, // Pass relevant data to FourthPage
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: getLevelColor(index),
                      child: Container(
                        height: cardHeight - 3,
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              description,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
